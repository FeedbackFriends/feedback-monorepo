import type { Metadata } from "next"
import DashboardScreen from "@/components/auth/DashboardScreen"

export const metadata: Metadata = {
  title: "Dashboard | Lets Grow",
  description: "Protected Lets Grow dashboard for authenticated users.",
}

export default function DashboardPage() {
  return <DashboardScreen />
}
