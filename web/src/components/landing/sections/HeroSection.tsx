'use client'

import { motion } from "framer-motion"
import type { MouseEventHandler, Ref } from "react"
import Image from "next/image"
import PhoneFrames from "@/components/landing/PhoneFrames"
import { appStoreUrl, calendarPlatforms } from "@/components/landing/content"
import { fadeInUp, stagger } from "@/components/landing/motion"
import PrimaryButton from "@/components/ui/PrimaryButton"
import SecondaryButton from "@/components/ui/SecondaryButton"
import { navbarSurfaceShadowClass } from "@/lib/letsgrow"

type HeroSectionProps = {
  heroSectionRef: Ref<HTMLElement>
  onHowItWorksClick: MouseEventHandler<HTMLAnchorElement>
}

function HeroSection({
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
            <div className="relative isolate max-w-3xl">
              <div
                aria-hidden="true"
                className="hero-heading-glow pointer-events-none absolute -inset-x-8 -inset-y-6 -z-10 rounded-full blur-2xl"
              />
              <h1 className="pb-1 text-4xl font-bold leading-[1.14] tracking-tight sm:text-5xl sm:leading-[1.1] lg:text-6xl">
                <span className="block text-hero-heading">
                  Bliv klogere på
                </span>
                <span className="mt-2 block text-hero-heading">
                  hvad der{" "}
                  <span className="relative inline-block">
                    virker
                    <svg
                      aria-hidden="true"
                      viewBox="0 0 144 14"
                      preserveAspectRatio="none"
                      className="absolute -bottom-1 left-0 right-0 -z-10 h-3 w-full text-primary"
                    >
                      <path
                        d="M3 9.2C24 6.8 38 9.7 56 7.4C78 4.7 96 7.1 113 6.4C126 5.9 135 6.8 141 5.9"
                        fill="none"
                        stroke="currentColor"
                        strokeLinecap="round"
                        strokeWidth="5"
                        opacity="1"
                      />
                    </svg>
                  </span>
                </span>
              </h1>
            </div>

            <p className="max-w-2xl text-lg leading-8 text-muted-foreground sm:text-xl">
                Få ærlig feedback efter møder, workshops, oplæg og andre aktiviteter, så du kan se mønstre, justere undervejs og blive bedre til det, der gør en forskel.
            </p>
          </motion.div>

          <motion.div
            className="flex flex-col gap-4 sm:flex-row sm:items-center"
            variants={fadeInUp}
          >
            <PrimaryButton asChild className="h-12 px-6" size="lg">
              <a href={appStoreUrl} target="_blank" rel="noopener noreferrer">
                Hent på App Store
              </a>
            </PrimaryButton>
            <SecondaryButton
              asChild
              size="lg"
              className={`h-12 border-[#DCE3F4] bg-transparent px-6 ${navbarSurfaceShadowClass} hover:bg-transparent active:bg-transparent`}
            >
              <a href="#how-it-works" onClick={onHowItWorksClick}>
                Se hvordan det virker
              </a>
            </SecondaryButton>
          </motion.div>

          <motion.div
            className="rounded-3xl border border-gray-200/80 bg-white/55 px-4 py-4 shadow-[0_18px_50px_-40px_rgba(40,42,71,0.7)] backdrop-blur-sm sm:max-w-136"
            variants={fadeInUp}
          >
            <p className="text-xs font-medium uppercase tracking-[0.22em] text-[#6A6D88]">
              Integreret med disse kalenderværktøjer
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
        </motion.div>
      </div>
    </section>
  )
}

export default HeroSection
