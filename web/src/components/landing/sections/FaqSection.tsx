'use client'

import { motion } from "framer-motion"
import { ChevronDown } from "lucide-react"
import { faqItems } from "@/components/landing/content"
import { fadeInUp, stagger } from "@/components/landing/motion"

type FaqSectionProps = {
  openFaqIndex: number | null
  onToggleFaq: (index: number) => void
}

function FaqSection({ openFaqIndex, onToggleFaq }: FaqSectionProps) {
  return (
    <section className="container py-12 sm:py-16">
      <motion.div
        className="py-2"
        initial="initial"
        whileInView="animate"
        viewport={{ once: true, margin: "-120px" }}
        variants={stagger}
      >
        <motion.div
          className="mx-auto max-w-3xl space-y-4 text-center"
          variants={fadeInUp}
        >
          <span className="text-sm font-semibold uppercase tracking-[0.24em] text-primary">
            Spørgsmål
          </span>
          <h2 className="text-3xl font-bold text-[#282A47] sm:text-4xl">
            Det spørger folk typisk om
          </h2>
        </motion.div>

        <motion.div
          className="mx-auto mt-10 max-w-4xl overflow-hidden rounded-[1.75rem] border border-[#DCE3F4] bg-white/85 shadow-[0_24px_70px_-50px_rgba(40,42,71,0.9)] backdrop-blur"
          variants={stagger}
        >
          {faqItems.map((item, index) => (
            <motion.div
              key={item.question}
              className={`border-b border-[#DCE3F4] last:border-b-0 ${
                openFaqIndex === index
                  ? "bg-gradient-to-r from-[#F8FAFF] via-white to-[#F4F8FF]"
                  : "bg-white/80"
              }`}
              transition={{ duration: 0.28, ease: "easeOut" }}
            >
              <button
                type="button"
                className="flex w-full items-center justify-between gap-6 px-6 py-6 text-left transition-colors hover:bg-[#F8FAFF]/70 sm:px-7"
                aria-expanded={openFaqIndex === index}
                onClick={() => onToggleFaq(index)}
              >
                <span className="pr-2 text-lg font-semibold text-[#282A47] sm:text-[1.15rem]">
                  {item.question}
                </span>
                <motion.span
                  animate={{ rotate: openFaqIndex === index ? 180 : 0 }}
                  transition={{
                    type: "spring",
                    stiffness: 320,
                    damping: 24,
                  }}
                  className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-[#EEF1F5] text-[#4A4D69]"
                >
                  <ChevronDown className="h-5 w-5" />
                </motion.span>
              </button>
              <div
                className={`grid overflow-hidden transition-[grid-template-rows,opacity] duration-300 ease-out ${
                  openFaqIndex === index
                    ? "grid-rows-[1fr] opacity-100"
                    : "grid-rows-[0fr] opacity-70"
                }`}
              >
                <div className="min-h-0 overflow-hidden">
                  <p
                    className={`px-6 pb-6 pr-16 text-base leading-7 text-muted-foreground transition-transform duration-300 ease-out sm:px-7 ${
                      openFaqIndex === index ? "translate-y-0" : "-translate-y-2"
                    }`}
                  >
                    {item.answer}
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

export default FaqSection
