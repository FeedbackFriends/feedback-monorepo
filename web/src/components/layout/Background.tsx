import { cn } from "@/lib/utils"

interface BackgroundProps {
  className?: string
}

function Background({ className }: BackgroundProps) {
  return (
    <div className={cn("absolute inset-0", className)}>
      <div className="marketing-background-base absolute inset-0" />
      <div className="absolute -top-52 -left-48 h-[36rem] w-[42rem] rounded-[48%_52%_55%_45%/46%_44%_56%_54%] bg-marketing-bg-sky/70 blur-[120px]" />
      <div className="absolute -right-48 top-8 h-[34rem] w-[38rem] rounded-[58%_42%_48%_52%/44%_58%_42%_56%] bg-marketing-bg-mint/70 blur-[130px]" />
      <div className="absolute left-[18vw] top-[45rem] h-[28rem] w-[34rem] rounded-[44%_56%_50%_50%/58%_46%_54%_42%] bg-marketing-bg-gold/42 blur-[140px]" />
      <div className="absolute right-[8vw] top-[42rem] h-[30rem] w-[34rem] rounded-[54%_46%_58%_42%/45%_55%_47%_53%] bg-marketing-bg-lilac/50 blur-[140px]" />
      <div className="absolute -left-36 top-[72rem] h-[28rem] w-[32rem] rounded-[46%_54%_42%_58%/52%_48%_58%_42%] bg-marketing-bg-coral/44 blur-[150px]" />
      <div className="absolute inset-0 bg-linear-to-b from-white/[0.18] via-white/[0.48] to-white/[0.9]" />
    </div>
  )
}

export default Background
