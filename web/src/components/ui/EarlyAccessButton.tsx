import { ArrowRight } from "lucide-react"
import PrimaryButton, { type PrimaryButtonProps } from "@/components/ui/PrimaryButton"
import { earlyAccessLabel } from "@/lib/letsgrow"

export type EarlyAccessButtonProps = Readonly<{
  className?: string
  href: string
  showIcon?: boolean
}> &
  Pick<PrimaryButtonProps, "size">

function EarlyAccessButton({
  className,
  href,
  showIcon = true,
  size = "default",
}: EarlyAccessButtonProps) {
  return (
    <PrimaryButton
      asChild
      className={className}
      size={size}
    >
      <a href={href} target="_blank" rel="noopener noreferrer">
        {earlyAccessLabel}
        {showIcon ? <ArrowRight className="ml-2 h-4 w-4" /> : null}
      </a>
    </PrimaryButton>
  )
}

export default EarlyAccessButton
