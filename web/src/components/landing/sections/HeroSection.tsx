'use client'

import { motion } from "framer-motion"
import type { MouseEventHandler, Ref } from "react"
import { ArrowRight } from "lucide-react"
import Image from "next/image"
import PhoneFrames from "@/components/landing/PhoneFrames"
import { appStoreUrl, calendarPlatforms } from "@/components/landing/content"
import { fadeInUp, stagger } from "@/components/landing/motion"
import EarlyAccessButton from "@/components/ui/EarlyAccessButton"
import SecondaryButton from "@/components/ui/SecondaryButton"

type HeroSectionProps = {
  earlyAccessUrl: string
  heroSectionRef: Ref<HTMLElement>
  onHowItWorksClick: MouseEventHandler<HTMLAnchorElement>
}

function HeroSection({
  earlyAccessUrl,
  heroSectionRef,
  onHowItWorksClick,
}: HeroSectionProps) {
  return (
    <section
      ref={heroSectionRef}
      className="container flex min-h-screen items-center py-12 sm:py-16"
    >
      <div className="grid w-full items-center gap-12 lg:grid-cols-[1.05fr_0.95fr]">
        <motion.div
          className="space-y-8"
          initial="initial"
          animate="animate"
          variants={stagger}
        >
          <motion.div className="space-y-7" variants={fadeInUp}>
            <h1 className="max-w-3xl bg-linear-to-b from-[#4A4D69] via-[#282A47] to-[#1F2140] bg-clip-text pb-1 text-4xl font-bold leading-[1.08] text-transparent sm:text-5xl lg:text-6xl">
                Få feedback – hver gang I samler folk
            </h1>
            <p className="max-w-2xl text-lg leading-8 text-muted-foreground sm:text-xl">
                Få enkel feedback efter møder, workshops og oplæg – og se hvad der virker over tid.
            </p>
          </motion.div>

          <motion.div
            className="flex flex-col gap-4 sm:flex-row sm:items-center"
            variants={fadeInUp}
          >
            <EarlyAccessButton className="h-12 px-6" href={earlyAccessUrl} size="lg" />
            <SecondaryButton
              asChild
              size="lg"
              className="h-12 px-6"
            >
              <a href="#how-it-works" onClick={onHowItWorksClick}>
                Se hvordan det virker
                <ArrowRight className="ml-2 h-4 w-4" />
              </a>
            </SecondaryButton>
          </motion.div>

          <motion.div
            className="rounded-3xl border border-white/70 bg-white/55 px-4 py-4 shadow-[0_18px_50px_-40px_rgba(40,42,71,0.7)] backdrop-blur-sm sm:max-w-136"
            variants={fadeInUp}
          >
            <p className="text-xs font-medium uppercase tracking-[0.22em] text-[#6A6D88]">
              Fungerer med de værktøjer, I allerede bruger
            </p>
            <div className="mt-4 flex flex-wrap items-start gap-x-4 gap-y-3 sm:gap-x-5">
              {calendarPlatforms.map((platform) => (
                <div
                  key={platform.name}
                  className="group flex w-14 flex-col items-center gap-1 opacity-80 transition-all duration-300 hover:-translate-y-0.5 hover:opacity-100 sm:w-16"
                  title={platform.name}
                >
                  <div className="relative flex h-10 w-10 items-center justify-center sm:h-11 sm:w-11">
                    <Image
                      src={platform.icon}
                      alt={platform.name}
                      fill
                      sizes="(min-width: 640px) 44px, 40px"
                      className="max-h-8 max-w-8 object-contain sm:max-h-9 sm:max-w-9"
                    />
                  </div>
                  <span className="text-center text-[11px] font-medium leading-3 text-[#5B5F7B] sm:text-xs">
                    {platform.name
                      .replace("Microsoft ", "")
                      .replace(" Calendar", "")}
                  </span>
                </div>
              ))}
            </div>
          </motion.div>
        </motion.div>

        <motion.div
          className="relative space-y-4"
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.15 }}
        >
          <PhoneFrames />
          <div className="flex justify-center">
            <a
              href={appStoreUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="relative block h-14 w-45"
            >
              <Image
                src="/appstore.png"
                alt="Download on the App Store"
                fill
                sizes="180px"
                className="object-contain transition-opacity duration-200 hover:opacity-85"
              />
            </a>
          </div>
        </motion.div>
      </div>
    </section>
  )
}

export default HeroSection
