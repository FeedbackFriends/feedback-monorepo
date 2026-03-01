import { HTMLAttributes } from "react"
import { Card, CardContent } from "./card"
import { cn } from "@/lib/utils"

interface GlassCardProps extends HTMLAttributes<HTMLDivElement> {
  contentClassName?: string
}

function GlassCard({ className, contentClassName, children, ...props }: GlassCardProps) {
  return (
    <Card
      className={cn(
        "relative overflow-hidden border border-gray-200/20 bg-white/5 backdrop-blur-lg",
        className
      )}
      {...props}
    >
      <CardContent className={cn("relative z-10", contentClassName)}>
        {children}
      </CardContent>
      <div className="absolute inset-0 bg-gradient-to-br from-white/10 to-white/5" />
    </Card>
  )
}

export { GlassCard } 
