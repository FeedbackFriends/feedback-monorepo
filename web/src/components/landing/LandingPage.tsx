'use client'

import { type MouseEvent, useEffect, useRef, useState } from "react"
import { appStoreUrl } from "@/components/landing/content"
import AppStoreCtaSection from "@/components/landing/sections/AppStoreCtaSection"
import HeroSection from "@/components/landing/sections/HeroSection"
import HowItWorksSection from "@/components/landing/sections/HowItWorksSection"
import MobileStickyCta from "@/components/landing/sections/MobileStickyCta"
import OutcomesSection from "@/components/landing/sections/OutcomesSection"
import ProblemSection from "@/components/landing/sections/ProblemSection"

function LandingPage() {
  const [showMobileStickyCta, setShowMobileStickyCta] = useState(false)
  const heroSectionRef = useRef<HTMLElement | null>(null)

  useEffect(() => {
    const heroSection = heroSectionRef.current
    if (!heroSection) {
      return
    }

    const observer = new IntersectionObserver(
      ([entry]) => {
        setShowMobileStickyCta(!entry.isIntersecting)
      },
      {
        threshold: 0.2,
      }
    )

    observer.observe(heroSection)

    return () => {
      observer.disconnect()
    }
  }, [])

  const scrollToSection = (
    event: MouseEvent<HTMLAnchorElement>,
    targetId: string
  ) => {
    event.preventDefault()

    const target = document.getElementById(targetId)
    if (!target) {
      return
    }

    const prefersReducedMotion = window.matchMedia(
      "(prefers-reduced-motion: reduce)"
    ).matches

    const startY = window.scrollY
    const targetY = target.getBoundingClientRect().top + window.scrollY - 24

    if (prefersReducedMotion) {
      window.scrollTo(0, targetY)
      window.history.replaceState(null, "", `#${targetId}`)
      return
    }

    const duration = 850
    const startTime = performance.now()

    const easeInOutCubic = (progress: number) =>
      progress < 0.5
        ? 4 * progress * progress * progress
        : 1 - Math.pow(-2 * progress + 2, 3) / 2

    const animateScroll = (currentTime: number) => {
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / duration, 1)
      const easedProgress = easeInOutCubic(progress)
      const nextY = startY + (targetY - startY) * easedProgress

      window.scrollTo(0, nextY)

      if (progress < 1) {
        window.requestAnimationFrame(animateScroll)
        return
      }

      window.history.replaceState(null, "", `#${targetId}`)
    }

    window.requestAnimationFrame(animateScroll)
  }

  const handleHowItWorksClick = (event: MouseEvent<HTMLAnchorElement>) => {
    scrollToSection(event, "how-it-works")
  }

  return (
      <>
          <HeroSection
              heroSectionRef={heroSectionRef}
              onHowItWorksClick={handleHowItWorksClick}
          />
          <ProblemSection />
          <HowItWorksSection />
          <OutcomesSection />
          <AppStoreCtaSection />
          <MobileStickyCta ctaHref={appStoreUrl} visible={showMobileStickyCta} />
      </>
  )
}

export default LandingPage
