"use client"

import {
  clearStoredEmailLinkAddress,
  emailStorageKey,
  getStoredEmailLinkAddress,
  normalizeEmail,
  createProviderData,
} from "@/lib/auth/shared"
import type {
  AppAuthUser,
  AuthClient,
  AuthErrorListener,
  AuthStateListener,
} from "@/lib/auth/types"

const e2eUserStorageKey = "feedback.e2e.auth.user"

export class E2EAuthClient implements AuthClient {
  private readonly listeners = new Set<(user: AppAuthUser | null) => void>()

  clearStoredEmailLinkAddress() {
    clearStoredEmailLinkAddress()
  }

  async completeEmailLinkSignIn(email: string, _url: string) {
    void _url
    const normalizedEmail = normalizeEmail(email)

    this.setUser({
      displayName: normalizedEmail,
      email: normalizedEmail,
      providerData: createProviderData(
        "emailLink",
        normalizedEmail,
        normalizedEmail
      ),
      uid: `playwright-email-${normalizedEmail}`,
    })
    clearStoredEmailLinkAddress()
  }

  getConfigError() {
    return null
  }

  getStoredEmailLinkAddress() {
    return getStoredEmailLinkAddress()
  }

  initializePersistence() {
    return Promise.resolve()
  }

  isConfigured() {
    return true
  }

  isEmailLink(url: string) {
    const currentUrl = new URL(url)
    return currentUrl.searchParams.get("mode") === "signIn"
  }

  async sendEmailLink(email: string) {
    const normalizedEmail = normalizeEmail(email)

    if (typeof window !== "undefined") {
      window.localStorage.setItem(emailStorageKey, normalizedEmail)
    }

    return normalizedEmail
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
