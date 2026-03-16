import type { Metadata } from "next"
import DashboardScreen from "@/components/auth/DashboardScreen"

export const metadata: Metadata = {
  title: "Profil | Dashboard | Lets Grow",
  description: "Profil og kontooverblik for autentificerede Lets Grow-brugere.",
}

export default function DashboardPage() {
  return <DashboardScreen />
}
