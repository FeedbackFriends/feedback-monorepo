'use client'

import { motion } from "framer-motion"
import type { MouseEventHandler } from "react"
import { ArrowRight } from "lucide-react"
import { fadeInUp, stagger } from "@/components/landing/motion"
import EarlyAccessButton from "@/components/ui/EarlyAccessButton"
import SecondaryButton from "@/components/ui/SecondaryButton"

type EarlyAccessSectionProps = {
  earlyAccessUrl: string
  onHowItWorksClick: MouseEventHandler<HTMLAnchorElement>
}

function EarlyAccessSection({
  earlyAccessUrl,
  onHowItWorksClick,
}: EarlyAccessSectionProps) {
  return (
    <section className="container pb-16 pt-6 sm:pb-24">
      <motion.div
        className="rounded-[2rem] border border-[#27AB85]/45 bg-gradient-to-b from-[#26A783] to-[#28AE88] p-8 text-white shadow-[0_35px_90px_-55px_rgba(39,171,133,0.62)] sm:p-10"
        initial="initial"
        whileInView="animate"
        viewport={{ once: true, margin: "-120px" }}
        variants={stagger}
      >
        <motion.div className="max-w-3xl space-y-5" variants={fadeInUp}>
          <span className="text-sm font-semibold uppercase tracking-[0.24em] text-white/70">
            Tidlig adgang
          </span>
          <h2 className="text-3xl font-bold sm:text-4xl">
            Vil I prøve Lets Grow?
          </h2>
          <p className="text-lg leading-8 text-white/80">
            Du kan prøve Let&apos;s Grow helt gratis og teste det i praksis. Hvis
            du har lyst til at være blandt de første brugere og give feedback
            undervejs, så vil vi meget gerne have dig med. Målet er at gøre
            tilbagevendende møder mere målbare uden tung opsætning.
          </p>
        </motion.div>

        <motion.div
          className="mt-8 flex flex-col gap-4 sm:flex-row sm:items-center"
          variants={fadeInUp}
        >
          <EarlyAccessButton className="h-12 px-6" href={earlyAccessUrl} size="lg" />
          <SecondaryButton
            asChild
            className="h-12 px-5 text-sm font-semibold"
            tone="inverse"
          >
            <a href="#how-it-works" onClick={onHowItWorksClick}>
              Se workflowet igen
              <ArrowRight className="ml-2 h-4 w-4" />
            </a>
          </SecondaryButton>
        </motion.div>

        <motion.p
          className="mt-4 text-sm leading-6 text-white/75"
          variants={fadeInUp}
        >
          Ingen offentlig pris endnu. Vi starter med udvalgte teams og et enkelt
          setup omkring jeres tilbagevendende møder.
        </motion.p>
      </motion.div>
    </section>
  )
}

export default EarlyAccessSection
