import { motion, useReducedMotion } from "framer-motion"
import Image from "next/image"

function PhoneFrames() {
  const shouldReduceMotion = useReducedMotion()

  return (
    <motion.div
      className="relative"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.8, delay: 0.2 }}
    >
      <motion.div
        className="relative mx-auto w-full max-w-[900px] will-change-transform"
        data-hero-phone-motion
        animate={
          shouldReduceMotion
            ? { rotate: 0, scale: 1, y: 0 }
            : {
                rotate: [0, -0.12, 0.08, 0],
                y: [0, -3, 1, 0],
              }
        }
        transition={
          shouldReduceMotion
            ? { duration: 0 }
            : {
                duration: 14,
                ease: "easeInOut",
                repeat: Infinity,
                repeatDelay: 1.2,
              }
        }
      >
        <Image
          src="/hero_image.png"
          alt="Let's Grow App Interface"
          width={2946}
          height={2231}
          preload
          sizes="(min-width: 1024px) 45vw, 100vw"
          className="h-auto w-full"
        />
      </motion.div>
    </motion.div>
  )
}

export default PhoneFrames
