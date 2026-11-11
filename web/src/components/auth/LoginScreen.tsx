"use client"

import { useRouter } from "next/navigation"
import { useEffect, useRef, useState } from "react"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Field, FieldGroup } from "@/components/ui/field"
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
import { sendEmailCode, verifyEmailCode } from "@/lib/auth"

export default function LoginScreen({ destination = "/dashboard" }: { destination?: string }) {
  const router = useRouter()
  const { authError, configured, status } = useAuth()
  const [errorMessage, setErrorMessage] = useState<string | null>(null)
  const [activeAction, setActiveAction] = useState<"email" | null>(null)

  const actionInFlight = useRef(false)
  const [emailMode, setEmailMode] = useState<"signup" | "login" | null>(null)
  const [name, setName] = useState("")
  const [email, setEmail] = useState("")
  const [code, setCode] = useState("")
  const [codeSent, setCodeSent] = useState(false)
  const [resendAt, setResendAt] = useState(0)

  async function emailAction(verify: boolean) {
    if (actionInFlight.current) return
    actionInFlight.current = true
    setActiveAction("email")
    setErrorMessage(null)
    try {
      if (verify) await verifyEmailCode(email.trim().toLowerCase(), code.trim())
      else {
        await sendEmailCode(email.trim().toLowerCase(), emailMode === "signup" ? name.trim() : undefined)
        setCodeSent(true)
        setResendAt(Date.now() + 60000)
      }
    } catch {
      setErrorMessage(verify ? "Koden er ugyldig eller udløbet. Prøv igen, eller få en ny kode." : "Kunne ikke sende koden. Vent et minut, og prøv igen.")
    } finally { actionInFlight.current = false; setActiveAction(null) }
  }

  useEffect(() => {
    if (status === "authenticated") {
      router.replace(destination)
    }
  }, [router, status, destination])

  const isBusy = activeAction !== null || status === "loading"
  const configMessage = !configured
    ? (authError ??
      "Login er ikke tilgængeligt lige nu. Prøv igen senere.")
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
              <h1 className="text-2xl">{codeSent ? "Tjek din email" : emailMode === "signup" ? "Opret med email" : "Log ind"}</h1>
            </CardTitle>
            <CardDescription>
              Brug din arbejdsmail for at komme i gang eller vende tilbage til dit team.
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
            {!emailMode && (
              <Button className="w-full" disabled={!configured || isBusy} onClick={() => setEmailMode("signup")}>
                Opret med email
              </Button>
            )}
            {emailMode && <form className="flex flex-col gap-4" onSubmit={event => { event.preventDefault(); void emailAction(codeSent) }}>
              <FieldGroup>
                {emailMode === "signup" && !codeSent && <Field>
                  <Label htmlFor="signup-name">Dit navn</Label>
                  <Input id="signup-name" autoComplete="name" required maxLength={200} pattern={".*\\S.*"}
                    value={name} disabled={isBusy} onChange={event => setName(event.target.value)} />
                </Field>}
                <Field>
                <Label htmlFor="work-email">Arbejdsmail</Label>
                <Input id="work-email" type="email" autoComplete="email" required maxLength={254}
                  value={email} disabled={isBusy || codeSent} onChange={event => setEmail(event.target.value)} />
                </Field>
                {codeSent && <>
                  <p role="status" className="text-sm">Vi har sendt en kode til {email}. Tjek også uønsket post.</p>
                  <Field>
                  <Label htmlFor="email-code">Engangskode</Label>
                  <Input id="email-code" autoComplete="one-time-code" inputMode="numeric" required
                    value={code} disabled={isBusy} onChange={event => setCode(event.target.value)} />
                  </Field>
                </>}
              </FieldGroup>
              <Button disabled={!configured || isBusy}>{isBusy ? "Vent…" : codeSent ? "Bekræft kode" : "Fortsæt"}</Button>
              {codeSent && <>
                <Button type="button" variant="outline" disabled={isBusy} onClick={() => {
                  if (Date.now() < resendAt) setErrorMessage("Vent et minut, før du beder om en ny kode.")
                  else void emailAction(false)
                }}>Send ny kode</Button>
                <Button type="button" variant="ghost" disabled={isBusy} onClick={() => { setCodeSent(false); setCode(""); setErrorMessage(null) }}>Brug en anden e-mail</Button>
              </>}
              {!codeSent && <Button type="button" variant="ghost" disabled={isBusy} onClick={() => { setEmailMode(null); setErrorMessage(null) }}>Tilbage</Button>}
            </form>}
            {!codeSent && <Button className="w-full" variant="ghost" disabled={!configured || isBusy} onClick={() => {
              setEmailMode(emailMode === "login" ? "signup" : "login")
              setErrorMessage(null)
            }}>{emailMode === "login" ? "Opret med email" : "Log ind med email"}</Button>}
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
