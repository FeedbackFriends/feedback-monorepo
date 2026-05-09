'use client'

import { ArrowRight } from "lucide-react"
import PrimaryButton from "@/components/ui/PrimaryButton"

type MobileStickyCtaProps = {
  ctaHref: string
  visible: boolean
}

function MobileStickyCta({ ctaHref, visible }: MobileStickyCtaProps) {
  return (
    <div
      className={`mobile-cta-safe fixed inset-x-0 bottom-0 z-40 border-t border-white/70 bg-white/88 backdrop-blur-xl transition-transform duration-300 sm:hidden ${
        visible ? "translate-y-0" : "pointer-events-none translate-y-full"
      }`}
    >
      <div className="container py-3">
        <div className="flex items-center gap-3 rounded-3xl border border-[#DCE3F4] bg-white/90 p-3 shadow-[0_18px_40px_-30px_rgba(40,42,71,0.5)]">
          <div className="min-w-0 flex-1">
            <p className="text-sm font-semibold text-[#282A47]">Klar til at prøve?</p>
            <p className="text-xs leading-5 text-muted-foreground">
              Giv dit næste møde feedback - uden ekstra arbejde.
            </p>
          </div>

          <PrimaryButton asChild className="h-11 shrink-0 px-5 text-sm" size="sm">
            <a href={ctaHref} target="_blank" rel="noopener noreferrer">
              Hent appen
              <ArrowRight className="ml-1.5 h-4 w-4" />
            </a>
          </PrimaryButton>
        </div>
      </div>
    </div>
  )
}

export default MobileStickyCta
