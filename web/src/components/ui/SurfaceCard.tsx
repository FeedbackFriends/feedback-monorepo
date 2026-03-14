import type { HTMLAttributes } from "react"
import { Slot } from "@radix-ui/react-slot"
import { cn } from "@/lib/utils"

type SurfaceCardProps = HTMLAttributes<HTMLDivElement> & {
  asChild?: boolean
}

function SurfaceCard({
  asChild = false,
  className,
  ...props
}: SurfaceCardProps) {
  const Comp = asChild ? Slot : "div"

  return (
    <Comp
      className={cn(
        "rounded-[2rem] border border-white/70 bg-white/65 shadow-[0_30px_90px_-60px_rgba(40,42,71,0.8)] backdrop-blur",
        className
      )}
      {...props}
    />
  )
}

export default SurfaceCard
