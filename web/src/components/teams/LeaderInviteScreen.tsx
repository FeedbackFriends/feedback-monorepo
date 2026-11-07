"use client"

import { useEffect, useRef, useState } from "react"
import { useRouter } from "next/navigation"
import { useAuth } from "@/components/auth/AuthProvider"
import { signInWithGoogle, signOut } from "@/lib/auth"
import {
  getLeaderInvitation,
  acceptLeaderInvitation,
  type LeaderInvitationInfo,
} from "@/lib/api/teams"
import { APIHTTPError, apiErrorPresentation } from "@/lib/api/client"
import { Button } from "@/components/ui/button"
import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
} from "@/components/ui/card"
import { Alert, AlertDescription } from "@/components/ui/alert"

export default function LeaderInviteScreen({ code }: { code: string }) {
  const { user } = useAuth()
  return (
    <LeaderInvitation
      key={`${user?.uid ?? "signed-out"}:${code}`}
      code={code}
    />
  )
}

function LeaderInvitation({ code }: { code: string }) {
  const { status, user, configured } = useAuth()
  const router = useRouter()
  const [info, setInfo] = useState<LeaderInvitationInfo | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)
  const actionController = useRef<AbortController | null>(null)
  useEffect(() => () => actionController.current?.abort(), [])
  useEffect(() => {
    if (status !== "authenticated") return
    const controller = new AbortController()
    getLeaderInvitation(code, controller.signal)
      .then((next) => {
        if (!controller.signal.aborted) setInfo(next)
      })
      .catch((cause) => {
        if (!controller.signal.aborted)
          setError(
            cause instanceof APIHTTPError && [404, 409].includes(cause.status)
              ? "Invitationen er udløbet, tilbagekaldt eller allerede brugt. Bed ejeren om et nyt link."
              : (apiErrorPresentation(cause, "da")?.message ??
                  "Kunne ikke hente invitationen."),
          )
      })
    return () => controller.abort()
  }, [status, code])
  async function run(action: (signal: AbortSignal) => Promise<void>) {
    if (actionController.current) return
    const controller = new AbortController()
    actionController.current = controller
    setBusy(true)
    setError(null)
    try {
      await action(controller.signal)
    } catch (cause) {
      if (controller.signal.aborted) return
      if (
        cause instanceof APIHTTPError &&
        [401, 403, 404].includes(cause.status)
      )
        setInfo(null)
      setError(
        cause instanceof APIHTTPError && cause.status === 403
          ? "Log ind med den verificerede Google-e-mail, som invitationen er sendt til."
          : cause instanceof APIHTTPError && cause.status === 409
            ? "Du har allerede en anden tilknytning, eller invitationen er brugt. Forlad dit medarbejderteam eller kontakt ejeren."
            : (apiErrorPresentation(cause, "da")?.message ??
              "Noget gik galt. Prøv igen."),
      )
    } finally {
      if (!controller.signal.aborted) {
        actionController.current = null
        setBusy(false)
      }
    }
  }
  return (
    <main className="flex min-h-svh items-center justify-center bg-muted/40 p-4">
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>
            <h1>Invitation som teamleder</h1>
          </CardTitle>
          <CardDescription>
            {info
              ? `${info.team.organizationName} · ${info.team.name}`
              : "Log ind med Google for at se og acceptere din personlige invitation."}
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {error && (
            <Alert variant="destructive">
              <AlertDescription>{error}</AlertDescription>
            </Alert>
          )}
          {status === "unauthenticated" && (
            <Button
              disabled={busy || !configured}
              onClick={() => run(signInWithGoogle)}
            >
              Fortsæt med Google
            </Button>
          )}
          {status === "authenticated" && (
            <>
              <p className="break-all text-sm">Logget ind som {user?.email}.</p>
              {info && (
                <>
                  <p className="break-all text-sm">
                    Invitationen gælder {info.email}. Du får adgang til dette
                    team.
                  </p>
                  <Button
                    disabled={busy}
                    onClick={() =>
                      run(async (signal) => {
                        await acceptLeaderInvitation({ code }, signal)
                        signal.throwIfAborted()
                        if (info)
                          router.replace(`/dashboard/teams/${info.team.id}`)
                      })
                    }
                  >
                    Acceptér invitation
                  </Button>
                </>
              )}
              <Button
                variant="outline"
                disabled={busy}
                onClick={() =>
                  run(async () => {
                    await signOut()
                    setInfo(null)
                  })
                }
              >
                Brug en anden Google-konto
              </Button>
            </>
          )}
        </CardContent>
      </Card>
    </main>
  )
}
