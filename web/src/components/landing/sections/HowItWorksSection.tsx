'use client'

import { motion } from "framer-motion"
import { workflowSteps } from "@/components/landing/content"
import { fadeInUp, stagger } from "@/components/landing/motion"

function HowItWorksSection() {
  return (
    <section id="how-it-works" className="container py-12 sm:py-16">
      <motion.div
        className="rounded-[2rem] border border-[#DCE3F4] bg-gradient-to-br from-white via-[#F8FAFF] to-[#EEF4FF] p-6 shadow-[0_28px_80px_-55px_rgba(40,42,71,0.95)] sm:p-8 lg:p-10"
        initial="initial"
        whileInView="animate"
        viewport={{ once: true, margin: "-120px" }}
        variants={stagger}
      >
        <motion.div className="mb-6 space-y-4" variants={fadeInUp}>
          <span className="text-sm font-semibold uppercase tracking-[0.24em] text-primary">
            Sådan virker det
          </span>
          <h2 className="text-3xl font-bold text-[#282A47] sm:text-4xl">
            Fra møde til indsigt og handling i fire enkle trin
          </h2>
          <p className="max-w-3xl text-lg leading-8 text-muted-foreground">
            Ingen tung opsætning og ingen lange spørgeskemaer. Bare en enkel
            feedbackvane, hvor mødeholderen kan tilpasse spørgsmålene, se
            svarene og bruge dem til at forbedre næste møde.
          </p>
        </motion.div>

        <motion.div className="grid gap-4 md:grid-cols-2" variants={stagger}>
          {workflowSteps.map((step, index) => (
            <motion.div
              key={step.title}
              className="rounded-[1.5rem] border border-[#DCE3F4] bg-white px-5 py-5 shadow-[0_18px_40px_-35px_rgba(40,42,71,0.85)]"
              variants={fadeInUp}
            >
              <div className="flex items-start gap-4">
                <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-[#EEF1F5] text-lg font-semibold text-[#282A47]">
                  {index + 1}
                </div>
                <div className="min-w-0">
                  <h3 className="text-lg font-semibold text-[#282A47]">
                    {step.title}
                  </h3>
                  <p className="mt-3 text-base leading-7 text-muted-foreground">
                    {step.description}
                  </p>
                </div>
              </div>
            </motion.div>
          ))}
        </motion.div>
      </motion.div>
    </section>
  )
}

export default HowItWorksSection
