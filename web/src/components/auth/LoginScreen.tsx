"use client"

import { useRouter } from "next/navigation"
import { useEffect, useState } from "react"
import { LoaderCircle } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Alert, AlertDescription } from "@/components/ui/alert"
import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
  CardFooter,
} from "@/components/ui/card"
import { useAuth } from "@/components/auth/AuthProvider"
import BrandLogo from "@/components/layout/BrandLogo"
import { signInWithGoogle } from "@/lib/auth"

function getErrorMessage(error: unknown, fallback: string) {
  if (error instanceof Error && error.message) {
    return error.message
  }

  return fallback
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
    ? (authError ??
      "Firebase er ikke konfigureret endnu. Tilføj de nødvendige NEXT_PUBLIC_FIREBASE_* variabler for at aktivere login.")
    : null
  const displayError = configured ? (errorMessage ?? authError) : errorMessage

  return (
    <main className="flex min-h-svh items-center justify-center bg-muted/40 px-4 py-12">
      <div className="w-full max-w-sm space-y-6">
        <div className="flex justify-center">
          <BrandLogo />
        </div>
        <Card>
          <CardHeader>
            <CardTitle>
              <h1 className="text-2xl">Log ind</h1>
            </CardTitle>
            <CardDescription>
              Log ind som leder for at oprette og administrere jeres teams.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {configMessage && (
              <Alert>
                <AlertDescription>{configMessage}</AlertDescription>
              </Alert>
            )}
            {displayError && (
              <Alert variant="destructive">
                <AlertDescription>{displayError}</AlertDescription>
              </Alert>
            )}
            <Button
              className="w-full"
              variant="outline"
              disabled={!configured || isBusy}
              onClick={handleGoogleSignIn}
            >
              {isBusy && (
                <LoaderCircle className="animate-spin" aria-hidden="true" />
              )}
              {busyLabel ?? "Fortsæt med Google"}
            </Button>
          </CardContent>
          <CardFooter>
            <p className="text-xs text-muted-foreground">
              Medarbejdere deltager via Lets Grow iOS-appen.
            </p>
          </CardFooter>
        </Card>
      </div>
    </main>
  )
}
