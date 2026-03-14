'use client'

import { motion } from "framer-motion"
import { wedgeReasons } from "@/components/landing/content"
import { fadeInUp, stagger } from "@/components/landing/motion"

function WhyStartHereSection() {
  return (
    <section className="container py-8 sm:py-12">
      <motion.div
        className="rounded-[2rem] border border-white/70 bg-white/70 p-8 shadow-[0_30px_90px_-60px_rgba(40,42,71,0.8)] backdrop-blur"
        initial="initial"
        whileInView="animate"
        viewport={{ once: true, margin: "-120px" }}
        variants={stagger}
      >
        <motion.div className="max-w-3xl space-y-4" variants={fadeInUp}>
          <span className="text-sm font-semibold uppercase tracking-[0.24em] text-primary">
            Hvorfor starte her?
          </span>
          <h2 className="text-3xl font-bold text-[#282A47] sm:text-4xl">
            Det, der går igen, er lettere at forbedre
          </h2>
          <p className="text-lg leading-8 text-muted-foreground">
            Et engangsmøde giver en enkelt mening. Når noget sker igen, opstår
            der et mønster. Derfor starter Lets Grow her: det giver de bedste
            betingelser for at måle kvalitet og følge udviklingen over tid.
          </p>
        </motion.div>

        <motion.div
          className="mt-8 grid gap-4 sm:grid-cols-2 xl:grid-cols-3"
          variants={stagger}
        >
          {wedgeReasons.map((reason) => {
            const Icon = reason.icon

            return (
              <motion.div
                key={reason.title}
                className="rounded-[1.5rem] border border-[#DCE3F4] bg-gradient-to-b from-white to-[#F7FAFF] px-5 py-6 shadow-[0_18px_50px_-40px_rgba(40,42,71,0.9)]"
                variants={fadeInUp}
                whileHover={{ y: -4, scale: 1.01 }}
                transition={{ duration: 0.2, ease: "easeOut" }}
              >
                <div className="inline-flex rounded-full bg-[#EEF1F5] p-3 text-[#3F4F63]">
                  <Icon className="h-5 w-5" />
                </div>
                <h3 className="mt-4 text-lg font-semibold text-[#282A47]">
                  {reason.title}
                </h3>
                <p className="mt-3 text-base leading-7 text-muted-foreground">
                  {reason.description}
                </p>
              </motion.div>
            )
          })}
        </motion.div>
      </motion.div>
    </section>
  )
}

export default WhyStartHereSection
