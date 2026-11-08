"use client"

import Link from "next/link"
import { useRouter } from "next/navigation"
import { useRef, useState, type FormEvent } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Alert, AlertDescription } from "@/components/ui/alert"
import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
} from "@/components/ui/card"
import {
  Table,
  TableHeader,
  TableHead,
  TableBody,
  TableRow,
  TableCell,
} from "@/components/ui/table"
import { Skeleton } from "@/components/ui/skeleton"
import {
  Dialog,
  DialogTrigger,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog"
import { useTeamResource } from "./useTeamResource"
import {
  getTeamContext,
  getPendingLeaderInvitations,
  createOrganization as createOrganizationAPI,
  createTeam,
  type OrganizationInput,
  type TeamInput,
} from "@/lib/api/teams"

async function loadDashboard(signal: AbortSignal) {
  const [context, invitations] = await Promise.all([getTeamContext(signal), getPendingLeaderInvitations(signal)])
  return { ...context, invitations }
}

export default function DashboardScreen() {
  const router = useRouter()
  const {
    data: context,
    error,
    busy,
    loading,
    refresh,
    mutate,
    setError,
  } = useTeamResource(loadDashboard)
  const [createOpen, setCreateOpen] = useState(false)
  const [ownerName, setOwnerName] = useState("")
  const [organizationName, setOrganizationName] = useState("")
  const [teamName, setTeamName] = useState("")
  const organizationDraft = useRef<OrganizationInput | null>(null)
  const teamDraft = useRef<TeamInput | null>(null)
  async function createOrganization(event: FormEvent) {
    event.preventDefault()
    organizationDraft.current = {
      id: organizationDraft.current?.id ?? crypto.randomUUID(),
      name: organizationName.trim(),
      ownerName: ownerName.trim(),
      teamId: organizationDraft.current?.teamId ?? crypto.randomUUID(),
      teamName: teamName.trim(),
    }
    const input = organizationDraft.current
    const next = await mutate(async (signal) => ({ ...await createOrganizationAPI(input, signal), invitations: [] }))
    if (next) router.push(`/dashboard/teams/${input.teamId}`)
  }
  async function addTeam(event: FormEvent) {
    event.preventDefault()
    if (!context?.organization) return
    teamDraft.current = {
      id: teamDraft.current?.id ?? crypto.randomUUID(),
      name: teamName.trim(),
    }
    const input = teamDraft.current
    const organizationId = context.organization.id
    const next = await mutate(async (signal) => {
      const team = await createTeam(organizationId, input, signal)
      return { ...context, managedTeams: [...context.managedTeams, team] }
    })
    if (next) {
      setCreateOpen(false)
      router.push(`/dashboard/teams/${input.id}`)
    }
  }
  const errorAlert = error && (
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
  )
  return (
    <div className="space-y-6">
      <div className="space-y-1">
        <h1 className="text-2xl font-semibold tracking-tight">
          {context?.organization ? "Teams" : "Velkommen til Lets Grow"}
        </h1>
        <p className="text-sm text-muted-foreground">
          {context?.organization?.name ??
            "Opret jeres organisation og første team for at komme i gang."}
        </p>
      </div>
      {!createOpen && errorAlert}
      {loading ? (
        <div role="status" aria-label="Henter dine teams">
          <Skeleton className="h-32 w-full" />
        </div>
      ) : !context ? null : context.invitations.length > 0 ? (
        <Card>
          <CardHeader><CardTitle>Du er inviteret som teamleder</CardTitle><CardDescription>Vælg invitationen for at se og acceptere din adgang.</CardDescription></CardHeader>
          <CardContent className="flex flex-col gap-3">
            {context.invitations.map(invitation => <Button key={invitation.code} variant="outline" asChild>
              <Link href={`/leader-invite/${invitation.code}`}>{invitation.team.organizationName} · {invitation.team.name}</Link>
            </Button>)}
          </CardContent>
        </Card>
      ) : !context.organization ? (
        context.membership || context.request?.status === "Pending" ? (
          <Alert>
            <AlertDescription>
              Din konto er tilknyttet et team som medarbejder. Brug iOS-appen
              til at deltage.
            </AlertDescription>
          </Alert>
        ) : (
          <Card className="max-w-xl">
            <CardHeader>
              <CardTitle>
                <h2>Opret organisation og første team</h2>
              </CardTitle>
              <CardDescription>
                Start med virksomhedens navn og det første team.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={createOrganization} className="space-y-5">
                <div className="space-y-2">
                  <Label htmlFor="owner-name">Dit navn</Label>
                  <Input id="owner-name" autoComplete="name" required maxLength={100} value={ownerName}
                    onChange={event => setOwnerName(event.target.value)} disabled={busy} />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="organization-name">Organisation</Label>
                  <Input
                    id="organization-name"
                    required
                    maxLength={100}
                    value={organizationName}
                    onChange={(e) => setOrganizationName(e.target.value)}
                    disabled={busy}
                    placeholder="Virksomhedens navn"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="first-team-name">Teamnavn</Label>
                  <Input
                    id="first-team-name"
                    required
                    maxLength={100}
                    value={teamName}
                    onChange={(e) => setTeamName(e.target.value)}
                    disabled={busy}
                    placeholder="Fx IT"
                  />
                </div>
                <Button
                  disabled={
                    busy || !ownerName.trim() || !organizationName.trim() || !teamName.trim()
                  }
                >
                  {busy ? "Opretter…" : "Opret organisation og team"}
                </Button>
              </form>
            </CardContent>
          </Card>
        )
      ) : (
        <>
          <div className="flex flex-wrap items-center justify-between gap-4">
            <p className="text-sm text-muted-foreground">
              Vælg et team for at se medlemmer og invitere medarbejdere.
            </p>
            {context.isOwner && (
              <Dialog
                open={createOpen}
                onOpenChange={(open) => {
                  if (!busy) {
                    setCreateOpen(open)
                    setError(null)
                  }
                }}
              >
                <DialogTrigger asChild>
                  <Button>Opret team</Button>
                </DialogTrigger>
                <DialogContent>
                  <DialogHeader>
                    <DialogTitle>Opret team</DialogTitle>
                    <DialogDescription>
                      Giv teamet et navn, fx IT, Marketing eller Produkt.
                    </DialogDescription>
                  </DialogHeader>
                  <form onSubmit={addTeam} className="space-y-4">
                    {errorAlert}
                    <div className="space-y-2">
                      <Label htmlFor="new-team-name">Teamnavn</Label>
                      <Input
                        id="new-team-name"
                        required
                        maxLength={100}
                        value={teamName}
                        onChange={(e) => setTeamName(e.target.value)}
                        disabled={busy}
                        placeholder="Fx Marketing"
                      />
                    </div>
                    <Button disabled={busy || !teamName.trim()}>
                      {busy ? "Opretter…" : "Opret team"}
                    </Button>
                  </form>
                </DialogContent>
              </Dialog>
            )}
          </div>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Team</TableHead>
                <TableHead className="text-right">
                  <span className="sr-only">Handling</span>
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {context.managedTeams.map((team) => (
                <TableRow key={team.id}>
                  <TableCell className="font-medium whitespace-normal break-words">
                    {team.name}
                  </TableCell>
                  <TableCell className="text-right">
                    <Button asChild variant="ghost">
                      <Link
                        href={`/dashboard/teams/${team.id}`}
                        aria-label={`Åbn ${team.name}`}
                      >
                        Åbn team →
                      </Link>
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </>
      )}
    </div>
  )
}
