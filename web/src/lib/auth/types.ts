export type UserInfo = { providerId: string; email: string | null; displayName: string | null; uid: string; phoneNumber?: string | null; photoURL?: string | null }

export type AppAuthUser = {
  displayName: string | null
  email: string | null
  providerData: UserInfo[]
  uid: string
}

export type AuthStateListener = (user: AppAuthUser | null) => void

export type AuthErrorListener = (error: unknown) => void

export interface AuthClient {
  getIdToken(): Promise<string>
  getConfigError(): string | null
  initializePersistence(): Promise<void>
  isConfigured(): boolean
  sendEmailCode(email: string, name?: string): Promise<void>
  verifyEmailCode(email: string, code: string): Promise<void>
  signOut(): Promise<void>
  subscribeToAuthState(
    onUser: AuthStateListener,
    onError: AuthErrorListener
  ): () => void
}
