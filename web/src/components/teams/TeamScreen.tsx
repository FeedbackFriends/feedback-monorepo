"use client"

import TeamLeaders from "./TeamLeaders"
import Link from "next/link"
import { useCallback, useState } from "react"
import { Button } from "@/components/ui/button"
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
import {
  getTeam,
  getTeamContext,
  rotateTeamInvite,
  approveTeamRequest,
  rejectTeamRequest,
  removeTeamMember,
  type TeamManagement,
} from "@/lib/api/teams"
import { useTeamResource } from "./useTeamResource"

import TeamInviteDialog from "./TeamInviteDialog"

export default function TeamScreen({ teamId }: { teamId: string }) {
  const load = useCallback(
    async (signal: AbortSignal) => {
      const [details, context] = await Promise.all([
        getTeam(teamId, signal),
        getTeamContext(signal),
      ])
      return { details, isOwner: context.isOwner }
    },
    [teamId],
  )
  const {
    data,
    error,
    busy,
    refresh,
    mutate: update,
    setError,
  } = useTeamResource(load)
  const details = data?.details ?? null
  const isOwner = data?.isOwner ?? false
  const [inviteOpen, setInviteOpen] = useState(false)
  async function mutate(
    action: (signal: AbortSignal) => Promise<TeamManagement>,
  ) {
    if (!data) return
    await update(async (signal) => ({ ...data, details: await action(signal) }))
  }
  return (
    <div className="space-y-6">
      <Button asChild variant="link" className="h-auto p-0">
        <Link href="/dashboard">← Alle teams</Link>
      </Button>
      {error && (!inviteOpen || !details) && (
        <Alert variant="destructive">
          <AlertDescription className="space-y-3">
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
                onClick={() => void refresh()}
              >
                Opdater
              </Button>
              <TeamInviteDialog
                key={details.inviteCode}
                team={details.team}
                inviteCode={details.inviteCode}
                busy={busy}
                error={error}
                open={inviteOpen}
                onOpenChange={setInviteOpen}
                onRotate={() =>
                  mutate((signal) => rotateTeamInvite(teamId, signal))
                }
                onError={setError}
              />
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
                                mutate((signal) =>
                                  approveTeamRequest(
                                    teamId,
                                    request.id,
                                    signal,
                                  ),
                                )
                              }
                            >
                              Godkend
                            </Button>
                            <Button
                              size="sm"
                              variant="outline"
                              disabled={busy}
                              onClick={() =>
                                mutate((signal) =>
                                  rejectTeamRequest(teamId, request.id, signal),
                                )
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
                                  void mutate((signal) =>
                                    removeTeamMember(
                                      teamId,
                                      member.accountId,
                                      signal,
                                    ),
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
