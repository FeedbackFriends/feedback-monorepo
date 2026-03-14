"use client"

import { createProviderData } from "@/lib/auth/shared"
import type {
  AppAuthUser,
  AuthClient,
  AuthErrorListener,
  AuthStateListener,
} from "@/lib/auth/types"

const e2eUserStorageKey = "feedback.e2e.auth.user"

export class E2EAuthClient implements AuthClient {
  private readonly listeners = new Set<(user: AppAuthUser | null) => void>()

  getConfigError() {
    return null
  }

  initializePersistence() {
    return Promise.resolve()
  }

  isConfigured() {
    return true
  }

  async signInWithGoogle() {
    this.setUser({
      displayName: "Playwright Test User",
      email: "playwright@example.com",
      providerData: createProviderData(
        "google.com",
        "playwright@example.com",
        "Playwright Test User"
      ),
      uid: "playwright-google-user",
    })
  }

  async signOut() {
    this.setUser(null)
  }

  subscribeToAuthState(
    onUser: AuthStateListener,
    _onError: AuthErrorListener
  ) {
    void _onError
    onUser(this.getUser())
    this.listeners.add(onUser)

    return () => {
      this.listeners.delete(onUser)
    }
  }

  private getUser() {
    if (typeof window === "undefined") {
      return null
    }

    const rawUser = window.localStorage.getItem(e2eUserStorageKey)

    if (!rawUser) {
      return null
    }

    try {
      return JSON.parse(rawUser) as AppAuthUser
    } catch {
      window.localStorage.removeItem(e2eUserStorageKey)
      return null
    }
  }

  private notifyListeners() {
    const user = this.getUser()

    this.listeners.forEach((listener) => {
      listener(user)
    })
  }

  private setUser(user: AppAuthUser | null) {
    if (typeof window === "undefined") {
      return
    }

    if (user) {
      window.localStorage.setItem(e2eUserStorageKey, JSON.stringify(user))
    } else {
      window.localStorage.removeItem(e2eUserStorageKey)
    }

    this.notifyListeners()
  }
}
