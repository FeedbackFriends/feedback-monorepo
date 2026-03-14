import MarketingShell from "@/components/layout/MarketingShell"
import LandingPage from "@/components/landing/LandingPage"
import { readEarlyAccessUrlFromEnv } from "@/lib/letsgrow-server"

export const dynamic = "force-dynamic"

export default function HomePage() {
  const earlyAccessUrl = readEarlyAccessUrlFromEnv()

  return (
    <MarketingShell
      contentClassName="pb-28 sm:pb-0"
      earlyAccessUrl={earlyAccessUrl}
    >
      <LandingPage earlyAccessUrl={earlyAccessUrl} />
    </MarketingShell>
  )
}
