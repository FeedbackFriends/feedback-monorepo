"use client"

import { useCallback, useRef, useState, type FormEvent } from "react"
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
import {
  getTeamLeaders,
  inviteTeamLeader,
  removeTeamLeader,
  revokeLeaderInvitation,
  type LeaderInvitationInput,
  type TeamLeadership,
} from "@/lib/api/teams"
import { useTeamResource } from "./useTeamResource"

export default function TeamLeaders({ teamId }: { teamId: string }) {
  const load = useCallback(
    (signal: AbortSignal) => getTeamLeaders(teamId, signal),
    [teamId],
  )
  const { data, error, busy, accessDenied, refresh, mutate, setError } =
    useTeamResource(load)
  const [email, setEmail] = useState("")
  const [copied, setCopied] = useState(false)
  const [open, setOpen] = useState(false)
  const draft = useRef<LeaderInvitationInput | null>(null)
  async function invite(event: FormEvent) {
    event.preventDefault()
    const normalized = email.trim().toLowerCase()
    if (draft.current?.email !== normalized)
      draft.current = { id: crypto.randomUUID(), email: normalized }
    const input = draft.current
    setCopied(false)
    const next = await mutate((signal) =>
      inviteTeamLeader(teamId, input, signal),
    )
    if (next) {
      draft.current = null
      setEmail("")
    }
  }
  async function remove(
    action: (signal: AbortSignal) => Promise<TeamLeadership>,
  ) {
    setCopied(false)
    await mutate(action)
  }

  if (accessDenied)
    return (
      <Alert variant="destructive">
        <AlertDescription className="space-y-2">
          <p>{error}</p>
          <Button
            variant="outline"
            disabled={busy}
            onClick={() => void refresh()}
          >
            Prøv igen
          </Button>
        </AlertDescription>
      </Alert>
    )

  return (
    <section className="space-y-4" aria-labelledby="leaders-heading">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h2 id="leaders-heading" className="text-lg font-semibold">
          Teamledere
        </h2>
        <Dialog open={open} onOpenChange={setOpen}>
          <DialogTrigger asChild>
            <Button variant="outline" disabled={busy}>
              Invitér leder
            </Button>
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
              onClick={() => void refresh()}
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
                            void remove((signal) =>
                              removeTeamLeader(
                                teamId,
                                leader.accountId,
                                signal,
                              ),
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
                    onClick={() =>
                      remove((signal) =>
                        revokeLeaderInvitation(teamId, invitation.id, signal),
                      )
                    }
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
