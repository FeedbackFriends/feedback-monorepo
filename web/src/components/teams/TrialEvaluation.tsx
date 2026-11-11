"use client"

import { useId, useRef, useState } from "react"
import { Button } from "@/components/ui/button"
import { Field, FieldGroup, FieldLabel, FieldDescription } from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { NativeSelect, NativeSelectOption } from "@/components/ui/native-select"
import { Textarea } from "@/components/ui/textarea"
import { openSuggestionEvaluation, publishSuggestionOutcome, type SuggestionInbox } from "@/lib/api/teams"

type Suggestion = SuggestionInbox["suggestions"][number]
const summaries = {
  Improved: "Samlet peger evalueringen på en forbedring.",
  Mixed: "Evalueringen giver ikke en entydig retning.",
  NotImproved: "Samlet peger evalueringen på en forværring.",
  InsufficientResponses: "Resultatet vises ikke af hensyn til anonymiteten. Der kræves mindst fem svar.",
}
const outcomes = { Continue: "Fortsæt", Adjust: "Juster", Stop: "Stop" }

export function TrialEvaluation({ teamId, suggestion, busy, error, mutate }: {
  teamId: string; suggestion: Suggestion; busy: boolean; error: string | null
  mutate: (operation: (signal: AbortSignal) => Promise<SuggestionInbox>) => Promise<SuggestionInbox | undefined>
}) {
  const prefix = useId()
  const [deadline, setDeadline] = useState("")
  const [outcome, setOutcome] = useState<"Continue" | "Adjust" | "Stop">("Continue")
  const [explanation, setExplanation] = useState("")
  const receipt = useRef<{ content: string; id: string } | null>(null)
  const submitting = useRef(false)
  const trial = suggestion.trials[0]
  const evaluation = suggestion.evaluations.find((item) => item.trialId === trial?.id)
  const published = suggestion.outcomes.find((item) => item.trialId === trial?.id)
  const deadlineMs = new Date(deadline).getTime()
  const valid = evaluation ? evaluation.closed && explanation.trim().length > 0 && explanation.trim().length <= 1000 :
    Number.isFinite(deadlineMs) && deadlineMs > Date.now()
  return <div className="flex flex-col gap-3">
    {suggestion.evaluations.map((item) => <div key={item.id} className="flex flex-col gap-1">
      <h3 className="font-medium">Evaluering</h3>
      <p>Forsøg: {suggestion.trials.find((plan) => plan.id === item.trialId)?.change}</p>
      <p>Svarfrist: {new Intl.DateTimeFormat("da-DK", { dateStyle: "long", timeStyle: "short" }).format(item.closesAt)}</p>
      <p>{item.summary ? summaries[item.summary] : item.closed ? "Lukket. Offentliggør resultatet for at dele den samlede vurdering." : "Åben for svar. Resultatet vises efter fristen."}</p>
    </div>)}
    {suggestion.outcomes.map((item) => <div key={item.id} className="flex flex-col gap-1">
      <h3 className="font-medium">Resultat: {outcomes[item.outcome]}</h3>
      <p>Forsøg: {suggestion.trials.find((plan) => plan.id === item.trialId)?.change}</p>
      <p className="whitespace-pre-wrap break-words">{item.explanation}</p>
      {item.outcome === "Adjust" && item.trialId === trial?.id && <p>Start det justerede forsøg med en ny plan.</p>}
    </div>)}
    {trial && !published && (!evaluation || evaluation.closed) && <form onSubmit={async (event) => {
      event.preventDefault()
      if (!valid || busy || submitting.current) return
      const content = evaluation ? { trialId: trial.id, outcome, explanation: explanation.trim() } : { trialId: trial.id, closesAt: deadlineMs }
      const serialized = JSON.stringify(content)
      if (receipt.current?.content !== serialized) receipt.current = { content: serialized, id: crypto.randomUUID() }
      const id = receipt.current.id
      submitting.current = true
      try {
        if (evaluation) await mutate((signal) => publishSuggestionOutcome(teamId, suggestion.id, { id, trialId: trial.id, outcome, explanation: explanation.trim() }, signal))
        else await mutate((signal) => openSuggestionEvaluation(teamId, suggestion.id, { id, trialId: trial.id, closesAt: deadlineMs }, signal))
      } finally { submitting.current = false }
    }}><FieldGroup>
      {evaluation ? <>
        <Field><FieldLabel htmlFor={`${prefix}-outcome`}>Beslutning efter forsøget *</FieldLabel>
          <NativeSelect id={`${prefix}-outcome`} value={outcome} disabled={busy} onChange={(event) => setOutcome(event.target.value as typeof outcome)}>
            {Object.entries(outcomes).map(([value, label]) => <NativeSelectOption key={value} value={value}>{label}</NativeSelectOption>)}
          </NativeSelect></Field>
        <Field><FieldLabel htmlFor={`${prefix}-reason`}>Begrundelse *</FieldLabel>
          <Textarea id={`${prefix}-reason`} required maxLength={1000} value={explanation} disabled={busy} onChange={(event) => setExplanation(event.target.value)} />
          <FieldDescription>Resultatet bliver synligt for teamet, også når evalueringen ikke kan vises. Juster kræver en efterfølgende forsøgsplan.</FieldDescription></Field>
      </> : <Field><FieldLabel htmlFor={`${prefix}-deadline`}>Svarfrist for evaluering *</FieldLabel>
        <Input id={`${prefix}-deadline`} type="datetime-local" required value={deadline} disabled={busy} onChange={(event) => setDeadline(event.target.value)} />
        <FieldDescription>Teamets nuværende medarbejdere kan svare og redigere indtil fristen. Ingen kan se løbende deltagelse eller individuelle svar.</FieldDescription></Field>}
      {error && <p role="alert">{error}</p>}
      <Button type="submit" disabled={!valid || busy}>{evaluation ? "Offentliggør resultat" : "Åbn evaluering"}</Button>
    </FieldGroup></form>}
  </div>
}
