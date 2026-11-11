"use client"

import { useCallback, useId, useRef, useState } from "react"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog"
import { Field, FieldDescription, FieldGroup, FieldLabel } from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { NativeSelect, NativeSelectOption } from "@/components/ui/native-select"
import { Skeleton } from "@/components/ui/skeleton"
import { Textarea } from "@/components/ui/textarea"
import { getSuggestionInbox, publishSuggestionDecision, publishSuggestionTrial, type PublishSuggestionTrialInput, type PublishSuggestionDecisionInput, type SuggestionInbox } from "@/lib/api/teams"
import { TrialEvaluation } from "./TrialEvaluation"
import { useTeamResource } from "./useTeamResource"

type Suggestion = SuggestionInbox["suggestions"][number]
type Decision = Suggestion["decisions"][number]
const statusLabels: Record<Decision["status"], string> = {
  Reviewing: "Under vurdering", Planned: "Planlagt", Deferred: "Udskudt", Declined: "Afvist",
}
const dateLabel = (date: string) => new Intl.DateTimeFormat("da-DK", { dateStyle: "long", timeZone: "UTC" }).format(new Date(`${date}T00:00:00Z`))

export default function TeamSuggestions({ teamId }: { teamId: string }) {
  const [filter, setFilter] = useState("all")
  const load = useCallback((signal: AbortSignal) => getSuggestionInbox(teamId, signal), [teamId])
  const { data, error, busy, refresh, mutate } = useTeamResource(load)
  return (
    <section className="flex flex-col gap-4" aria-labelledby="suggestions-heading" aria-busy={busy}>
      <div className="flex flex-wrap items-center justify-between gap-2">
        <h2 id="suggestions-heading" className="text-lg font-semibold">Forslag og beslutninger</h2>
        <Button variant="outline" disabled={busy} onClick={() => void refresh()}>Opdater forslag</Button>
      </div>
      <p className="text-sm text-muted-foreground">Giv et begrundet svar og en tydelig næste handling. Støtte er input til vurderingen og afgør ikke beslutningen.</p>
      {data && <p className="text-sm">{data.suggestions.filter((item) => item.trials.length > 0 && !item.outcomes.some((outcome) => outcome.trialId === item.trials[0].id)).length} aktive forsøg. Hold få forsøg i gang, så der er tid til opfølgning.</p>}
      <Field>
        <FieldLabel htmlFor="suggestion-filter">Vis forbedringer</FieldLabel>
        <NativeSelect id="suggestion-filter" value={filter} onChange={(event) => setFilter(event.target.value)}>
          <NativeSelectOption value="all">Alle forslag</NativeSelectOption>
          <NativeSelectOption value="unanswered">Afventer svar</NativeSelectOption>
          <NativeSelectOption value="active">Aktive forsøg og opfølgning</NativeSelectOption>
          <NativeSelectOption value="results">Resultater</NativeSelectOption>
        </NativeSelect>
      </Field>
      {error && <Alert variant="destructive"><AlertDescription>{error} Opdater forslag før en ny revision.</AlertDescription></Alert>}
      {!data ? !error && <Skeleton className="h-24 w-full" aria-label="Henter forslag" /> : (
        data.suggestions.length === 0 ? <p>Teamet har ingen forslag endnu.</p> : data.suggestions.filter((suggestion) => {
          if (filter === "unanswered") return suggestion.decisions.length === 0
          if (filter === "results") return suggestion.outcomes.length > 0 || suggestion.decisions[0]?.status === "Declined"
          if (filter === "active") return suggestion.trials.length === 0 ? !!suggestion.decisions[0]?.followUpDate : !suggestion.outcomes.some((outcome) => outcome.trialId === suggestion.trials[0].id && outcome.outcome !== "Adjust")
          return true
        }).map((suggestion) => (
          <Card key={suggestion.id}>
            <CardHeader><CardTitle className="whitespace-pre-wrap break-words">{suggestion.problem}</CardTitle></CardHeader>
            <CardContent className="flex flex-col gap-4">
              <p className="whitespace-pre-wrap break-words">{suggestion.impact}</p>
              {suggestion.solution && <p className="whitespace-pre-wrap break-words">{suggestion.solution}</p>}
              {suggestion.hasFiveSupporters && <p>5+ støtter</p>}
              {suggestion.decisions.length === 0 ? <p>Modtaget — afventer svar.</p> : (
                <ol className="flex flex-col gap-4" aria-label="Beslutningshistorik, nyeste først">
                  {suggestion.decisions.map((decision, index) => (
                    <li key={decision.id} className="flex flex-col gap-1">
                      <h3 className="font-medium">{index === 0 ? "Seneste svar" : "Tidligere svar"}: {statusLabels[decision.status]}</h3>
                      <p className="whitespace-pre-wrap break-words">{decision.explanation}</p>
                      <p>Ansvarlig: {decision.responsibleName}</p>
                      {decision.followUpDate && <p>Opfølgning: {dateLabel(decision.followUpDate)}</p>}
                      <p className="text-sm text-muted-foreground">Offentliggjort {new Intl.DateTimeFormat("da-DK", { dateStyle: "long", timeStyle: "short" }).format(decision.publishedAt)}</p>
                    </li>
                  ))}
                </ol>
              )}
              {suggestion.trials.length > 0 && (
                <div className="flex flex-col gap-3" aria-label="Forsøgshistorik, nyeste først">
                  {suggestion.trials.map((trial, index) => <div key={trial.id} className="flex flex-col gap-1">
                    <h3 className="font-medium">{suggestion.outcomes.some((outcome) => outcome.trialId === trial.id) ? "Afsluttet forsøg" : index === 0 ? "Afprøves" : "Tidligere forsøgsplan"}</h3>
                    <p className="whitespace-pre-wrap break-words">{trial.change}</p>
                    <p className="whitespace-pre-wrap break-words">Formål: {trial.intendedBenefit}</p>
                    <p>Ansvarlig: {trial.responsibleName}</p>
                    {index === 0 && trial.needsReassignment && <p role="status">Vælg en ny ansvarlig. Den tidligere ansvarlige leder ikke længere teamet.</p>}
                    <p>Periode: {dateLabel(trial.startDate)} – {dateLabel(trial.endDate)}</p>
                    <p>Opfølgning: {dateLabel(trial.followUpDate)}{index === 0 && trial.followUpDate < new Intl.DateTimeFormat("sv-SE").format(new Date()) ? " — overskredet" : ""}</p>
                  </div>)}
                </div>
              )}
              {suggestion.decisions[0]?.status === "Planned" && (!suggestion.trials[0] || (!suggestion.evaluations.some((evaluation) => evaluation.trialId === suggestion.trials[0].id) || suggestion.outcomes.some((outcome) => outcome.trialId === suggestion.trials[0].id && outcome.outcome === "Adjust"))) && <TrialForm key={`${suggestion.id}-trial-${suggestion.trials[0]?.revision ?? 0}`}
                suggestion={suggestion} people={data.responsiblePeople} busy={busy} error={error}
                publish={(input) => mutate((signal) => publishSuggestionTrial(teamId, suggestion.id, input, signal))} />}
              <TrialEvaluation teamId={teamId} suggestion={suggestion} busy={busy} error={error} mutate={mutate} />
              {suggestion.trials.length === 0 && <DecisionForm key={`${suggestion.id}-${suggestion.decisions[0]?.revision ?? 0}`} suggestion={suggestion}
                people={data.responsiblePeople} busy={busy} error={error}
                publish={(input) => mutate((signal) => publishSuggestionDecision(teamId, suggestion.id, input, signal))} />}
            </CardContent>
          </Card>
        ))
      )}
    </section>
  )
}

