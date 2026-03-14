'use client'

import { motion } from "framer-motion"
import { problemCards } from "@/components/landing/content"
import { fadeInUp, stagger } from "@/components/landing/motion"
import SurfaceCard from "@/components/ui/SurfaceCard"

function ProblemSection() {
  return (
    <section className="container py-8 sm:py-12">
      <SurfaceCard asChild>
        <motion.div
          className="p-8"
          initial="initial"
          whileInView="animate"
          viewport={{ once: true, margin: "-120px" }}
          variants={stagger}
        >
        <motion.div className="max-w-3xl space-y-4" variants={fadeInUp}>
          <span className="text-sm font-semibold uppercase tracking-[0.24em] text-primary">
            Problemet
          </span>
          <h2 className="text-3xl font-bold text-[#282A47] sm:text-4xl">
            Møder tager tid, men de færreste teams forbedrer dem systematisk
          </h2>
          <p className="text-lg leading-8 text-muted-foreground">
            Når de samme møder vender tilbage uge efter uge, burde kvaliteten
            kunne følges. I praksis kører formatet ofte videre, uden at nogen
            samler signalerne op.
          </p>
        </motion.div>

        <motion.div className="mt-10 grid gap-5 lg:grid-cols-3" variants={stagger}>
          {problemCards.map((card) => {
            const Icon = card.icon

            return (
              <motion.div
                key={card.title}
                className="rounded-[1.75rem] border border-[#DCE3F4] bg-[#F9FBFF]/90 p-6 shadow-[0_20px_60px_-45px_rgba(40,42,71,0.95)]"
                variants={fadeInUp}
              >
                <div className="mb-5 inline-flex rounded-full bg-[#EEF1F5] p-3 text-[#3F4F63]">
                  <Icon className="h-5 w-5" />
                </div>
                <h3 className="text-xl font-semibold text-[#282A47]">
                  {card.title}
                </h3>
                <p className="mt-3 text-base leading-7 text-muted-foreground">
                  {card.description}
                </p>
              </motion.div>
            )
          })}
        </motion.div>
        </motion.div>
      </SurfaceCard>
    </section>
  )
}

export default ProblemSection
