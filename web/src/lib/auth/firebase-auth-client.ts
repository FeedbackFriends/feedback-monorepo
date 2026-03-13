"use client"

import {
  getApp,
  getApps,
  initializeApp,
  type FirebaseOptions,
} from "firebase/app"
import {
  GoogleAuthProvider,
  browserLocalPersistence,
  getAuth,
  isSignInWithEmailLink as firebaseIsSignInWithEmailLink,
  onAuthStateChanged,
  sendSignInLinkToEmail,
  setPersistence,
  signInWithEmailLink,
  signInWithPopup,
  signOut,
} from "firebase/auth"
import {
  clearStoredEmailLinkAddress,
  emailStorageKey,
  getStoredEmailLinkAddress,
  normalizeEmail,
} from "@/lib/auth/shared"
import {
  requiredFirebaseConfigKeys,
  type FirebaseConfigInput,
  type FirebaseConfigKey,
} from "@/lib/auth/firebase-config"
import type {
  AuthClient,
  AuthErrorListener,
  AuthStateListener,
} from "@/lib/auth/types"

export class FirebaseAuthClient implements AuthClient {
  private readonly firebaseConfig: FirebaseOptions | null

  private readonly missingConfigKeys: FirebaseConfigKey[]

  private readonly googleProvider = new GoogleAuthProvider()

  constructor(rawConfig: FirebaseConfigInput) {
    this.missingConfigKeys = requiredFirebaseConfigKeys.filter(
      (key) => !rawConfig[key]
    )
    this.firebaseConfig =
      this.missingConfigKeys.length === 0
        ? (Object.fromEntries(
            Object.entries(rawConfig).filter(([, value]) => Boolean(value))
          ) as FirebaseOptions)
        : null

    this.googleProvider.setCustomParameters({ prompt: "select_account" })
  }

  clearStoredEmailLinkAddress() {
    clearStoredEmailLinkAddress()
  }

  async completeEmailLinkSignIn(email: string, url: string) {
    const normalizedEmail = normalizeEmail(email)

    await signInWithEmailLink(
      this.requireFirebaseAuth(),
      normalizedEmail,
      url
    )
    clearStoredEmailLinkAddress()
  }

  getConfigError() {
    if (this.firebaseConfig) {
      return null
    }

    return `Missing Firebase configuration: ${this.missingConfigKeys.join(", ")}`
  }

  getStoredEmailLinkAddress() {
    return getStoredEmailLinkAddress()
  }

  initializePersistence() {
    if (!this.firebaseConfig) {
      return Promise.resolve()
    }

    return setPersistence(this.requireFirebaseAuth(), browserLocalPersistence)
  }

  isConfigured() {
    return this.firebaseConfig !== null
  }

  isEmailLink(url: string) {
    const auth = this.getFirebaseAuth()
    return auth ? firebaseIsSignInWithEmailLink(auth, url) : false
  }

  async sendEmailLink(email: string) {
    const normalizedEmail = normalizeEmail(email)

    await sendSignInLinkToEmail(this.requireFirebaseAuth(), normalizedEmail, {
      url: `${window.location.origin}/login`,
      handleCodeInApp: true,
    })
    window.localStorage.setItem(emailStorageKey, normalizedEmail)
    return normalizedEmail
  }

  async signInWithGoogle() {
    await signInWithPopup(this.requireFirebaseAuth(), this.googleProvider)
  }

  async signOut() {
    await signOut(this.requireFirebaseAuth())
  }

  subscribeToAuthState(onUser: AuthStateListener, onError: AuthErrorListener) {
    const auth = this.getFirebaseAuth()

    if (!auth) {
      onUser(null)
      return () => {}
    }

    return onAuthStateChanged(auth, onUser, onError)
  }

  private getFirebaseAuth() {
    return this.firebaseConfig ? this.requireFirebaseAuth() : null
  }

  private requireFirebaseAuth() {
    if (!this.firebaseConfig) {
      throw new Error(
        `Missing Firebase config: ${this.missingConfigKeys.join(", ")}`
      )
    }

    const app =
      getApps().length > 0 ? getApp() : initializeApp(this.firebaseConfig)
    return getAuth(app)
  }
}
