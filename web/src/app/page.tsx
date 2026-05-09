import MarketingShell from "@/components/layout/MarketingShell"
import LandingPage from "@/components/landing/LandingPage"
import { appStoreUrl } from "@/components/landing/content"

export const dynamic = "force-dynamic"

export default function HomePage() {
  return (
    <MarketingShell
      contentClassName="pb-28 sm:pb-0"
      ctaHref={appStoreUrl}
      ctaLabel="Hent appen"
    >
      <LandingPage />
    </MarketingShell>
  )
}
