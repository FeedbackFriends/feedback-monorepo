"use client"

import TeamLeaders from "./TeamLeaders"
import Link from "next/link"
import { useCallback, useEffect, useState } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Skeleton } from "@/components/ui/skeleton"
import {
  Table,
  TableHeader,
  TableHead,
  TableBody,
  TableRow,
  TableCell,
} from "@/components/ui/table"
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
import { APIHTTPError, apiErrorPresentation } from "@/lib/api/client"
import {
  teamRequest,
  type TeamManagement,
  type TeamContext,
} from "@/lib/api/teams"

import {
  Dialog,
  DialogTrigger,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog"

export default function TeamScreen({ teamId }: { teamId: string }) {
  const [details, setDetails] = useState<TeamManagement | null>(null)
  const [isOwner, setIsOwner] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)
  const [copied, setCopied] = useState(false)
  const [inviteOpen, setInviteOpen] = useState(false)
  const showError = (cause: unknown) => {
    if (
      cause instanceof APIHTTPError &&
      [401, 403, 404].includes(cause.status)
    ) {
      setDetails(null)
      setIsOwner(false)
      setInviteOpen(false)
    }
    setError(
      apiErrorPresentation(cause, "da")?.message ??
        "Noget gik galt. Prøv igen.",
    )
  }
  const load = useCallback(
    async (signal?: AbortSignal) => {
      const [next, context] = await Promise.all([
        teamRequest<TeamManagement>(
          `/${encodeURIComponent(teamId)}`,
          "GET",
          undefined,
          signal,
        ),
        teamRequest<TeamContext>("/context", "GET", undefined, signal),
      ])
      if (!signal?.aborted) {
        setDetails(next)
        setIsOwner(context.isOwner)
      }
    },
    [teamId],
  )
  useEffect(() => {
    const controller = new AbortController()
    load(controller.signal).catch((cause) => {
      if (!controller.signal.aborted) showError(cause)
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
      showError(cause)
    } finally {
      setBusy(false)
    }
  }
  async function mutate(path: string, method = "POST") {
    await run(async () => {
      setDetails(
        await teamRequest<TeamManagement>(
          `/${encodeURIComponent(teamId)}${path}`,
          method,
        ),
      )
    })
  }
  const invite = details
    ? `${typeof window === "undefined" ? "" : window.location.origin}/team-invite/${details.inviteCode}`
    : ""
  return (
    <div className="space-y-6">
      <Button asChild variant="link" className="h-auto p-0">
        <Link href="/dashboard">← Alle teams</Link>
      </Button>
      {error && !inviteOpen && (
        <Alert variant="destructive">
          <AlertDescription className="space-y-3">
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
      {!details ? (
        !error && (
          <div role="status" aria-label="Henter team">
            <Skeleton className="h-48 w-full" />
          </div>
        )
      ) : (
        <div className="space-y-8" aria-busy={busy}>
          <div className="flex flex-wrap items-center justify-between gap-4">
            <div className="space-y-1">
              <h1 className="text-2xl font-semibold tracking-tight">
                {details.team.name}
              </h1>
              <p className="text-sm text-muted-foreground">
                {details.team.organizationName}
              </p>
            </div>
            <div className="flex flex-wrap gap-2">
              <Button
                variant="outline"
                disabled={busy}
                onClick={() => run(() => load())}
              >
                Opdater
              </Button>
              <Dialog open={inviteOpen} onOpenChange={setInviteOpen}>
                <DialogTrigger asChild>
                  <Button>Invitér medarbejdere</Button>
                </DialogTrigger>
                <DialogContent>
                  <DialogHeader>
                    <DialogTitle asChild>
                      <h2>Invitér til {details.team.name}</h2>
                    </DialogTitle>
                    <DialogDescription>
                      Del linket med medarbejderne. De åbner det i iOS-appen og
                      anmoder om adgang. Du godkender hver person her.
                    </DialogDescription>
                  </DialogHeader>
                  {error && (
                    <Alert variant="destructive">
                      <AlertDescription>{error}</AlertDescription>
                    </Alert>
                  )}
                  <div className="space-y-3">
                    <div className="flex flex-wrap gap-3">
                      <Input
                        aria-label="Invitationslink"
                        readOnly
                        value={invite}
                        className="min-w-0 w-full"
                      />
                      <Button
                        disabled={busy}
                        onClick={async () => {
                          try {
                            await navigator.clipboard.writeText(invite)
                            setCopied(true)
                          } catch {
                            setError(
                              "Kunne ikke kopiere. Markér og kopiér linket i feltet.",
                            )
                          }
                        }}
                      >
                        Kopiér link
                      </Button>
                      <AlertDialog>
                        <AlertDialogTrigger asChild>
                          <Button variant="outline" disabled={busy}>
                            Nyt invitationslink
                          </Button>
                        </AlertDialogTrigger>
                        <AlertDialogContent>
                          <AlertDialogHeader>
                            <AlertDialogTitle>
                              Opret et nyt invitationslink?
                            </AlertDialogTitle>
                            <AlertDialogDescription>
                              Det gamle link kan derefter ikke bruges til nye
                              anmodninger. Eksisterende anmodninger og medlemmer
                              bevares.
                            </AlertDialogDescription>
                          </AlertDialogHeader>
                          <AlertDialogFooter>
                            <AlertDialogCancel>Annuller</AlertDialogCancel>
                            <AlertDialogAction
                              onClick={() => void mutate("/invite")}
                            >
                              Opret nyt link
                            </AlertDialogAction>
                          </AlertDialogFooter>
                        </AlertDialogContent>
                      </AlertDialog>
                    </div>
                    {copied && (
                      <p
                        role="status"
                        className="text-sm text-muted-foreground"
                      >
                        Link kopieret
                      </p>
                    )}
                  </div>
                </DialogContent>
              </Dialog>
            </div>
          </div>
          {isOwner && <TeamLeaders teamId={teamId} />}
          {details.pendingRequests.length > 0 && (
            <section className="space-y-4" aria-labelledby="pending-heading">
              <div className="flex items-center justify-between gap-4">
                <h2 id="pending-heading" className="text-lg font-semibold">
                  Afventer godkendelse ({details.pendingRequests.length})
                </h2>
              </div>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Navn</TableHead>
                    <TableHead className="text-right">Handling</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {details.pendingRequests.length === 0 ? (
                    <TableRow>
                      <TableCell
                        colSpan={2}
                        className="h-20 text-center text-muted-foreground"
                      >
                        Ingen nye anmodninger.
                      </TableCell>
                    </TableRow>
                  ) : (
                    details.pendingRequests.map((request) => (
                      <TableRow key={request.id}>
                        <TableCell className="max-w-40 whitespace-normal break-words font-medium">
                          {request.name}
                        </TableCell>
                        <TableCell>
                          <div className="flex justify-end gap-2">
                            <Button
                              size="sm"
                              disabled={busy}
                              onClick={() =>
                                mutate(`/requests/${request.id}/approve`)
                              }
                            >
                              Godkend
                            </Button>
                            <Button
                              size="sm"
                              variant="outline"
                              disabled={busy}
                              onClick={() =>
                                mutate(`/requests/${request.id}/reject`)
                              }
                            >
                              Afvis
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </section>
          )}
          <section className="space-y-4" aria-labelledby="members-heading">
            <h2 id="members-heading" className="text-lg font-semibold">
              Medlemmer ({details.memberCount})
            </h2>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Navn</TableHead>
                  <TableHead className="text-right">Handling</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {details.members.length === 0 ? (
                  <TableRow>
                    <TableCell
                      colSpan={2}
                      className="h-20 text-center text-muted-foreground"
                    >
                      Ingen medarbejdere er tilmeldt endnu.
                    </TableCell>
                  </TableRow>
                ) : (
                  details.members.map((member) => (
                    <TableRow key={member.accountId}>
                      <TableCell className="max-w-40 whitespace-normal break-words font-medium">
                        {member.name}
                      </TableCell>
                      <TableCell className="text-right">
                        <AlertDialog>
                          <AlertDialogTrigger asChild>
                            <Button size="sm" variant="outline" disabled={busy}>
                              Fjern
                            </Button>
                          </AlertDialogTrigger>
                          <AlertDialogContent>
                            <AlertDialogHeader>
                              <AlertDialogTitle>
                                Fjern {member.name} fra teamet?
                              </AlertDialogTitle>
                              <AlertDialogDescription>
                                Personen mister adgang til teamet og skal
                                godkendes igen for at deltage.
                              </AlertDialogDescription>
                            </AlertDialogHeader>
                            <AlertDialogFooter>
                              <AlertDialogCancel>Annuller</AlertDialogCancel>
                              <AlertDialogAction
                                variant="destructive"
                                onClick={() =>
                                  void mutate(
                                    `/members/${encodeURIComponent(member.accountId)}`,
                                    "DELETE",
                                  )
                                }
                              >
                                Fjern medlem
                              </AlertDialogAction>
                            </AlertDialogFooter>
                          </AlertDialogContent>
                        </AlertDialog>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </section>
        </div>
      )}
    </div>
  )
}
