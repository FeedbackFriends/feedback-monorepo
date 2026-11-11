"use client"

import { createClient, type SupabaseClient, type User } from "@supabase/supabase-js"
import type { SupabaseConfigInput } from "./supabase-config"
import type { AppAuthUser, AuthClient, AuthErrorListener, AuthStateListener } from "./types"

function appUser(user: User | undefined): AppAuthUser | null {
  if (!user || user.is_anonymous) return null
  const name = user.user_metadata.full_name ?? user.user_metadata.name
  const displayName = typeof name === "string" ? name : null
  return {
    uid: user.id, email: user.email ?? null,
    displayName,
    providerData: (user.identities ?? []).map(identity => ({
      providerId: identity.provider, uid: identity.id,
      email: user.email ?? null, displayName,
    })),
  }
}

export class SupabaseAuthClient implements AuthClient {
  private client: SupabaseClient | null = null
  constructor(private readonly config: SupabaseConfigInput) {}
  private requireClient() {
    if (!this.config.url || !this.config.publishableKey) throw new Error("Login er ikke tilgængeligt lige nu.")
    return this.client ??= createClient(this.config.url, this.config.publishableKey, {
      auth: { flowType: "pkce", persistSession: true, autoRefreshToken: true, detectSessionInUrl: true },
    })
  }
  async getIdToken() {
    const { data, error } = await this.requireClient().auth.getSession()
    if (error) throw error
    if (!data.session) throw new Error("Log ind igen for at fortsætte.")
    return data.session.access_token
  }
  isConfigured() { return Boolean(this.config.url && this.config.publishableKey) }
  getConfigError() { return this.isConfigured() ? null : "Login er ikke tilgængeligt lige nu. Prøv igen senere." }
  async initializePersistence() {
    if (!this.isConfigured()) return
    const { error } = await this.requireClient().auth.initialize()
    if (error) throw error
  }
  async sendEmailCode(email: string, name?: string) {
    const { error } = await this.requireClient().auth.signInWithOtp({
      email,
      options: {
        emailRedirectTo: window.location.origin + window.location.pathname,
        shouldCreateUser: Boolean(name),
        ...(name ? { data: { full_name: name } } : {}),
      },
    })
    if (error) throw error
  }
  async verifyEmailCode(email: string, token: string) {
    const { error } = await this.requireClient().auth.verifyOtp({ email, token, type: "email" })
    if (error) throw error
  }
  async signOut() {
    const { error } = await this.requireClient().auth.signOut({ scope: "local" })
    if (error) throw error
  }
  subscribeToAuthState(onUser: AuthStateListener, onError: AuthErrorListener) {
    if (!this.isConfigured()) { onUser(null); return () => {} }
    const { data } = this.requireClient().auth.onAuthStateChange((_event, session) => onUser(appUser(session?.user)))
    void this.requireClient().auth.getSession().then(({ data, error }) => {
      if (error) onError(error)
      else onUser(appUser(data.session?.user))
    }).catch(onError)
    return () => data.subscription.unsubscribe()
  }
}
