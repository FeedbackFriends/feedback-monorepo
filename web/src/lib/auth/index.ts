"use client"

import { E2EAuthClient } from "@/lib/auth/e2e-auth-client"
import { FirebaseAuthClient } from "@/lib/auth/firebase-auth-client"
import type {
  AuthClient,
  AuthErrorListener,
  AuthStateListener,
} from "@/lib/auth/types"

const authClient: AuthClient =
  process.env.NEXT_PUBLIC_E2E_AUTH === "1"
    ? new E2EAuthClient()
    : new FirebaseAuthClient({
        apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
        authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
        projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
        appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
        storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
        messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
        measurementId: process.env.NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID,
      })

export type { AppAuthUser, AuthClient } from "@/lib/auth/types"

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
