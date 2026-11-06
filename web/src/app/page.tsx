import MarketingShell from "@/components/layout/MarketingShell"
import LandingPage from "@/components/landing/LandingPage"
import { contactUrl } from "@/components/landing/content"

export const dynamic = "force-dynamic"

export default function HomePage() {
  return (
    <MarketingShell
      contentClassName="pb-28 sm:pb-0"
      ctaHref={contactUrl}
      ctaLabel="Få tidlig adgang"
    >
      <LandingPage />
    </MarketingShell>
  )
}
