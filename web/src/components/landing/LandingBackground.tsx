import ScrollAccent from "@/components/landing/ScrollAccent"
import { cn } from "@/lib/utils"

type LandingBackgroundProps = {
  className?: string
}

function LandingBackground({ className }: LandingBackgroundProps) {
  return (
    <div className={cn("absolute inset-0", className)}>
      <div
        aria-hidden="true"
        className="pointer-events-none absolute inset-x-0 top-0 h-[88rem]"
      >
        <div className="absolute left-[-8rem] top-20 h-72 w-72 rounded-full bg-primary/24 blur-3xl md:h-96 md:w-96" />
        <div className="absolute right-[-10rem] top-12 h-[24rem] w-[24rem] rounded-full bg-sky-300/30 blur-3xl md:h-[32rem] md:w-[32rem]" />
        <div className="absolute left-1/2 top-[28rem] h-[18rem] w-[18rem] -translate-x-1/2 rounded-full bg-amber-200/36 blur-3xl md:h-[24rem] md:w-[24rem]" />
        <div className="absolute inset-x-0 top-0 h-[34rem] bg-[radial-gradient(circle_at_top,_rgba(255,255,255,0.3),_transparent_68%)]" />
      </div>

      <ScrollAccent
        glowClassName="left-[-7rem] top-24 h-72 w-72 bg-sky-200/60"
        drift={128}
      />
      <ScrollAccent
        glowClassName="right-[-8rem] bottom-10 h-80 w-80 bg-primary/14"
        drift={88}
      />
      <ScrollAccent
        glowClassName="left-[-5rem] top-28 h-64 w-64 bg-primary/12"
        drift={84}
      />
      <ScrollAccent
        glowClassName="right-[-7rem] bottom-16 h-80 w-80 bg-sky-200/55"
        drift={120}
      />
      <ScrollAccent
        glowClassName="left-[-6rem] top-20 h-72 w-72 bg-sky-200/45"
        drift={108}
      />
      <ScrollAccent
        glowClassName="right-[-5rem] bottom-0 h-72 w-72 bg-primary/12"
        drift={78}
      />
    </div>
  )
}

export default LandingBackground
