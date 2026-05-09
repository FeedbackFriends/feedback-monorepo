'use client'

import { motion } from "framer-motion"
import { fadeInUp, stagger } from "@/components/landing/motion"

const steps = [
  {
    title: "Planlæg mødet som du plejer",
    description:
      "Du bliver i de værktøjer, du allerede bruger - Google, Outlook, Teams osv.",
    highlight: false,
  },
  {
    title: "Tilføj én deltager",
    description:
      "Invitér feedback@letsgrow.dk, så ved systemet, at mødet skal have feedback bagefter.",
    highlight: true,
  },
  {
    title: "Deltagerne giver feedback",
    description:
      "Efter mødet svarer deltagerne på få, relevante spørgsmål direkte fra mobilen.",
    highlight: false,
  },
  {
    title: "Se hvad der faktisk virker",
    description:
      "Få klare indsigter og følg din udvikling over tid.",
    highlight: false,
  },
]

function HowItWorksSection() {
  return (
    <section
      id="how-it-works"
      className="container scroll-mt-28 py-12 sm:py-16"
    >
      <motion.div
        className="p-0"
        initial="initial"
        whileInView="animate"
        viewport={{ once: true, margin: "-120px" }}
        variants={stagger}
      >
        <motion.div className="mx-auto mb-8 max-w-3xl space-y-4 text-center" variants={fadeInUp}>
          <h2 className="text-3xl font-bold text-[#282A47] sm:text-4xl">
            Fra møde til indsigt - i 4 enkle trin
          </h2>
        </motion.div>

        <motion.div className="grid gap-4 md:grid-cols-2" variants={stagger}>
          {steps.map((step, index) => (
            <motion.div
              key={step.title}
              className={`rounded-3xl bg-white px-5 py-6 ${
                step.highlight
                  ? "border-2 border-[#27AB85]/45 shadow-[0_24px_60px_-42px_rgba(39,171,133,0.75)]"
                  : "border border-[#DCE3F4] shadow-[0_18px_40px_-35px_rgba(40,42,71,0.85)]"
              }`}
              variants={fadeInUp}
            >
              <p className="text-sm font-semibold uppercase tracking-[0.16em] text-[#6A6D88]">
                Trin {index + 1}
              </p>
              <h3 className="mt-3 text-xl font-semibold leading-8 text-[#282A47]">
                {index + 1}. {step.title}
              </h3>
              <p className="mt-3 text-base leading-7 text-muted-foreground">
                {step.description}
              </p>
            </motion.div>
          ))}
        </motion.div>
      </motion.div>
    </section>
  )
}

export default HowItWorksSection
