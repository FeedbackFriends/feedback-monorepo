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
  getConfigError(): string | null
  initializePersistence(): Promise<void>
  isConfigured(): boolean
  signInWithGoogle(): Promise<void>
  signOut(): Promise<void>
  subscribeToAuthState(
    onUser: AuthStateListener,
    onError: AuthErrorListener
  ): () => void
}
