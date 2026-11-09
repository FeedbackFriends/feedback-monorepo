"use client"

import { useCallback } from "react"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Button } from "@/components/ui/button"
import { Skeleton } from "@/components/ui/skeleton"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import {
  AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent,
  AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle, AlertDialogTrigger,
} from "@/components/ui/alert-dialog"
import { getReportedSuggestions, moderateTeamSuggestion } from "@/lib/api/teams"
import { useTeamResource } from "./useTeamResource"

export default function TeamSuggestionReports({ teamId }: { teamId: string }) {
  const load = useCallback((signal: AbortSignal) => getReportedSuggestions(teamId, signal), [teamId])
  const { data, error, busy, refresh, mutate } = useTeamResource(load)

  return (
    <section className="flex flex-col gap-4" aria-labelledby="suggestion-reports-heading" aria-busy={busy}>
      <div className="flex flex-wrap items-center justify-between gap-2">
        <h2 id="suggestion-reports-heading" className="text-lg font-semibold">Rapporterede forslag</h2>
        <Button variant="outline" disabled={busy} onClick={() => void refresh()}>Opdater rapporter</Button>
      </div>
      <p className="text-sm text-muted-foreground">
        Gennemgå indhold, som medarbejdere har rapporteret som upassende eller identificerende.
        Forfatter og afsender af rapporten vises ikke. Forslaget er synligt for teamet, indtil du fjerner det.
      </p>
      {error && <Alert variant="destructive"><AlertDescription>{error}</AlertDescription></Alert>}
      {!data ? (
        !error && <Skeleton className="h-24 w-full" aria-label="Henter rapporter" />
      ) : (
        <Table>
          <TableHeader><TableRow><TableHead>Forslag</TableHead><TableHead className="text-right">Vurdering</TableHead></TableRow></TableHeader>
          <TableBody>
            {data.length === 0 ? (
              <TableRow><TableCell colSpan={2} className="h-20 text-center text-muted-foreground">Ingen forslag afventer gennemgang.</TableCell></TableRow>
            ) : data.map((suggestion) => (
              <TableRow key={suggestion.id}>
                <TableCell className="max-w-lg whitespace-normal break-words">
                  <div className="flex flex-col gap-2">
                    <p className="font-medium">{suggestion.problem}</p>
                    <p>{suggestion.impact}</p>
                    {suggestion.solution && <p>{suggestion.solution}</p>}
                  </div>
                </TableCell>
                <TableCell>
                  <div className="flex flex-wrap justify-end gap-2">
                    <Button size="sm" variant="outline" disabled={busy}
                      onClick={() => void mutate((signal) => moderateTeamSuggestion(teamId, suggestion.id, false, signal))}>
                      Behold forslag
                    </Button>
                    <AlertDialog>
                      <AlertDialogTrigger asChild><Button size="sm" variant="destructive" disabled={busy}>Fjern forslag</Button></AlertDialogTrigger>
                      <AlertDialogContent>
                        <AlertDialogHeader>
                          <AlertDialogTitle>Fjern det rapporterede forslag?</AlertDialogTitle>
                          <AlertDialogDescription>Forslagets indhold og støtte fjernes. Det kan ikke gendannes.</AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                          <AlertDialogCancel>Annuller</AlertDialogCancel>
                          <AlertDialogAction variant="destructive" disabled={busy}
                            onClick={() => void mutate((signal) => moderateTeamSuggestion(teamId, suggestion.id, true, signal))}>
                            Fjern forslag
                          </AlertDialogAction>
                        </AlertDialogFooter>
                      </AlertDialogContent>
                    </AlertDialog>
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </section>
  )
}
