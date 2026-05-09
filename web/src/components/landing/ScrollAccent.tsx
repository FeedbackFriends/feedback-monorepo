"use client"

import { motion, useScroll, useTransform } from "framer-motion"
import { useRef } from "react"
import { cn } from "@/lib/utils"

type ScrollAccentProps = {
  className?: string
  glowClassName?: string
  drift?: number
}

function ScrollAccent({
  className,
  glowClassName,
  drift = 96,
}: ScrollAccentProps) {
  const ref = useRef<HTMLDivElement>(null)

  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "end start"],
  })

  const y = useTransform(scrollYProgress, [0, 0.5, 1], [drift, 0, -drift])
  const opacity = useTransform(
    scrollYProgress,
    [0, 0.2, 0.8, 1],
    [0, 0.72, 0.72, 0]
  )
  const scale = useTransform(scrollYProgress, [0, 0.5, 1], [0.9, 1, 1.06])

  return (
    <div
      ref={ref}
      aria-hidden="true"
      className={cn(
        "pointer-events-none absolute inset-0 overflow-hidden",
        className
      )}
    >
      <motion.div
        className={cn("absolute rounded-full blur-3xl", glowClassName)}
        style={{ opacity, scale, y }}
      />
    </div>
  )
}

export default ScrollAccent
