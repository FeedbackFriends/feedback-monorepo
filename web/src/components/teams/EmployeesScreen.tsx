"use client"

import Link from "next/link"
import { useCallback } from "react"
import { Button } from "@/components/ui/button"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Badge } from "@/components/ui/badge"
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
  getTeamContext,
  getTeam,
  approveTeamRequest,
  rejectTeamRequest,
  removeTeamMember,
  type TeamManagement,
} from "@/lib/api/teams"
import { useTeamResource } from "./useTeamResource"

export default function EmployeesScreen() {
  const load = useCallback(async (signal: AbortSignal) => {
    const context = await getTeamContext(signal)
    return Promise.all(
      context.managedTeams.map((team) => getTeam(team.id, signal)),
    )
  }, [])
  const {
    data,
    loading,
    busy,
    error,
    refresh,
    mutate: update,
  } = useTeamResource(load)
  const teams = data ?? []
  async function mutate(
    teamId: string,
    action: (signal: AbortSignal) => Promise<TeamManagement>,
  ) {
    await update(async (signal) => {
      const next = await action(signal)
      return teams.map((team) => (team.team.id === teamId ? next : team))
    })
  }
  const employees = teams.flatMap((team) => [
    ...team.pendingRequests.map((request) => ({
      id: request.id,
      name: request.name,
      team: team.team,
      pending: true,
    })),
    ...team.members.map((member) => ({
      id: member.accountId,
      name: member.name,
      team: team.team,
      pending: false,
    })),
  ])
  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div className="space-y-2">
          <h1 className="text-2xl font-semibold tracking-tight">
            Medarbejdere
          </h1>
          <p className="text-sm text-muted-foreground">
            Medarbejdere og anmodninger i de teams, du har adgang til.
          </p>
        </div>
        <Button
          variant="outline"
          disabled={busy || loading}
          onClick={() => void refresh()}
        >
          Opdater
        </Button>
      </div>
      {error && (
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
      {loading ? (
        <div role="status" aria-label="Henter medarbejdere">
          <Skeleton className="h-48 w-full" />
        </div>
      ) : error && teams.length === 0 ? null : (
        <>
          <p className="text-sm text-muted-foreground">
            Nye medarbejdere inviteres fra deres{" "}
            <Link href="/dashboard" className="underline underline-offset-4">
              team
            </Link>
            .
          </p>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Navn</TableHead>
                <TableHead>Team</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="text-right">Handling</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {employees.length === 0 ? (
                <TableRow>
                  <TableCell
                    colSpan={4}
                    className="h-24 text-center text-muted-foreground"
                  >
                    Ingen medarbejdere endnu. Åbn et team for at invitere de
                    første.
                  </TableCell>
                </TableRow>
              ) : (
                employees.map((employee) => (
                  <TableRow
                    key={`${employee.team.id}-${employee.pending}-${employee.id}`}
                  >
                    <TableCell className="max-w-48 whitespace-normal break-words font-medium">
                      {employee.name}
                    </TableCell>
                    <TableCell>
                      <Link
                        href={`/dashboard/teams/${employee.team.id}`}
                        className="underline-offset-4 hover:underline"
                      >
                        {employee.team.name}
                      </Link>
                    </TableCell>
                    <TableCell>
                      <Badge
                        variant={employee.pending ? "outline" : "secondary"}
                      >
                        {employee.pending ? "Afventer godkendelse" : "Aktiv"}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <div className="flex justify-end gap-2">
                        {employee.pending ? (
                          <>
                            <Button
                              size="sm"
                              disabled={busy}
                              onClick={() =>
                                mutate(employee.team.id, (signal) =>
                                  approveTeamRequest(
                                    employee.team.id,
                                    employee.id,
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
                                mutate(employee.team.id, (signal) =>
                                  rejectTeamRequest(
                                    employee.team.id,
                                    employee.id,
                                    signal,
                                  ),
                                )
                              }
                            >
                              Afvis
                            </Button>
                          </>
                        ) : (
                          <AlertDialog>
                            <AlertDialogTrigger asChild>
                              <Button size="sm" variant="ghost" disabled={busy}>
                                Fjern
                              </Button>
                            </AlertDialogTrigger>
                            <AlertDialogContent>
                              <AlertDialogHeader>
                                <AlertDialogTitle>
                                  Fjern {employee.name} fra {employee.team.name}
                                  ?
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
                                    void mutate(employee.team.id, (signal) =>
                                      removeTeamMember(
                                        employee.team.id,
                                        employee.id,
                                        signal,
                                      ),
                                    )
                                  }
                                >
                                  Fjern medarbejder
                                </AlertDialogAction>
                              </AlertDialogFooter>
                            </AlertDialogContent>
                          </AlertDialog>
                        )}
                      </div>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </>
      )}
    </div>
  )
}
