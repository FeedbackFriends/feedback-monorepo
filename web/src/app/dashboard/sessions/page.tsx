import type { Metadata } from "next"
import DashboardSessionsView from "@/components/auth/DashboardSessionsView"

export const metadata: Metadata = {
  title: "Sessions | Dashboard | Lets Grow",
  description: "Overblik over sessions, kladder og næste handlinger.",
}

export default function DashboardSessionsPage() {
  return <DashboardSessionsView />
}
