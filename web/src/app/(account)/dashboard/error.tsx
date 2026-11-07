"use client"

import { Button } from "@/components/ui/button"
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"

export default function DashboardError({ retry }: { retry: () => void }) {
  return (
    <Alert variant="destructive">
      <AlertTitle>Siden kunne ikke vises</AlertTitle>
      <AlertDescription className="space-y-3">
        <p>Prøv at hente siden igen. Dine gemte ændringer bliver bevaret.</p>
        <Button variant="outline" onClick={retry}>
          Prøv igen
        </Button>
      </AlertDescription>
    </Alert>
  )
}
