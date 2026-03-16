import type { Metadata } from "next"
import DashboardPlaceholderView from "@/components/auth/DashboardPlaceholderView"

export const metadata: Metadata = {
  title: "Spørgeskemaer | Dashboard | Lets Grow",
  description: "Administrer de korte spørgeskemaer, som bruges efter møder i Lets Grow.",
}

export default function DashboardSurveysPage() {
  return (
    <DashboardPlaceholderView
      description="Spørgeskemaer har nu deres egen rute i dashboardet. Siden kan senere kobles til templates, spørgsmålsopsætninger og mødespecifikke flows."
      eyebrow="Spørgeskemaer"
      highlights={[
        "Gem genbrugelige templates med 2-3 spørgsmål til faste møder.",
        "Knyt det rigtige spørgeskema til den rigtige mødetype.",
        "Hold deltageroplevelsen kort og ensartet.",
      ]}
      title="Her kan spørgeskema-templates kobles på næste gang"
    />
  )
}
