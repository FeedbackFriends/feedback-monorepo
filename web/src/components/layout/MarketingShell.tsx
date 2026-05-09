import type { ReactNode } from "react"
import { cn } from "@/lib/utils"
import LandingBackground from "@/components/landing/LandingBackground"
import Footer from "@/components/layout/Footer"
import Navbar from "@/components/layout/Navbar"

type MarketingShellProps = {
  children: ReactNode
  contentClassName?: string
  ctaHref?: string
  ctaLabel?: string
}

function MarketingShell({
  children,
  contentClassName,
  ctaHref,
  ctaLabel,
}: MarketingShellProps) {
  return (
    <div className="relative isolate min-h-screen overflow-x-clip bg-background">
      <div className="pointer-events-none absolute inset-0 overflow-hidden">
        <LandingBackground />
      </div>

      <div className={cn("relative", contentClassName)}>
        <Navbar ctaHref={ctaHref} ctaLabel={ctaLabel} />
        <main>{children}</main>
        <Footer />
      </div>
    </div>
  )
}

export default MarketingShell
