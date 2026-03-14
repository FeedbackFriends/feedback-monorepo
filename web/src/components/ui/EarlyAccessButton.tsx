import { ArrowRight } from "lucide-react"
import CapsuleButton from "@/components/ui/CapsuleButton"
import { earlyAccessButtonClass, earlyAccessLabel } from "@/lib/letsgrow"
import { cn } from "@/lib/utils"

type EarlyAccessButtonProps = Readonly<{
  className?: string
  href: string
  showIcon?: boolean
  size?: "default" | "sm" | "lg" | "icon"
}>

function EarlyAccessButton({
  className,
  href,
  showIcon = true,
  size = "default",
}: EarlyAccessButtonProps) {
  return (
    <CapsuleButton
      asChild
      className={cn(earlyAccessButtonClass, className)}
      size={size}
    >
      <a href={href} target="_blank" rel="noopener noreferrer">
        {earlyAccessLabel}
        {showIcon ? <ArrowRight className="ml-2 h-4 w-4" /> : null}
      </a>
    </CapsuleButton>
  )
}

export default EarlyAccessButton
