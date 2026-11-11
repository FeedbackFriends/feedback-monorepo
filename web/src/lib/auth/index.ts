"use client"

import { E2EAuthClient } from "@/lib/auth/e2e-auth-client"
import { SupabaseAuthClient } from "@/lib/auth/supabase-auth-client"
import type { SupabaseConfigInput } from "@/lib/auth/supabase-config"
import type {
  AuthClient,
  AuthErrorListener,
  AuthStateListener,
} from "@/lib/auth/types"

const runtimeAuthConfigPath = "/api/auth/config"
const e2eAuthEnabled = process.env.NEXT_PUBLIC_E2E_AUTH === "1"

let authClient: AuthClient = createAuthClient()
let runtimeAuthLoadPromise: Promise<AuthClient> | null = null

function createAuthClient(supabaseConfig: SupabaseConfigInput = {}) {
  if (e2eAuthEnabled && process.env.NODE_ENV === "production") {
    throw new Error("Test authentication is unavailable in production")
  }
  return e2eAuthEnabled
    ? new E2EAuthClient()
    : new SupabaseAuthClient(supabaseConfig)
}

export type { AppAuthUser, AuthClient } from "@/lib/auth/types"

export async function loadRuntimeAuthClient() {
  if (!runtimeAuthLoadPromise) {
    runtimeAuthLoadPromise = (async () => {
      if (e2eAuthEnabled) {
        authClient = createAuthClient()
        return authClient
      }

      const response = await fetch(runtimeAuthConfigPath, {
        cache: "no-store",
      })

      if (!response.ok) {
        throw new Error(
          `Unable to load login configuration (${response.status}).`
        )
      }

      authClient = createAuthClient(
        (await response.json()) as SupabaseConfigInput
      )
      return authClient
    })().catch((error: unknown) => {
      runtimeAuthLoadPromise = null
      throw error
    })
  }

  return runtimeAuthLoadPromise
}

export function getAuthClient() {
  return authClient
}

export function getAuthConfigError() {
  return authClient.getConfigError()
}

export function isAuthConfigured() {
  return authClient.isConfigured()
}

export function initializeAuthPersistence() {
  return authClient.initializePersistence()
}

export function subscribeToAuthState(
  onUser: AuthStateListener,
  onError: AuthErrorListener
) {
  return authClient.subscribeToAuthState(onUser, onError)
}

export function signOut() {
  return authClient.signOut()
}

export const sendEmailCode = (email: string, name?: string) => authClient.sendEmailCode(email, name)
export const verifyEmailCode = (email: string, code: string) => authClient.verifyEmailCode(email, code)
