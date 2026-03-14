'use client'

import EarlyAccessButton from "@/components/ui/EarlyAccessButton"

type MobileStickyCtaProps = {
  earlyAccessUrl: string
  visible: boolean
}

function MobileStickyCta({ earlyAccessUrl, visible }: MobileStickyCtaProps) {
  return (
    <div
      className={`mobile-cta-safe fixed inset-x-0 bottom-0 z-40 border-t border-white/70 bg-white/88 backdrop-blur-xl transition-transform duration-300 sm:hidden ${
        visible ? "translate-y-0" : "pointer-events-none translate-y-full"
      }`}
    >
      <div className="container py-3">
        <div className="flex items-center gap-3 rounded-[1.5rem] border border-[#DCE3F4] bg-white/90 p-3 shadow-[0_18px_40px_-30px_rgba(40,42,71,0.5)]">
          <div className="min-w-0 flex-1">
            <p className="text-sm font-semibold text-[#282A47]">
              Test Lets Grow gratis
            </p>
            <p className="text-xs leading-5 text-muted-foreground">
              Få tidlig adgang og vær blandt de første teams.
            </p>
          </div>

          <EarlyAccessButton
            className="h-11 shrink-0 px-5 text-sm"
            href={earlyAccessUrl}
          />
        </div>
      </div>
    </div>
  )
}

export default MobileStickyCta
