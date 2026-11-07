"use client"

import Link from "next/link"
import { useCallback, useEffect, useState } from "react"
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
import { APIHTTPError, apiErrorPresentation } from "@/lib/api/client"
import {
  teamRequest,
  type TeamContext,
  type TeamManagement,
} from "@/lib/api/teams"

export default function EmployeesScreen() {
  const [teams, setTeams] = useState<TeamManagement[]>([])
  const [loading, setLoading] = useState(true)
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const showError = (cause: unknown) => {
    if (cause instanceof APIHTTPError && [401, 403, 404].includes(cause.status))
      setTeams([])
    setError(
      apiErrorPresentation(cause, "da")?.message ??
        "Noget gik galt. Prøv igen.",
    )
  }
  const load = useCallback(async (signal?: AbortSignal) => {
    const context = await teamRequest<TeamContext>(
      "/context",
      "GET",
      undefined,
      signal,
    )
    const next = await Promise.all(
      context.managedTeams.map((team) =>
        teamRequest<TeamManagement>(
          `/${encodeURIComponent(team.id)}`,
          "GET",
          undefined,
          signal,
        ),
      ),
    )
    if (!signal?.aborted) setTeams(next)
  }, [])
  useEffect(() => {
    const controller = new AbortController()
    load(controller.signal)
      .catch((cause) => {
        if (!controller.signal.aborted) showError(cause)
      })
      .finally(() => {
        if (!controller.signal.aborted) setLoading(false)
      })
    return () => controller.abort()
  }, [load])
  async function run(action: () => Promise<void>) {
    setBusy(true)
    setError(null)
    try {
      await action()
    } catch (cause) {
      showError(cause)
    } finally {
      setBusy(false)
    }
  }
  async function mutate(teamId: string, path: string, method = "POST") {
    await run(async () => {
      const next = await teamRequest<TeamManagement>(
        `/${encodeURIComponent(teamId)}${path}`,
        method,
      )
      setTeams((current) =>
        current.map((team) => (team.team.id === teamId ? next : team)),
      )
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
          onClick={() => run(() => load())}
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
              onClick={() => run(() => load())}
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
                                mutate(
                                  employee.team.id,
                                  `/requests/${encodeURIComponent(employee.id)}/approve`,
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
                                mutate(
                                  employee.team.id,
                                  `/requests/${encodeURIComponent(employee.id)}/reject`,
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
                                    void mutate(
                                      employee.team.id,
                                      `/members/${encodeURIComponent(employee.id)}`,
                                      "DELETE",
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
