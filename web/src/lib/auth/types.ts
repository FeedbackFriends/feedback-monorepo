import type { UserInfo } from "firebase/auth"

export type AppAuthUser = {
  displayName: string | null
  email: string | null
  providerData: UserInfo[]
  uid: string
}

export type AuthStateListener = (user: AppAuthUser | null) => void

export type AuthErrorListener = (error: unknown) => void

export interface AuthClient {
  clearStoredEmailLinkAddress(): void
  completeEmailLinkSignIn(email: string, url: string): Promise<void>
  getConfigError(): string | null
  getStoredEmailLinkAddress(): string | null
  initializePersistence(): Promise<void>
  isConfigured(): boolean
  isEmailLink(url: string): boolean
  sendEmailLink(email: string): Promise<string>
  signInWithGoogle(): Promise<void>
  signOut(): Promise<void>
  subscribeToAuthState(
    onUser: AuthStateListener,
    onError: AuthErrorListener
  ): () => void
}
