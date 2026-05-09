'use client'

import { useEffect, useState } from "react"
import Image from "next/image"
import { motion } from "framer-motion"
import { fadeInUp, stagger } from "@/components/landing/motion"

const problemImages = [
  {
    src: "/problem.png",
    alt: "Kollegaer i gruppemøde, hvor stemningen virker god",
  },
  {
    src: "/problem2.png",
    alt: "Samtale ved et mødebord med en rolig, fokuseret stemning",
  },
  {
    src: "/problem3.png",
    alt: "Person der holder et papir med et neutralt udtryk foran ansigtet",
  },
  {
    src: "/problem4.png",
    alt: "Publikum der klapper og ser engageret ud under en præsentation",
  },
]

function ProblemSection() {
  const [activeImageIndex, setActiveImageIndex] = useState(0)

  useEffect(() => {
    const interval = window.setInterval(() => {
      setActiveImageIndex((currentIndex) => (currentIndex + 1) % problemImages.length)
    }, 6000)

    return () => window.clearInterval(interval)
  }, [])

  return (
    <section id="problem" className="scroll-mt-28 py-10 sm:py-14">
      <motion.div
        className="container"
        initial="initial"
        whileInView="animate"
        viewport={{ once: true, margin: "-120px" }}
        variants={stagger}
      >
        <div className="overflow-hidden rounded-[2rem] border border-[#DCE3F4] bg-white/75 shadow-[0_30px_90px_-60px_rgba(40,42,71,0.8)] backdrop-blur-sm">
          <div className="grid gap-0 lg:grid-cols-[1fr_0.9fr] lg:items-stretch">
            <motion.div className="order-2 flex items-center p-6 sm:p-8 lg:order-1 lg:p-10">
              <div className="mx-auto max-w-3xl space-y-7 lg:mx-0">
                <motion.h2
                  className="text-3xl font-bold leading-tight text-[#282A47] sm:text-4xl"
                  variants={fadeInUp}
                >
                  Alle nikker.
                  <br />
                  Ingen siger noget.
                </motion.h2>

                <motion.p
                  className="text-lg font-normal leading-9 italic text-[#282A47]"
                  variants={fadeInUp}
                >
                  Men hvad tænkte de {" "}
                  <span className="relative inline-block">
                    egentlig
                    <svg
                      aria-hidden="true"
                      viewBox="0 0 144 14"
                      preserveAspectRatio="none"
                      className="absolute -bottom-1 left-0 right-0 -z-10 h-3 w-full text-[#27AB85]"
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
                  ?
                </motion.p>

                <motion.p className="text-lg leading-8 text-[#4A5568]" variants={fadeInUp}>
                  De fleste møder føles som succes i øjeblikket. Men uden ærlig
                  feedback ved du ikke, hvad der faktisk virkede - eller hvad du
                  skal gøre anderledes næste gang.
                </motion.p>

                <motion.p
                  className="text-lg font-semibold leading-9 text-[#282A47]"
                  variants={fadeInUp}
                >
                  Og derfor bliver det svært at blive bedre.
                </motion.p>
              </div>
            </motion.div>

            <motion.div
              className="order-1 overflow-hidden lg:order-2"
              variants={fadeInUp}
            >
              <div className="relative aspect-[4/3] h-full min-h-[18rem] overflow-hidden lg:min-h-[32rem]">
                {problemImages.map((image, index) => {
                  const isActive = index === activeImageIndex

                  return (
                    <Image
                      key={image.src}
                      src={image.src}
                      alt={image.alt}
                      fill
                      sizes="(min-width: 1024px) 42vw, 100vw"
                      className={`object-cover transition-opacity duration-[1400ms] ease-in-out ${
                        isActive ? "opacity-100" : "opacity-0"
                      }`}
                      priority={index === 0}
                      loading="eager"
                    />
                  )
                })}
                <div className="pointer-events-none absolute inset-0 bg-gradient-to-br from-white/60 via-white/45 to-[#f8fbff]/55" />
              </div>
            </motion.div>
          </div>
        </div>
      </motion.div>
    </section>
  )
}

export default ProblemSection
