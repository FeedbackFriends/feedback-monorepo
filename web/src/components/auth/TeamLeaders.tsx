"use client"

import { useCallback, useEffect, useRef, useState, type FormEvent } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Alert, AlertDescription } from "@/components/ui/alert"
import {
  Dialog,
  DialogTrigger,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog"
import {
  AlertDialog,
  AlertDialogTrigger,
  AlertDialogContent,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogCancel,
  AlertDialogAction,
} from "@/components/ui/alert-dialog"
import {
  Table,
  TableHeader,
  TableHead,
  TableBody,
  TableRow,
  TableCell,
} from "@/components/ui/table"
import { apiErrorPresentation } from "@/lib/api/client"
import { teamRequest, type TeamLeadership } from "@/lib/api/teams"

export default function TeamLeaders({ teamId }: { teamId: string }) {
  const [data, setData] = useState<TeamLeadership | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [email, setEmail] = useState("")
  const [copied, setCopied] = useState(false)
  const [busy, setBusy] = useState(false)
  const [open, setOpen] = useState(false)
  const draft = useRef<{ id: string; email: string } | null>(null)
  const path = `/${encodeURIComponent(teamId)}/leaders`
  const load = useCallback(
    async (signal?: AbortSignal) => {
      const result = await teamRequest<TeamLeadership>(
        path,
        "GET",
        undefined,
        signal,
      )
      if (!signal?.aborted) setData(result)
    },
    [path],
  )
  useEffect(() => {
    const controller = new AbortController()
    load(controller.signal).catch((cause) => {
      if (!controller.signal.aborted) {
        setData(null)
        setError(
          apiErrorPresentation(cause, "da")?.message ??
            "Kunne ikke hente ledere.",
        )
      }
    })
    return () => controller.abort()
  }, [load])
  async function run(action: () => Promise<void>) {
    setBusy(true)
    setError(null)
    setCopied(false)
    try {
      await action()
    } catch (cause) {
      setData(null)
      setError(
        apiErrorPresentation(cause, "da")?.message ??
          "Noget gik galt. Prøv igen.",
      )
    } finally {
      setBusy(false)
    }
  }
  async function invite(event: FormEvent) {
    event.preventDefault()
    await run(async () => {
      const normalized = email.trim().toLowerCase()
      if (draft.current?.email !== normalized)
        draft.current = { id: crypto.randomUUID(), email: normalized }
      setData(
        await teamRequest<TeamLeadership>(
          `${path}/invitations`,
          "POST",
          draft.current,
        ),
      )
      draft.current = null
      setEmail("")
    })
  }
  async function remove(suffix: string) {
    await run(async () =>
      setData(await teamRequest<TeamLeadership>(`${path}${suffix}`, "DELETE")),
    )
  }
  return (
    <section className="space-y-4" aria-labelledby="leaders-heading">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h2 id="leaders-heading" className="text-lg font-semibold">
          Teamledere
        </h2>
        <Dialog open={open} onOpenChange={setOpen}>
          <DialogTrigger asChild>
            <Button variant="outline">Invitér leder</Button>
          </DialogTrigger>
          <DialogContent className="max-h-[85svh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>Invitér teamleder</DialogTitle>
              <DialogDescription>
                Lederen får kun adgang til dette team. Del det personlige link,
                og bed personen logge ind med den angivne Google-e-mail. Linket
                gælder i syv dage.
              </DialogDescription>
            </DialogHeader>
            {error && (
              <Alert variant="destructive">
                <AlertDescription>{error}</AlertDescription>
              </Alert>
            )}
            <form className="space-y-4" onSubmit={invite}>
              <Label htmlFor="leader-email">Lederens e-mail</Label>
              <Input
                id="leader-email"
                type="email"
                autoComplete="email"
                maxLength={254}
                required
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                disabled={busy}
              />
              <Button disabled={busy || !email.trim()}>
                Opret lederinvitation
              </Button>
            </form>
            {data?.invitations.map((invitation) => (
              <div key={invitation.id} className="space-y-2">
                <Label htmlFor={`invite-${invitation.id}`}>
                  {invitation.email}
                </Label>
                <Input
                  id={`invite-${invitation.id}`}
                  readOnly
                  value={`${window.location.origin}/leader-invite/${invitation.code}`}
                />
                <Button
                  variant="outline"
                  onClick={async () => {
                    try {
                      await navigator.clipboard.writeText(
                        `${window.location.origin}/leader-invite/${invitation.code}`,
                      )
                      setCopied(true)
                    } catch {
                      setError(
                        "Kunne ikke kopiere. Markér og kopiér linket i feltet.",
                      )
                    }
                  }}
                >
                  Kopiér lederlink
                </Button>
                <p className="text-sm text-muted-foreground">
                  Del linket med denne person.
                </p>
              </div>
            ))}
            {copied && (
              <p role="status" className="text-sm">
                Link kopieret
              </p>
            )}
          </DialogContent>
        </Dialog>
      </div>
      {error && !open && (
        <Alert variant="destructive">
          <AlertDescription className="space-y-2">
            <p>{error}</p>
            <Button
              variant="outline"
              disabled={busy}
              onClick={() => run(() => load())}
            >
              Prøv igen
            </Button>
          </AlertDescription>
        </Alert>
      )}
      <p className="text-sm text-muted-foreground">
        Du har som ejer adgang til alle teams. Tilføjede ledere har adgang til
        dette team.
      </p>
      {data && (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>E-mail</TableHead>
              <TableHead>Status</TableHead>
              <TableHead className="text-right">Handling</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.leaders.map((leader) => (
              <TableRow key={leader.accountId}>
                <TableCell className="whitespace-normal break-all">
                  {leader.email}
                </TableCell>
                <TableCell>Aktiv</TableCell>
                <TableCell className="text-right">
                  <AlertDialog>
                    <AlertDialogTrigger asChild>
                      <Button variant="outline" size="sm" disabled={busy}>
                        Fjern leder
                      </Button>
                    </AlertDialogTrigger>
                    <AlertDialogContent>
                      <AlertDialogHeader>
                        <AlertDialogTitle>
                          Fjern {leader.email} som leder?
                        </AlertDialogTitle>
                        <AlertDialogDescription>
                          Personen mister adgang til teamet. Medarbejdere og
                          andre ledere bliver i teamet.
                        </AlertDialogDescription>
                      </AlertDialogHeader>
                      <AlertDialogFooter>
                        <AlertDialogCancel>Annuller</AlertDialogCancel>
                        <AlertDialogAction
                          onClick={() =>
                            void remove(
                              `/${encodeURIComponent(leader.accountId)}`,
                            )
                          }
                        >
                          Fjern adgang
                        </AlertDialogAction>
                      </AlertDialogFooter>
                    </AlertDialogContent>
                  </AlertDialog>
                </TableCell>
              </TableRow>
            ))}
            {data.invitations.map((invitation) => (
              <TableRow key={invitation.id}>
                <TableCell className="whitespace-normal break-all">
                  {invitation.email}
                </TableCell>
                <TableCell>Inviteret</TableCell>
                <TableCell className="text-right">
                  <Button
                    size="sm"
                    variant="outline"
                    disabled={busy}
                    onClick={() => remove(`/invitations/${invitation.id}`)}
                  >
                    Tilbagekald
                  </Button>
                </TableCell>
              </TableRow>
            ))}
            {!data.leaders.length && !data.invitations.length && (
              <TableRow>
                <TableCell colSpan={3} className="text-muted-foreground">
                  Ingen ekstra ledere endnu.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      )}
    </section>
  )
}
