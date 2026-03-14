import { motion } from "framer-motion"
import Image from "next/image"

function PhoneFrames() {
  return (
    <motion.div
      className="relative"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.8, delay: 0.2 }}
    >
      <motion.div
        className="relative mx-auto w-full max-w-[900px]"
        animate={{
          y: [0, -3, 0],
        }}
        transition={{
          duration: 4,
          repeat: 1,
          ease: "easeInOut",
        }}
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