function DecisionForm({ suggestion, people, busy, error, publish }: {
  suggestion: Suggestion
  people: SuggestionInbox["responsiblePeople"]
  busy: boolean
  error: string | null
  publish: (input: PublishSuggestionDecisionInput) => Promise<SuggestionInbox | undefined>
}) {
  const prefix = useId()
  const [open, setOpen] = useState(false)
  const [status, setStatus] = useState<Decision["status"]>(suggestion.decisions[0]?.status ?? "Reviewing")
  const [explanation, setExplanation] = useState("")
  const [responsibleId, setResponsibleId] = useState("")
  const [responsibleName, setResponsibleName] = useState("")
  const [followUpDate, setFollowUpDate] = useState("")
  // A failed request may have committed. Keep the exact receipt for an unchanged retry.
  const receipt = useRef<{ content: string; id: string } | null>(null)
  const submitting = useRef(false)
  const valid = explanation.trim().length > 0 && explanation.trim().length <= 1000 &&
    people.some((person) => person.accountId === responsibleId) && responsibleName.trim().length > 0 &&
    responsibleName.trim().length <= 255 && (status === "Declined" || followUpDate !== "")
  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild><Button variant="outline" disabled={busy}>{suggestion.decisions.length ? "Revider svar" : "Giv svar"}</Button></DialogTrigger>
      <DialogContent className="max-h-[90dvh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{suggestion.decisions.length ? "Revider svar" : "Giv svar"}</DialogTitle>
          <DialogDescription>Svaret bliver synligt for teamet. Tidligere svar bevares. Felter markeret * skal udfyldes.</DialogDescription>
        </DialogHeader>
        <form onSubmit={async (event) => {
          event.preventDefault()
          if (!valid || busy || submitting.current) return
          const content = { expectedRevision: suggestion.decisions[0]?.revision ?? 0, status, explanation: explanation.trim(),
            responsibleId, responsibleName: responsibleName.trim(), followUpDate: followUpDate || undefined }
          const serialized = JSON.stringify(content)
          if (receipt.current?.content !== serialized) receipt.current = { content: serialized, id: crypto.randomUUID() }
          submitting.current = true
          try {
            if (await publish({ ...content, id: receipt.current.id })) setOpen(false)
          } finally { submitting.current = false }
        }}>
          <FieldGroup>
            <Field>
              <FieldLabel htmlFor={`${prefix}-status`}>Beslutning *</FieldLabel>
              <NativeSelect id={`${prefix}-status`} value={status} disabled={busy} onChange={(event) => setStatus(event.target.value as Decision["status"])}>
                {Object.entries(statusLabels).map(([value, label]) => <NativeSelectOption key={value} value={value}>{label}</NativeSelectOption>)}
              </NativeSelect>
            </Field>
            <Field>
              <FieldLabel htmlFor={`${prefix}-explanation`}>Begrundelse og næste skridt *</FieldLabel>
              <Textarea id={`${prefix}-explanation`} required maxLength={1000} value={explanation} disabled={busy} onChange={(event) => setExplanation(event.target.value)} />
            </Field>
            <Field>
              <FieldLabel htmlFor={`${prefix}-person`}>Ansvarlig person *</FieldLabel>
              <NativeSelect id={`${prefix}-person`} required value={responsibleId} disabled={busy} onChange={(event) => {
                setResponsibleId(event.target.value)
                setResponsibleName(people.find((person) => person.accountId === event.target.value)?.name ?? "")
              }}>
                <NativeSelectOption value="">Vælg en leder eller organisationsejer</NativeSelectOption>
                {people.map((person) => <NativeSelectOption key={person.accountId} value={person.accountId}>{person.email ? (person.name ? `${person.name} (${person.email})` : person.email) : (person.name || "Organisationsejer")}</NativeSelectOption>)}
              </NativeSelect>
            </Field>
            <Field>
              <FieldLabel htmlFor={`${prefix}-name`}>Ansvarliges navn til teamet *</FieldLabel>
              <Input id={`${prefix}-name`} required maxLength={255} value={responsibleName} disabled={busy} onChange={(event) => setResponsibleName(event.target.value)} />
              <FieldDescription>Navnet bevares i historikken, også hvis personen forlader teamet. Vælg en nuværende ansvarlig ved hver revision.</FieldDescription>
            </Field>
            <Field>
              <FieldLabel htmlFor={`${prefix}-date`}>Næste opfølgning {status === "Declined" ? "(valgfri)" : "*"}</FieldLabel>
              <Input id={`${prefix}-date`} type="date" required={status !== "Declined"} value={followUpDate} disabled={busy} onChange={(event) => setFollowUpDate(event.target.value)} />
            </Field>
            {error && <Alert variant="destructive"><AlertDescription>{error} Luk og opdater forslag, hvis svaret er ændret af en anden leder.</AlertDescription></Alert>}
            <Button type="submit" disabled={!valid || busy}>{busy ? "Offentliggør…" : "Offentliggør svar"}</Button>
          </FieldGroup>
        </form>
      </DialogContent>
    </Dialog>
  )
}

