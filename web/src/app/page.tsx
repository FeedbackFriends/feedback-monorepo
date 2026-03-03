import MarketingShell from "@/components/layout/MarketingShell"
import LandingPage from "@/components/landing/LandingPage"

export default function HomePage() {
  return (
    <MarketingShell contentClassName="pb-28 sm:pb-0">
      <LandingPage />
    </MarketingShell>
  )
}
