import type { Metadata } from "next"
import DashboardScreen from "@/components/teams/DashboardScreen"

export const metadata: Metadata = {
  title: "Teams | Lets Grow",
  description: "Opret teams, invitér medarbejdere og administrer medlemskab.",
}

export default function DashboardPage() {
  return <DashboardScreen />
}
