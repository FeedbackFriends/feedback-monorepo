import { getStartedUrl } from "@/components/landing/content"
import AppStoreCtaSection from "@/components/landing/sections/AppStoreCtaSection"
import HeroSection from "@/components/landing/sections/HeroSection"
import HowItWorksSection from "@/components/landing/sections/HowItWorksSection"
import MobileStickyCta from "@/components/landing/sections/MobileStickyCta"
import OutcomesSection from "@/components/landing/sections/OutcomesSection"
import ProblemSection from "@/components/landing/sections/ProblemSection"

export default function LandingPage() {
  return (
    <>
      <HeroSection />
      <ProblemSection />
      <HowItWorksSection />
      <OutcomesSection />
      <AppStoreCtaSection />
      <MobileStickyCta ctaHref={getStartedUrl} />
    </>
  )
}
