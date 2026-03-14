import type { Variants } from "framer-motion"

export const fadeInUp: Variants = {
  initial: { opacity: 0, y: 24 },
  animate: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.7, ease: "easeOut" },
  },
}

export const stagger: Variants = {
  animate: {
    transition: {
      staggerChildren: 0.12,
    },
  },
}
