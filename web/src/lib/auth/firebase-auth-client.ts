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
  onAuthStateChanged,
  setPersistence,
  signInWithPopup,
  signOut,
} from "firebase/auth"
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

  getConfigError() {
    if (this.firebaseConfig) {
      return null
    }

    return `Missing Firebase configuration: ${this.missingConfigKeys.join(", ")}`
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
