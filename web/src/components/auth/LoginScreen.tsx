"use client"

import Link from "next/link"
import { useRouter } from "next/navigation"
import { useEffect, useState } from "react"
import { LoaderCircle, MoveRight } from "lucide-react"
import AuthShell from "@/components/auth/AuthShell"
import { useAuth } from "@/components/auth/AuthProvider"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { signInWithGoogle } from "@/lib/auth"

function getErrorMessage(error: unknown, fallback: string) {
  if (error instanceof Error && error.message) {
    return error.message
  }

  return fallback
}

function LoginActionSpinner({ label }: Readonly<{ label: string }>) {
  return (
    <div className="flex items-center justify-center gap-2 rounded-xl border border-emerald-100 bg-emerald-50/80 px-4 py-3 text-sm font-medium text-emerald-900">
      <LoaderCircle className="h-4 w-4 animate-spin" />
      <span>{label}</span>
    </div>
  )
}

export default function LoginScreen() {
  const router = useRouter()
  const { authError, configured, status } = useAuth()
  const [errorMessage, setErrorMessage] = useState<string | null>(null)
  const [activeAction, setActiveAction] = useState<"google" | null>(null)

  useEffect(() => {
    if (status === "authenticated") {
      router.replace("/dashboard")
    }
  }, [router, status])

  async function handleGoogleSignIn() {
    setActiveAction("google")
    setErrorMessage(null)

    try {
      await signInWithGoogle()
    } catch (error: unknown) {
      setErrorMessage(
        getErrorMessage(error, "Unable to start Google sign-in.")
      )
    } finally {
      setActiveAction(null)
    }
  }

  const isBusy = activeAction !== null || status === "loading"
  const busyLabel =
    status === "loading"
      ? "Checking your session..."
      : activeAction === "google"
        ? "Opening Google sign-in..."
        : null
  const configMessage = !configured
    ? authError ??
      "Firebase is not configured yet. Add the required NEXT_PUBLIC_FIREBASE_* variables to enable sign-in."
    : null
  const displayError = configured ? errorMessage ?? authError : errorMessage

  return (
    <AuthShell
      badge="Lets Grow access"
      description="Use Google to open your feedback dashboard without changing the existing landing page."
      title="Sign in to your meeting feedback dashboard"
    >
      <Card className="border-white/80 bg-white/85 shadow-2xl shadow-slate-900/10 backdrop-blur">
        <CardContent className="space-y-6 p-6 sm:p-8">
          <div className="space-y-2">
            <h2 className="text-2xl font-semibold text-slate-950">Welcome back</h2>
            <p className="text-sm leading-6 text-slate-600">
              Choose the fastest path into the dashboard. Your session stays
              active until you sign out.
            </p>
          </div>

          {configMessage ? (
            <div className="rounded-2xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-950">
              {configMessage}
            </div>
          ) : null}

          {configured && busyLabel ? (
            <LoginActionSpinner label={busyLabel} />
          ) : null}

          {displayError ? (
            <div className="rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-950">
              {displayError}
            </div>
          ) : null}

          <div className="space-y-3">
            <Button
              className="h-11 w-full rounded-xl bg-slate-950 text-white hover:bg-slate-800"
              disabled={!configured || isBusy}
              onClick={handleGoogleSignIn}
              type="button"
            >
              Continue with Google
            </Button>
          </div>

          <p className="flex items-center justify-between gap-2 text-xs text-slate-500">
            <span>Signed-in users are routed directly to the dashboard.</span>
            <Link
              className="inline-flex items-center gap-1 font-medium text-slate-700 transition-colors hover:text-slate-950"
              href="/"
            >
              Back to landing page
              <MoveRight className="h-3.5 w-3.5" />
            </Link>
          </p>
        </CardContent>
      </Card>
    </AuthShell>
  )
}
