"use client"

import Link from "next/link"
import { useRouter } from "next/navigation"
import { useEffect, useState, type FormEvent } from "react"
import { LoaderCircle, Mail, MoveRight } from "lucide-react"
import AuthShell from "@/components/auth/AuthShell"
import { useAuth } from "@/components/auth/AuthProvider"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import {
  clearStoredEmailLinkAddress,
  completeEmailLinkSignIn,
  getStoredEmailLinkAddress,
  isEmailLink,
  sendEmailLink,
  signInWithGoogle,
} from "@/lib/auth"

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
  const [email, setEmail] = useState("")
  const [completionEmail, setCompletionEmail] = useState("")
  const [errorMessage, setErrorMessage] = useState<string | null>(null)
  const [notice, setNotice] = useState<string | null>(null)
  const [activeAction, setActiveAction] = useState<
    "google" | "send-link" | "complete-link" | null
  >(null)
  const [needsLinkEmail, setNeedsLinkEmail] = useState(false)
  const [linkMode, setLinkMode] = useState(false)

  useEffect(() => {
    if (status === "authenticated") {
      router.replace("/dashboard")
    }
  }, [router, status])

  useEffect(() => {
    if (typeof window !== "undefined") {
      setLinkMode(isEmailLink(window.location.href))
    }
  }, [])

  useEffect(() => {
    if (!configured || !linkMode) {
      return
    }

    const storedEmail = getStoredEmailLinkAddress()

    if (!storedEmail) {
      setNeedsLinkEmail(true)
      return
    }

    setCompletionEmail(storedEmail)
    setActiveAction("complete-link")
    setErrorMessage(null)

    completeEmailLinkSignIn(storedEmail, window.location.href)
      .catch((error: unknown) => {
        setErrorMessage(
          getErrorMessage(error, "Unable to complete the email sign-in link.")
        )
        setNeedsLinkEmail(true)
      })
      .finally(() => {
        setActiveAction(null)
      })
  }, [configured, linkMode])

  async function handleGoogleSignIn() {
    setActiveAction("google")
    setErrorMessage(null)
    setNotice(null)

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

  async function handleSendLink(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setActiveAction("send-link")
    setErrorMessage(null)
    setNotice(null)

    try {
      const normalizedEmail = await sendEmailLink(email)
      setEmail(normalizedEmail)
      setCompletionEmail(normalizedEmail)
      setNeedsLinkEmail(false)
      setNotice(`Magic link sent to ${normalizedEmail}. Open it in this browser.`)
    } catch (error: unknown) {
      setErrorMessage(
        getErrorMessage(error, "Unable to send the email sign-in link.")
      )
    } finally {
      setActiveAction(null)
    }
  }

  async function handleCompleteLink(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setActiveAction("complete-link")
    setErrorMessage(null)
    setNotice(null)

    try {
      await completeEmailLinkSignIn(completionEmail, window.location.href)
      setNeedsLinkEmail(false)
    } catch (error: unknown) {
      setErrorMessage(
        getErrorMessage(error, "Unable to complete the email sign-in link.")
      )
    } finally {
      setActiveAction(null)
    }
  }

  function handleResetLinkState() {
    clearStoredEmailLinkAddress()
    setNeedsLinkEmail(true)
    setCompletionEmail("")
    setNotice(null)
    setErrorMessage(null)
  }

  const isBusy = activeAction !== null || status === "loading"
  const busyLabel =
    status === "loading"
      ? "Checking your session..."
      : activeAction === "google"
        ? "Opening Google sign-in..."
        : activeAction === "send-link"
          ? "Sending your sign-in link..."
          : null
  const configMessage = !configured
    ? authError ??
      "Firebase is not configured yet. Add the required NEXT_PUBLIC_FIREBASE_* variables to enable sign-in."
    : null
  const displayError = configured ? errorMessage ?? authError : errorMessage

  return (
    <AuthShell
      badge="Lets Grow access"
      description="Use Google or a secure email link to open your feedback dashboard without changing the existing landing page."
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

          {configured && activeAction === "complete-link" ? (
            <LoginActionSpinner label="Completing your email sign-in..." />
          ) : null}

          {notice ? (
            <div className="rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-950">
              {notice}
            </div>
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

            <div className="flex items-center gap-3 text-xs uppercase tracking-[0.25em] text-slate-400">
              <span className="h-px flex-1 bg-slate-200" />
              <span>Email link</span>
              <span className="h-px flex-1 bg-slate-200" />
            </div>

            <form className="space-y-3" onSubmit={handleSendLink}>
              <label className="block space-y-2 text-sm font-medium text-slate-700">
                <span>Email address</span>
                <div className="relative">
                  <Mail className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
                  <Input
                    autoComplete="email"
                    className="pl-10"
                    disabled={!configured || isBusy}
                    onChange={(event) => setEmail(event.target.value)}
                    placeholder="name@company.com"
                    required
                    type="email"
                    value={email}
                  />
                </div>
              </label>

              <Button
                className="h-11 w-full rounded-xl"
                disabled={!configured || isBusy}
                type="submit"
              >
                Send sign-in link
              </Button>
            </form>
          </div>

          {configured && needsLinkEmail ? (
            <form
              className="space-y-3 rounded-2xl border border-sky-100 bg-sky-50/70 p-4"
              onSubmit={handleCompleteLink}
            >
              <div className="space-y-1">
                <h3 className="text-sm font-semibold text-sky-950">
                  Finish your email sign-in
                </h3>
                <p className="text-sm leading-6 text-sky-900/80">
                  Opened the magic link on a different device or browser? Enter
                  the email address that received it to finish the sign-in.
                </p>
              </div>

              <Input
                autoComplete="email"
                disabled={isBusy}
                onChange={(event) => setCompletionEmail(event.target.value)}
                placeholder="name@company.com"
                required
                type="email"
                value={completionEmail}
              />

              <div className="flex flex-col gap-2 sm:flex-row">
                <Button
                  className="flex-1 rounded-xl"
                  disabled={isBusy}
                  type="submit"
                >
                  Complete sign-in
                </Button>
                <Button
                  className="flex-1 rounded-xl"
                  disabled={isBusy}
                  onClick={handleResetLinkState}
                  type="button"
                  variant="outline"
                >
                  Reset link state
                </Button>
              </div>
            </form>
          ) : null}

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
