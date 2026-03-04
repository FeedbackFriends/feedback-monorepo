"use client"

import Link from "next/link"
import { useRouter } from "next/navigation"
import { useEffect, useState } from "react"
import { LoaderCircle, LogOut, MoveLeft } from "lucide-react"
import AuthShell from "@/components/auth/AuthShell"
import { useAuth } from "@/components/auth/AuthProvider"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { signOut } from "@/lib/auth"

function getErrorMessage(error: unknown, fallback: string) {
  if (error instanceof Error && error.message) {
    return error.message
  }

  return fallback
}

export default function DashboardScreen() {
  const router = useRouter()
  const { authError, configured, status, user } = useAuth()
  const [errorMessage, setErrorMessage] = useState<string | null>(null)
  const [isSigningOut, setIsSigningOut] = useState(false)

  useEffect(() => {
    if (status === "unauthenticated") {
      router.replace("/login")
    }
  }, [router, status])

  async function handleSignOut() {
    setIsSigningOut(true)
    setErrorMessage(null)

    try {
      await signOut()
      router.replace("/login")
    } catch (error: unknown) {
      setErrorMessage(getErrorMessage(error, "Unable to sign out right now."))
    } finally {
      setIsSigningOut(false)
    }
  }

  const isLoading = status === "loading" || status === "unauthenticated"
  const displayError = configured ? errorMessage ?? authError : errorMessage

  return (
    <AuthShell
      badge="Dashboard"
      description="This protected area stays client-side and only renders once Firebase confirms an authenticated user."
      title="Your feedback dashboard is ready"
    >
      <Card className="border-white/80 bg-white/90 shadow-2xl shadow-slate-900/10 backdrop-blur">
        <CardContent className="space-y-6 p-6 sm:p-8">
          {isLoading ? (
            <div className="flex items-center justify-center gap-2 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-6 text-sm font-medium text-slate-700">
              <LoaderCircle className="h-4 w-4 animate-spin" />
              <span>Loading your session...</span>
            </div>
          ) : null}

          {!configured ? (
            <div className="rounded-2xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-950">
              Firebase is not configured, so the dashboard cannot be opened yet.
            </div>
          ) : null}

          {displayError ? (
            <div className="rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-950">
              {displayError}
            </div>
          ) : null}

          {status === "authenticated" && user ? (
            <>
              <div className="space-y-2">
                <p className="text-sm font-medium uppercase tracking-[0.25em] text-emerald-700">
                  Signed in
                </p>
                <h2 className="text-3xl font-semibold tracking-tight text-slate-950">
                  {user.displayName ?? user.email ?? "Firebase user"}
                </h2>
                <p className="text-sm leading-6 text-slate-600">
                  {user.email
                    ? `Authenticated as ${user.email}.`
                    : "Your Firebase session is active and persisted locally in this browser."}
                </p>
              </div>

              <div className="grid gap-3 rounded-2xl border border-slate-200 bg-slate-50/80 p-4 text-sm text-slate-700">
                <div className="flex items-center justify-between gap-4">
                  <span className="text-slate-500">User ID</span>
                  <span className="font-medium text-slate-950">{user.uid}</span>
                </div>
                <div className="flex items-center justify-between gap-4">
                  <span className="text-slate-500">Providers</span>
                  <span className="font-medium capitalize text-slate-950">
                    {user.providerData.map((provider) => provider.providerId).join(", ")}
                  </span>
                </div>
              </div>

              <div className="flex flex-col gap-3 sm:flex-row">
                <Button
                  className="h-11 flex-1 rounded-xl"
                  disabled={isSigningOut}
                  onClick={handleSignOut}
                  type="button"
                >
                  <LogOut className="mr-2 h-4 w-4" />
                  {isSigningOut ? "Signing out..." : "Sign out"}
                </Button>
                <Button
                  asChild
                  className="h-11 flex-1 rounded-xl"
                  variant="outline"
                >
                  <Link href="/">
                    <MoveLeft className="mr-2 h-4 w-4" />
                    Return to landing page
                  </Link>
                </Button>
              </div>
            </>
          ) : null}
        </CardContent>
      </Card>
    </AuthShell>
  )
}
