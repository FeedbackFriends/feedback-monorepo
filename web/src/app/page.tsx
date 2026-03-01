import MarketingShell from "@/components/layout/MarketingShell"
import HomePageClient from "@/components/pages/HomePageClient"

export default function HomePage() {
  return (
    <MarketingShell contentClassName="pb-28 sm:pb-0">
      <HomePageClient />
    </MarketingShell>
  )
}
