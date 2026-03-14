"use client"

import { useRouter } from "next/navigation"
import { useEffect, useState } from "react"
import { LoaderCircle } from "lucide-react"
import GoogleLoginButton from "@/components/auth/GoogleLoginButton"
import { useAuth } from "@/components/auth/AuthProvider"
import Background from "@/components/layout/Background"
import BrandLogo from "@/components/layout/BrandLogo"
import SurfaceCard from "@/components/ui/SurfaceCard"
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
      setErrorMessage(getErrorMessage(error, "Kunne ikke starte Google-login."))
    } finally {
      setActiveAction(null)
    }
  }

  const isBusy = activeAction !== null || status === "loading"
  const busyLabel =
    status === "loading"
      ? "Tjekker din session..."
      : activeAction === "google"
        ? "Åbner Google-login..."
        : null
  const configMessage = !configured
    ? authError ??
      "Firebase er ikke konfigureret endnu. Tilføj de nødvendige NEXT_PUBLIC_FIREBASE_* variabler for at aktivere login."
    : null
  const displayError = configured ? errorMessage ?? authError : errorMessage

  return (
    <div className="relative min-h-screen overflow-hidden bg-background">
      <div className="pointer-events-none absolute inset-0 overflow-hidden">
        <Background />
      </div>

      <main className="relative mx-auto flex min-h-screen w-full max-w-5xl items-center justify-center px-6 py-12 lg:px-10">
        <div className="w-full max-w-md space-y-6">
          <div className="flex justify-center">
            <div className="rounded-[1.75rem] border border-white/70 bg-white/55 px-5 py-4 shadow-[0_24px_70px_-50px_rgba(40,42,71,0.8)] backdrop-blur">
              <BrandLogo className="scale-90 sm:scale-100" />
            </div>
          </div>

          <SurfaceCard className="p-6 sm:p-8">
            <div className="space-y-6">
              <div className="space-y-3 text-center">
                <h1 className="text-3xl font-semibold tracking-tight text-slate-950 sm:text-4xl">
                  Log ind
                </h1>
                <p className="text-sm leading-6 text-slate-600">
                  Fortsæt med Google for at få adgang til din konto.
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

              <GoogleLoginButton
                className="h-12 w-full px-6 text-sm font-semibold shadow-lg shadow-primary/20"
                disabled={!configured || isBusy}
                onClick={handleGoogleSignIn}
                size="default"
              />

              <p className="text-xs leading-5 text-slate-500">
                Brugere der er logget ind, sendes direkte til dashboardet.
              </p>
            </div>
          </SurfaceCard>
        </div>
      </main>
    </div>
  )
}
