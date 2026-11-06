'use client'

import { ArrowRight } from "lucide-react"
import { motion } from "framer-motion"
import { contactUrl } from "@/components/landing/content"
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
            Vær med fra starten
          </h2>
          <p className="text-lg leading-8 text-muted-foreground">
            Den nye Lets Grow er under udvikling. Vil I være med til at
            gøre medarbejdernes idéer til en bedre arbejdsdag? Skriv til os
            på hello@letsgrow.dk om tidlig adgang.
          </p>
        </motion.div>

        <motion.div
          className="mt-8 flex flex-col items-center gap-4"
          variants={fadeInUp}
        >
          <PrimaryButton asChild className="h-12 px-7 text-sm font-semibold" size="lg">
            <a href={contactUrl} target="_blank" rel="noopener noreferrer">
              Få tidlig adgang
              <ArrowRight className="ml-2 h-4 w-4" />
            </a>
          </PrimaryButton>
        </motion.div>
      </motion.div>
    </section>
  )
}

export default AppStoreCtaSection
