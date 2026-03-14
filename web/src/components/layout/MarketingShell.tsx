import type { ReactNode } from "react"
import { cn } from "@/lib/utils"
import Background from "@/components/layout/Background"
import Footer from "@/components/layout/Footer"
import Navbar from "@/components/layout/Navbar"

type MarketingShellProps = {
  children: ReactNode
  contentClassName?: string
  earlyAccessUrl: string
}

function MarketingShell({
  children,
  contentClassName,
  earlyAccessUrl,
}: MarketingShellProps) {
  return (
    <div className="relative min-h-screen bg-background">
      <div className="pointer-events-none absolute inset-0 overflow-hidden">
        <Background />
      </div>

      <div className={cn("relative", contentClassName)}>
        <Navbar earlyAccessUrl={earlyAccessUrl} />
        <main>{children}</main>
        <Footer />
      </div>
    </div>
  )
}

export default MarketingShell
