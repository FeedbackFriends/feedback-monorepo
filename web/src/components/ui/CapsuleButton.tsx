import * as React from "react"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"

type CapsuleButtonProps = React.ComponentProps<typeof Button>

const CapsuleButton = React.forwardRef<HTMLButtonElement, CapsuleButtonProps>(
  ({ className, ...props }, ref) => {
    return <Button ref={ref} className={cn("rounded-full", className)} {...props} />
  }
)

CapsuleButton.displayName = "CapsuleButton"

export default CapsuleButton
