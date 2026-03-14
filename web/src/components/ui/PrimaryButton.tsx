import * as React from "react"
import { Button } from "@/components/ui/button"
import { earlyAccessButtonClass } from "@/lib/letsgrow"
import { cn } from "@/lib/utils"

export type PrimaryButtonProps = React.ComponentProps<typeof Button>

const PrimaryButton = React.forwardRef<HTMLButtonElement, PrimaryButtonProps>(
  ({ className, ...props }, ref) => {
    return (
      <Button
        ref={ref}
        className={cn(earlyAccessButtonClass, "rounded-full", className)}
        {...props}
      />
    )
  }
)

PrimaryButton.displayName = "PrimaryButton"

export default PrimaryButton
