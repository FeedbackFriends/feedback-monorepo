'use client'

import { motion } from "framer-motion"
import { fadeInUp, stagger } from "@/components/landing/motion"

const benefits = [
  "Opdag hvad der virker (og hvad der ikke gør)",
  "Få ærlig feedback - ikke bare \"det var godt\"",
  "Følg din udvikling over tid",
  "Skab bedre møder, hver gang",
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
            Se hvad du får ud af det
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
