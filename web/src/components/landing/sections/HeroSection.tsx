'use client'

import { motion } from "framer-motion"
import { Lightbulb, HeartHandshake, MessageCircle, Target, TrendingUp, Users } from "lucide-react"
import PhoneFrames from "@/components/landing/PhoneFrames"
import { getStartedUrl } from "@/components/landing/content"
import { fadeInUp, stagger } from "@/components/landing/motion"
import PrimaryButton from "@/components/ui/PrimaryButton"
import SecondaryButton from "@/components/ui/SecondaryButton"
import { navbarSurfaceShadowClass } from "@/lib/letsgrow"

function HeroSection() {
  return (
    <section
      id="hero"
      className="container flex min-h-screen items-center pb-12 pt-28 sm:py-16"
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
                  Gør arbejdsdagen
                </span>
                <span className="mt-2 block text-hero-heading">
                  lidt{" "}
                  <span className="relative inline-block">
                    bedre
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
                Snart kan medarbejdere foreslå forbedringer anonymt, støtte hinandens idéer og følge med i, hvad der bliver gjort. Lets Grow – fra feedback til forbedring.
            </p>
          </motion.div>

          <motion.div
            className="flex flex-col gap-4 sm:flex-row sm:items-center"
            variants={fadeInUp}
          >
            <PrimaryButton asChild className="h-12 px-6" size="lg">
              <a href={getStartedUrl} target="_blank" rel="noopener noreferrer">
                Kom i gang
              </a>
            </PrimaryButton>
            <SecondaryButton
              asChild
              size="lg"
              className={`h-12 border-[#DCE3F4] bg-transparent px-6 ${navbarSurfaceShadowClass} hover:bg-transparent active:bg-transparent`}
            >
              <a href="#how-it-works">
                Se hvad der kommer
              </a>
            </SecondaryButton>
          </motion.div>

          <motion.div
            className="rounded-3xl border border-gray-200/80 bg-white/55 px-4 py-4 shadow-[0_18px_50px_-40px_rgba(40,42,71,0.7)] backdrop-blur-sm sm:max-w-136"
            variants={fadeInUp}
          >
            <p className="text-xs font-medium uppercase tracking-[0.22em] text-[#6A6D88]">
              En bedre arbejdsdag begynder med teamet
            </p>
            <div className="mt-4 flex flex-wrap items-start gap-x-4 gap-y-3 sm:gap-x-5">
              {[
                { name: "Idéer", Icon: Lightbulb },
                { name: "Opbakning", Icon: HeartHandshake },
                { name: "Dialog", Icon: MessageCircle },
                { name: "Handling", Icon: Target },
                { name: "Udvikling", Icon: TrendingUp },
                { name: "Trivsel", Icon: Users },
              ].map(({ name, Icon }) => (
                <div key={name} className="group flex w-14 flex-col items-center gap-1 opacity-80 transition-all duration-300 hover:-translate-y-0.5 hover:opacity-100 sm:w-16" title={name}>
                  <div className="relative flex h-10 w-10 items-center justify-center sm:h-11 sm:w-11">
                    <Icon aria-hidden="true" className="h-7 w-7 text-primary" />
                  </div>
                  <span className="text-center text-[11px] font-medium leading-3 text-[#5B5F7B] sm:text-xs">{name}</span>
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
