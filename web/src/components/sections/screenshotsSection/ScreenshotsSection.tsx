import { motion } from "framer-motion"
import { ArrowRight } from "lucide-react"
import { useState } from "react"
import { Button } from "@/components/ui/button"
import {
  earlyAccessButtonClass,
  earlyAccessLabel,
  earlyAccessUrl,
} from "@/lib/letsgrow"

function ScreenshotsSection() {
  const [imageErrors, setImageErrors] = useState<Set<number>>(new Set())
  const screenshotNumbers = [1, 2, 3, 4, 5, 6]

  const handleImageError = (index: number) => {
    setImageErrors((prev) => new Set(prev).add(index))
  }

  const fadeInUp = {
    initial: { opacity: 0, y: 60 },
    animate: { opacity: 1, y: 0 },
    transition: { duration: 0.8, ease: "easeOut" },
  }

  const stagger = {
    animate: {
      transition: {
        staggerChildren: 0.1,
      },
    },
  }

  const scaleOnHover = {
    initial: { scale: 1 },
    whileHover: {
      scale: 1.02,
      transition: { duration: 0.3, ease: "easeOut" },
    },
    whileTap: { scale: 0.98 },
  }

  const availableScreenshots = screenshotNumbers.filter(
    (num) => !imageErrors.has(num)
  )

  if (availableScreenshots.length === 0) {
    return null
  }

  return (
    <section className="container pt-2 pb-12 sm:pt-4 sm:pb-16">
      <motion.div
        className="space-y-8"
        initial="initial"
        whileInView="animate"
        viewport={{ once: true, margin: "-100px" }}
        variants={stagger}
      >
        <motion.div className="text-center space-y-4" variants={fadeInUp}>
          <span className="text-sm font-semibold uppercase tracking-[0.24em] text-primary">
            Produktet i praksis
          </span>
          <h2 className="bg-gradient-to-b from-[#4A4D69] from-0% via-[#282A47] via-50% to-[#282A47] to-100% bg-clip-text text-3xl font-bold text-transparent sm:text-4xl lg:text-5xl">
            Se hvordan feedbacken bliver en enkel vane efter faste møder
          </h2>
          <p className="mx-auto max-w-2xl text-base text-muted-foreground sm:text-lg">
            Lets Grow er bygget til korte svar og tydelige signaler lige efter
            mødet. Det gør det lettere for deltagerne at give feedback og
            lettere for mødeejeren at følge udviklingen over tid.
          </p>
        </motion.div>

        <motion.div
          className="grid max-w-[1400px] grid-cols-2 gap-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6"
          variants={stagger}
        >
          {availableScreenshots.map((num) => (
            <motion.div
              key={num}
              className="group relative"
              variants={fadeInUp}
              {...scaleOnHover}
            >
              <div className="relative w-full overflow-hidden rounded-xl bg-gradient-to-br from-gray-100 to-gray-200 shadow-md">
                <img
                  src={`/appstore_${num}.jpg`}
                  alt={`Lets Grow skærmbillede ${num}`}
                  className="h-auto w-full object-cover transition-all duration-300 group-hover:brightness-105"
                  onError={() => handleImageError(num)}
                  loading="lazy"
                />

                <div className="absolute inset-0 bg-gradient-to-t from-black/5 to-transparent opacity-0 transition-opacity duration-300 group-hover:opacity-100" />
                <div className="absolute inset-0 rounded-xl ring-1 ring-black/5 ring-inset" />
              </div>

              <div className="absolute inset-0 -z-10 rounded-xl bg-[#27AB85]/20 opacity-0 blur-lg transition-opacity duration-300 group-hover:opacity-30 shadow-xl" />
            </motion.div>
          ))}
        </motion.div>

        <motion.div className="text-center pt-6" variants={fadeInUp}>
          <Button
            asChild
            size="lg"
            className={`${earlyAccessButtonClass} h-12 rounded-full px-6`}
          >
            <a
              href={earlyAccessUrl}
              target="_blank"
              rel="noopener noreferrer"
            >
              {earlyAccessLabel}
              <ArrowRight className="ml-2 h-4 w-4" />
            </a>
          </Button>
        </motion.div>
      </motion.div>
    </section>
  )
}

export default ScreenshotsSection
