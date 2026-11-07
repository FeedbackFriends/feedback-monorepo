"use client"

import { useState } from "react"
import type { TeamInfo } from "@/lib/api/teams"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
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

type TeamInviteDialogProps = {
  team: TeamInfo
  inviteCode: string
  busy: boolean
  error: string | null
  open: boolean
  onOpenChange: (open: boolean) => void
  onRotate: () => Promise<void>
  onError: (message: string) => void
}

export default function TeamInviteDialog({
  team,
  inviteCode,
  busy,
  error,
  open,
  onOpenChange,
  onRotate,
  onError,
}: TeamInviteDialogProps) {
  const [copied, setCopied] = useState(false)
  const invite = `${typeof window === "undefined" ? "" : window.location.origin}/team-invite/${inviteCode}`
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogTrigger asChild>
        <Button>Invitér medarbejdere</Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle asChild>
            <h2>Invitér til {team.name}</h2>
          </DialogTitle>
          <DialogDescription>
            Del linket med medarbejderne. De åbner det i iOS-appen og anmoder om
            adgang. Du godkender hver person her.
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
                  onError(
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
                    Det gamle link kan derefter ikke bruges til nye anmodninger.
                    Eksisterende anmodninger og medlemmer bevares.
                  </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                  <AlertDialogCancel>Annuller</AlertDialogCancel>
                  <AlertDialogAction
                    onClick={() => {
                      setCopied(false)
                      void onRotate()
                    }}
                  >
                    Opret nyt link
                  </AlertDialogAction>
                </AlertDialogFooter>
              </AlertDialogContent>
            </AlertDialog>
          </div>
          {copied && (
            <p role="status" className="text-sm text-muted-foreground">
              Link kopieret
            </p>
          )}
        </div>
      </DialogContent>
    </Dialog>
  )
}
