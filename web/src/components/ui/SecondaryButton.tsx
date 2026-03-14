import * as React from "react"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"

export type SecondaryButtonProps = React.ComponentProps<typeof Button> & {
  tone?: "default" | "inverse"
}

const SecondaryButton = React.forwardRef<HTMLButtonElement, SecondaryButtonProps>(
  ({ className, tone = "default", ...props }, ref) => {
    return (
      <Button
        ref={ref}
        className={cn(
          "rounded-full",
          tone === "default"
            ? "border-[#DCE3F4] bg-white/80 text-[#282A47] shadow-sm hover:bg-white"
            : "border-white/20 bg-white/10 text-white/90 hover:bg-white/16 hover:text-white",
          className
        )}
        variant="outline"
        {...props}
      />
    )
  }
)

SecondaryButton.displayName = "SecondaryButton"

export default SecondaryButton
