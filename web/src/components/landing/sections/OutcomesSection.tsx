'use client'

import { motion } from "framer-motion"
import { fadeInUp, stagger } from "@/components/landing/motion"

const benefits = [
  "Giv medarbejdernes idéer en tydelig vej frem",
  "Se hvilke forbedringer teamet bakker op om",
  "Gør beslutninger og næste skridt synlige",
  "Følg op på, om ændringerne faktisk hjælper",
]

function OutcomesSection() {
  return (
    <section id="outcomes" className="container scroll-mt-28 py-12 sm:py-16">
      <motion.div
        className="p-0"
        initial="initial"
        whileInView="animate"
        viewport={{ once: true, margin: "-120px" }}
        variants={stagger}
      >
        <motion.div className="mx-auto max-w-3xl space-y-4 text-center" variants={fadeInUp}>
          <h2 className="text-3xl font-bold text-[#282A47] sm:text-4xl">
            Færre målinger. Flere synlige forbedringer.
          </h2>
        </motion.div>

        <motion.div className="mt-8 grid gap-4 md:grid-cols-2 xl:grid-cols-4" variants={stagger}>
          {benefits.map((benefit) => (
            <motion.div
              key={benefit}
              className="border-l-2 border-[#D7DFEC] pl-4"
              variants={fadeInUp}
            >
              <p className="text-base font-medium leading-7 text-[#282A47]">
                {benefit}
              </p>
            </motion.div>
          ))}
        </motion.div>
      </motion.div>
    </section>
  )
}

export default OutcomesSection
