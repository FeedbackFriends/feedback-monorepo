'use client'

import { motion } from "framer-motion"
import { outcomes } from "@/components/landing/content"
import { fadeInUp, stagger } from "@/components/landing/motion"

function OutcomesSection() {
  return (
    <section className="container py-12 sm:py-16">
      <motion.div
        initial="initial"
        whileInView="animate"
        viewport={{ once: true, margin: "-120px" }}
        variants={stagger}
      >
        <motion.div className="max-w-3xl space-y-4" variants={fadeInUp}>
          <span className="text-sm font-semibold uppercase tracking-[0.24em] text-primary">
            Hvad du får ud af det
          </span>
          <h2 className="text-3xl font-bold text-[#282A47] sm:text-4xl">
            Et klart billede af om jeres møder faktisk bliver bedre
          </h2>
          <p className="text-lg leading-8 text-muted-foreground">
            Vi starter ét sted: at gøre møder lettere at følge op på og lettere
            at forbedre over tid. Det er hverken et HR-værktøj eller en klassisk
            surveyplatform.
          </p>
        </motion.div>

        <motion.div
          className="mt-10 grid gap-5 md:grid-cols-2 xl:grid-cols-4"
          variants={stagger}
        >
          {outcomes.map((outcome) => {
            const Icon = outcome.icon

            return (
              <motion.div
                key={outcome.title}
                className="rounded-[1.75rem] border border-white/70 bg-white/80 p-6 shadow-[0_22px_60px_-45px_rgba(40,42,71,0.95)] backdrop-blur-sm"
                variants={fadeInUp}
              >
                <div className="mb-5 inline-flex rounded-full bg-[#EEF1F5] p-3 text-[#3F4F63]">
                  <Icon className="h-5 w-5" />
                </div>
                <h3 className="text-xl font-semibold text-[#282A47]">
                  {outcome.title}
                </h3>
                <p className="mt-3 text-base leading-7 text-muted-foreground">
                  {outcome.description}
                </p>
              </motion.div>
            )
          })}
        </motion.div>
      </motion.div>
    </section>
  )
}

export default OutcomesSection
