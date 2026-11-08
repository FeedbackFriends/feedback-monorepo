import type { Metadata } from "next"
import MarketingShell from "@/components/layout/MarketingShell"
import LandingPage from "@/components/landing/LandingPage"
import { getStartedUrl } from "@/components/landing/content"

export const metadata: Metadata = {
  alternates: { canonical: "https://letsgrow.dk/" },
}

export default function HomePage() {
  return (
    <MarketingShell
      contentClassName="pb-28 sm:pb-0"
      ctaHref={getStartedUrl}
      ctaLabel="Kom i gang"
    >
      <LandingPage />
    </MarketingShell>
  )
}
