"use client"

import { E2EAuthClient } from "@/lib/auth/e2e-auth-client"
import { FirebaseAuthClient } from "@/lib/auth/firebase-auth-client"
import type { FirebaseConfigInput } from "@/lib/auth/firebase-config"
import type {
  AuthClient,
  AuthErrorListener,
  AuthStateListener,
} from "@/lib/auth/types"

const runtimeAuthConfigPath = "/api/auth/config"
const e2eAuthEnabled = process.env.NEXT_PUBLIC_E2E_AUTH === "1"

let authClient: AuthClient = createAuthClient()
let runtimeAuthLoadPromise: Promise<AuthClient> | null = null

function createAuthClient(firebaseConfig: FirebaseConfigInput = {}) {
  return e2eAuthEnabled
    ? new E2EAuthClient()
    : new FirebaseAuthClient(firebaseConfig)
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
          `Unable to load Firebase configuration (${response.status}).`
        )
      }

      authClient = createAuthClient(
        (await response.json()) as FirebaseConfigInput
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

export function signInWithGoogle() {
  return authClient.signInWithGoogle()
}

export function sendEmailLink(email: string) {
  return authClient.sendEmailLink(email)
}

export function isEmailLink(url: string) {
  return authClient.isEmailLink(url)
}

export function getStoredEmailLinkAddress() {
  return authClient.getStoredEmailLinkAddress()
}

export function clearStoredEmailLinkAddress() {
  authClient.clearStoredEmailLinkAddress()
}

export function completeEmailLinkSignIn(email: string, url: string) {
  return authClient.completeEmailLinkSignIn(email, url)
}

export function signOut() {
  return authClient.signOut()
}