function TrialForm({ suggestion, people, busy, error, publish }: {
  suggestion: Suggestion
  people: SuggestionInbox["responsiblePeople"]
  busy: boolean
  error: string | null
  publish: (input: PublishSuggestionTrialInput) => Promise<SuggestionInbox | undefined>
}) {
  const prefix = useId()
  const latest = suggestion.trials[0]
  const [open, setOpen] = useState(false)
  const [change, setChange] = useState(latest?.change ?? "")
  const [intendedBenefit, setIntendedBenefit] = useState(latest?.intendedBenefit ?? "")
  const [responsibleId, setResponsibleId] = useState("")
  const [responsibleName, setResponsibleName] = useState("")
  const [startDate, setStartDate] = useState(latest?.startDate ?? "")
  const [endDate, setEndDate] = useState(latest?.endDate ?? "")
  const [followUpDate, setFollowUpDate] = useState(latest?.followUpDate ?? "")
  const receipt = useRef<{ content: string; id: string } | null>(null)
  const submitting = useRef(false)
  const valid = [change, intendedBenefit].every((value) => value.trim().length > 0 && value.trim().length <= 1000) &&
    people.some((person) => person.accountId === responsibleId) && responsibleName.trim().length > 0 && responsibleName.trim().length <= 255 &&
    startDate.length === 10 && endDate.length === 10 && followUpDate.length === 10 && startDate <= endDate && endDate <= followUpDate
  return <Dialog open={open} onOpenChange={setOpen}>
    <DialogTrigger asChild><Button variant="outline" disabled={busy}>{latest ? "Revider forsøg" : "Start forsøg"}</Button></DialogTrigger>
    <DialogContent className="max-h-[90dvh] overflow-y-auto">
      <DialogHeader><DialogTitle>{latest ? "Revider forsøg" : "Start forsøg"}</DialogTitle>
        <DialogDescription>Beskriv en lille ændring, teamet kan afprøve. Planen og dens revisioner bliver synlige for teamet. Alle felter skal udfyldes.</DialogDescription></DialogHeader>
      <form onSubmit={async (event) => {
        event.preventDefault()
        if (!valid || busy || submitting.current) return
        const content = { expectedRevision: latest?.revision ?? 0, expectedDecisionId: suggestion.decisions[0].id,
          change: change.trim(), intendedBenefit: intendedBenefit.trim(), responsibleId, responsibleName: responsibleName.trim(), startDate, endDate, followUpDate }
        const serialized = JSON.stringify(content)
        if (receipt.current?.content !== serialized) receipt.current = { content: serialized, id: crypto.randomUUID() }
        submitting.current = true
        try { if (await publish({ ...content, id: receipt.current.id })) setOpen(false) }
        finally { submitting.current = false }
      }}><FieldGroup>
        <Field><FieldLabel htmlFor={`${prefix}-change`}>Konkret ændring *</FieldLabel>
          <Textarea id={`${prefix}-change`} required maxLength={1000} value={change} disabled={busy} onChange={(event) => setChange(event.target.value)} /></Field>
        <Field><FieldLabel htmlFor={`${prefix}-benefit`}>Hvad skal ændringen hjælpe med? *</FieldLabel>
          <Textarea id={`${prefix}-benefit`} required maxLength={1000} value={intendedBenefit} disabled={busy} onChange={(event) => setIntendedBenefit(event.target.value)} /></Field>
        <Field><FieldLabel htmlFor={`${prefix}-person`}>Ansvarlig person *</FieldLabel>
          <NativeSelect id={`${prefix}-person`} required value={responsibleId} disabled={busy} onChange={(event) => {
            setResponsibleId(event.target.value)
            setResponsibleName(people.find((person) => person.accountId === event.target.value)?.name ?? "")
          }}><NativeSelectOption value="">Vælg en leder eller organisationsejer</NativeSelectOption>
            {people.map((person) => <NativeSelectOption key={person.accountId} value={person.accountId}>{person.email ? (person.name ? `${person.name} (${person.email})` : person.email) : (person.name || "Organisationsejer")}</NativeSelectOption>)}
          </NativeSelect></Field>
        <Field><FieldLabel htmlFor={`${prefix}-name`}>Ansvarliges navn til teamet *</FieldLabel>
          <Input id={`${prefix}-name`} required maxLength={255} value={responsibleName} disabled={busy} onChange={(event) => setResponsibleName(event.target.value)} />
          <FieldDescription>Navnet bevares efter afgang. Vælg en nuværende ansvarlig ved hver revision.</FieldDescription></Field>
        {([
          ["start", "Startdato *", startDate, setStartDate], ["end", "Slutdato *", endDate, setEndDate],
          ["follow", "Opfølgningsdato *", followUpDate, setFollowUpDate],
        ] as const).map(([key, label, value, setValue]) => <Field key={key}><FieldLabel htmlFor={`${prefix}-${key}`}>{label}</FieldLabel>
          <Input id={`${prefix}-${key}`} type="date" required value={value} disabled={busy} onChange={(event) => setValue(event.target.value)} /></Field>)}
        <FieldDescription>Slutdatoen skal være på eller efter startdatoen. Opfølgningen skal være på eller efter slutdatoen.</FieldDescription>
        {error && <Alert variant="destructive"><AlertDescription>{error} Luk og opdater forslag før en ny revision.</AlertDescription></Alert>}
        <Button type="submit" disabled={!valid || busy}>{busy ? "Offentliggør…" : "Offentliggør forsøg"}</Button>
      </FieldGroup></form>
    </DialogContent>
  </Dialog>
}
