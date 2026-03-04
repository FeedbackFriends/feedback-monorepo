"use client"

import { createContext, useContext, useEffect, useState, type ReactNode } from "react"
import {
  getAuthConfigError,
  initializeAuthPersistence,
  isAuthConfigured,
  subscribeToAuthState,
  type AppAuthUser,
} from "@/lib/auth"

type AuthStatus = "loading" | "authenticated" | "unauthenticated"

type AuthContextValue = {
  authError: string | null
  configured: boolean
  status: AuthStatus
  user: AppAuthUser | null
}

const AuthContext = createContext<AuthContextValue | null>(null)

function getErrorMessage(error: unknown, fallback: string) {
  if (error instanceof Error && error.message) {
    return error.message
  }

  return fallback
}

type AuthProviderProps = Readonly<{
  children: ReactNode
}>

export function AuthProvider({ children }: AuthProviderProps) {
  const [status, setStatus] = useState<AuthStatus>("loading")
  const [user, setUser] = useState<AppAuthUser | null>(null)
  const [authError, setAuthError] = useState<string | null>(
    getAuthConfigError()
  )

  useEffect(() => {
    initializeAuthPersistence().catch((error: unknown) => {
      setAuthError(
        getErrorMessage(error, "Unable to persist Firebase auth state.")
      )
    })

    const unsubscribe = subscribeToAuthState(
      (nextUser) => {
        setUser(nextUser)
        setStatus(nextUser ? "authenticated" : "unauthenticated")
      },
      (error) => {
        setUser(null)
        setStatus("unauthenticated")
        setAuthError(
          getErrorMessage(error, "Unable to read the Firebase auth session.")
        )
      }
    )

    return unsubscribe
  }, [])

  return (
    <AuthContext.Provider
      value={{
        authError,
        configured: isAuthConfigured(),
        status,
        user,
      }}
    >
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)

  if (!context) {
    throw new Error("useAuth must be used within AuthProvider")
  }

  return context
}
