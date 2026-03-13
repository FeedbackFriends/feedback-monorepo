"use client"

import { createContext, useContext, useEffect, useState, type ReactNode } from "react"
import {
  getAuthConfigError,
  initializeAuthPersistence,
  isAuthConfigured,
  loadRuntimeAuthClient,
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
  const [authError, setAuthError] = useState<string | null>(null)
  const [configured, setConfigured] = useState(false)

  useEffect(() => {
    let isMounted = true
    let unsubscribe = () => {}

    async function initializeAuth() {
      try {
        await loadRuntimeAuthClient()
      } catch (error: unknown) {
        if (!isMounted) {
          return
        }

        setUser(null)
        setConfigured(false)
        setStatus("unauthenticated")
        setAuthError(
          getErrorMessage(error, "Unable to load the Firebase configuration.")
        )
        return
      }

      if (!isMounted) {
        return
      }

      setConfigured(isAuthConfigured())
      setAuthError(getAuthConfigError())

      try {
        await initializeAuthPersistence()
      } catch (error: unknown) {
        if (isMounted) {
          setAuthError(
            getErrorMessage(error, "Unable to persist Firebase auth state.")
          )
        }
      }

      if (!isMounted) {
        return
      }

      unsubscribe = subscribeToAuthState(
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
    }

    void initializeAuth()

    return () => {
      isMounted = false
      unsubscribe()
    }
  }, [])

  return (
    <AuthContext.Provider
      value={{
        authError,
        configured,
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
