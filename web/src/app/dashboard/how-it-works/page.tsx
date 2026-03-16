import type { Metadata } from "next"
import DashboardHowItWorksView from "@/components/auth/DashboardHowItWorksView"

export const metadata: Metadata = {
  title: "Sådan Virker Det | Dashboard | Lets Grow",
  description: "Et overblik over hvordan Lets Grow kobler sig på møder, indsamler feedback og skaber læring over tid.",
}

export default function DashboardHowItWorksPage() {
  return <DashboardHowItWorksView />
}
