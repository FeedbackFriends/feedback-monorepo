'use client'

import { ArrowRight } from "lucide-react"
import { motion } from "framer-motion"
import { appStoreUrl } from "@/components/landing/content"
import { fadeInUp, stagger } from "@/components/landing/motion"
import PrimaryButton from "@/components/ui/PrimaryButton"

function AppStoreCtaSection() {
  return (
    <section id="app-store" className="container scroll-mt-28 pb-16 pt-6 sm:pb-24">
      <motion.div
        className="mx-auto max-w-4xl overflow-hidden rounded-[2rem] border border-[#27AB85]/22 bg-linear-to-br from-[#effbf6]/96 via-[#f8fcfa]/94 to-white px-6 py-10 text-center text-[#282A47] shadow-[0_30px_90px_-64px_rgba(39,171,133,0.8)] backdrop-blur-sm sm:px-10 sm:py-12"
        initial="initial"
        whileInView="animate"
        viewport={{ once: true, margin: "-120px" }}
        variants={stagger}
      >
        <motion.div className="mx-auto max-w-2xl space-y-5" variants={fadeInUp}>
          <h2 className="text-3xl font-bold leading-tight sm:text-4xl">
            Prøv det helt gratis
          </h2>
          <p className="text-lg leading-8 text-muted-foreground">
            Få ærlig feedback efter møder, workshops og oplæg, så du kan se
            mønstre, justere undervejs og blive bedre til det, der faktisk gør
            en forskel.
          </p>
        </motion.div>

        <motion.div
          className="mt-8 flex flex-col items-center gap-4"
          variants={fadeInUp}
        >
          <PrimaryButton asChild className="h-12 px-7 text-sm font-semibold" size="lg">
            <a href={appStoreUrl} target="_blank" rel="noopener noreferrer">
              Hent på App Store
              <ArrowRight className="ml-2 h-4 w-4" />
            </a>
          </PrimaryButton>
        </motion.div>
      </motion.div>
    </section>
  )
}

export default AppStoreCtaSection
