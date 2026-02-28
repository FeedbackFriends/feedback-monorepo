import "./App.css"
import { motion, type Variants } from "framer-motion"
import { type MouseEvent, useState } from "react"
import {
  ArrowRight,
  CalendarDays,
  ChevronDown,
  CheckCircle2,
  Clock3,
  LineChart,
  MessageSquareText,
  Repeat2,
  Sparkles,
} from "lucide-react"
import type { LucideIcon } from "lucide-react"
import Navbar from "@/components/layout/Navbar"
import Background from "@/components/layout/Background"
import Footer from "@/components/layout/Footer"
import PhoneFrames from "@/components/sections/hero/PhoneFrames"
import { Button } from "@/components/ui/button"
import {
  earlyAccessButtonClass,
  earlyAccessLabel,
  earlyAccessUrl,
} from "@/lib/letsgrow"

const appStoreUrl = "https://apps.apple.com/app/id6742420307"

const fadeInUp: Variants = {
  initial: { opacity: 0, y: 24 },
  animate: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.7, ease: "easeOut" },
  },
}

const stagger: Variants = {
  animate: {
    transition: {
      staggerChildren: 0.12,
    },
  },
}

type FeatureCard = {
  title: string
  description: string
  icon: LucideIcon
}

type FaqItem = {
  question: string
  answer: string
}

const calendarPlatforms = [
  {
    name: "Microsoft Teams",
    icon: "/teams_logo.png",
  },
  {
    name: "Microsoft Outlook",
    icon: "/microsoft_outlook.png",
  },
  {
    name: "Google Calendar",
    icon: "/Google_Calendar_icon.png",
  },
  {
    name: "Apple Calendar",
    icon: "/apple_logo.png",
  },
  {
    name: "Zoho Calendar",
    icon: "/zoho_calendar.png",
  },
  {
    name: "Proton Calendar",
    icon: "/proton-calendar.png",
  },
]

const problemCards: FeatureCard[] = [
  {
    title: "Det samme møde, uge efter uge",
    description:
      "Teammøder, 1:1s og reviews gentager sig, men formatet bliver sjældent justeret systematisk.",
    icon: Repeat2,
  },
  {
    title: "Mange meninger, ingen vane",
    description:
      "Folk ved godt, når et møde er uklart eller fladt. De observationer bliver bare ikke samlet konsekvent.",
    icon: MessageSquareText,
  },
  {
    title: "For meget tid på mavefornemmelse",
    description:
      "Uden et fast signal er det svært at vide, om møderne faktisk bliver mere nyttige eller bare fortsætter af vane.",
    icon: Clock3,
  },
]

const workflowSteps: FeatureCard[] = [
  {
    title: "Opret mødet som normalt",
    description:
      "I bliver i de værktøjer, I allerede bruger, uanset om det er Google, Apple, Outlook, Zoho, Proton eller Teams.",
    icon: CalendarDays,
  },
  {
    title: "Tilpas spørgsmål til mødet",
    description:
      "Mødeholderen kan bruge en eksisterende spørgeskabelon eller lave sin egen, så spørgsmålene passer til fx teammøder, 1:1s eller reviews.",
    icon: Sparkles,
  },
  {
    title: "Indsaml korte svar efter mødet",
    description:
      "Efter mødet giver deltagerne feedback i en mobilapp, der er gjort så nem og friktionsfri som muligt, med 2-3 korte spørgsmål mens oplevelsen stadig står klart.",
    icon: MessageSquareText,
  },
  {
    title: "Se feedbacken og tag handling",
    description:
      "Mødeholderen kan se, hvad deltagerne faktisk oplever, reagere på konkrete input og følge, om mødetilfredsheden bliver bedre over tid.",
    icon: LineChart,
  },
]

const wedgeReasons: FeatureCard[] = [
  {
    title: "Det samme møde vender tilbage",
    description:
      "Når et møde sker uge efter uge, giver det mening at følge kvaliteten og justere formatet løbende.",
    icon: Repeat2,
  },
  {
    title: "Gentagelser skaber et mønster",
    description:
      "Enkeltstående feedback siger lidt. Gentagne svar gør det synligt, om mødet bliver bedre, står stille eller falder.",
    icon: LineChart,
  },
  {
    title: "Små justeringer bliver målbare",
    description:
      "Faste møder giver team leads og mødeejere et klart sted at forbedre noget konkret uden at starte et stort projekt.",
    icon: CheckCircle2,
  },
]

const outcomes: FeatureCard[] = [
  {
    title: "Mere klare møder",
    description:
      "Se hurtigere, om agenda, retning og beslutninger føles tydelige for deltagerne.",
    icon: CheckCircle2,
  },
  {
    title: "Bedre energi i rummet",
    description:
      "Følg om møderne opleves som engagerende eller begynder at dræne teamet.",
    icon: Sparkles,
  },
  {
    title: "Højere oplevet nytte",
    description:
      "Mål om tiden i mødet faktisk skaber værdi, eller om formatet skal strammes op.",
    icon: LineChart,
  },
  {
    title: "Svage mødeformater bliver synlige",
    description:
      "Når et fast møde halter, bliver mønsteret tydeligt nok til, at du kan handle på det.",
    icon: Repeat2,
  },
]

const faqItems: FaqItem[] = [
  {
    question: "Skal vi ændre vores nuværende måde at oprette møder på?",
    answer:
      "Nej. I opretter mødet som normalt og inviterer bare feedback@letsgrow.dk med. Lets Grow lægger sig oven på den arbejdsgang, I allerede bruger.",
  },
  {
    question: "Er det et langt spørgeskema?",
    answer:
      "Nej. Deltagerne får 2-3 korte spørgsmål lige efter mødet, mens oplevelsen stadig er frisk.",
  },
  {
    question: "Skal deltagerne oprette en konto?",
    answer:
      "Nej. Deltagerne skal ikke oprette en konto for at svare. Værdien starter hos mødeejeren, mens feedbacken forbliver let at give.",
  },
  {
    question: "Hvilke typer møder giver det bedst mening til?",
    answer:
      "Det fungerer bedst på møder, der går igen, som teammøder, 1:1s, reviews og andre møder, hvor I gerne vil kunne følge udviklingen over tid.",
  },
  {
    question: "Hvordan fungerer tidlig adgang?",
    answer:
      "Klik på “Få tidlig adgang”, udfyld den korte Typeform, og fortæl lidt om jeres faste møder. Vi følger op med de teams, der matcher launch-profilen bedst.",
  },
]

function App() {
  const [openFaqIndex, setOpenFaqIndex] = useState<number | null>(null)

  const scrollToSection = (
    event: MouseEvent<HTMLAnchorElement>,
    targetId: string
  ) => {
    event.preventDefault()

    const target = document.getElementById(targetId)
    if (!target) {
      return
    }

    const prefersReducedMotion = window.matchMedia(
      "(prefers-reduced-motion: reduce)"
    ).matches

    const startY = window.scrollY
    const targetY = target.getBoundingClientRect().top + window.scrollY - 24

    if (prefersReducedMotion) {
      window.scrollTo(0, targetY)
      window.history.replaceState(null, "", `#${targetId}`)
      return
    }

    const duration = 850
    const startTime = performance.now()

    const easeInOutCubic = (progress: number) =>
      progress < 0.5
        ? 4 * progress * progress * progress
        : 1 - Math.pow(-2 * progress + 2, 3) / 2

    const animateScroll = (currentTime: number) => {
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / duration, 1)
      const easedProgress = easeInOutCubic(progress)
      const nextY = startY + (targetY - startY) * easedProgress

      window.scrollTo(0, nextY)

      if (progress < 1) {
        window.requestAnimationFrame(animateScroll)
        return
      }

      window.history.replaceState(null, "", `#${targetId}`)
    }

    window.requestAnimationFrame(animateScroll)
  }

  return (
    <div className="relative min-h-screen overflow-hidden bg-background">
      <Background />

      <div className="relative">
        <Navbar />

        <main>
          <section className="container flex min-h-screen items-center py-12 sm:py-16">
            <div className="grid w-full items-center gap-12 lg:grid-cols-[1.05fr_0.95fr]">
              <motion.div
                className="space-y-8"
                initial="initial"
                animate="animate"
                variants={stagger}
              >
                <motion.div className="space-y-7" variants={fadeInUp}>
                  <h1 className="max-w-3xl pb-1 text-4xl font-bold leading-[1.08] text-transparent bg-clip-text bg-gradient-to-b from-[#4A4D69] via-[#282A47] to-[#1F2140] sm:text-5xl lg:text-6xl">
                    Gør jeres faste møder bedre, uge for uge
                  </h1>
                  <p className="max-w-2xl text-lg leading-8 text-muted-foreground sm:text-xl">
                    Lets Grow hjælper team leads, scrum masters og
                    mødeejere med at forbedre tilbagevendende møder gennem
                    enkel, automatisk feedback i de værktøjer, de allerede
                    bruger.
                  </p>
                </motion.div>

                <motion.div
                  className="flex flex-col gap-4 sm:flex-row sm:items-center"
                  variants={fadeInUp}
                >
                  <Button
                    asChild
                    size="lg"
                    className={`${earlyAccessButtonClass} h-12 rounded-full px-6`}
                  >
                    <a
                      href={earlyAccessUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      {earlyAccessLabel}
                      <ArrowRight className="ml-2 h-4 w-4" />
                    </a>
                  </Button>
                  <Button
                    asChild
                    size="lg"
                    variant="outline"
                    className="h-12 rounded-full border-[#DCE3F4] bg-white/80 px-6 text-[#282A47] shadow-sm hover:bg-white"
                  >
                    <a
                      href="#how-it-works"
                      onClick={(event) => scrollToSection(event, "how-it-works")}
                    >
                      Se hvordan det virker
                      <ArrowRight className="ml-2 h-4 w-4" />
                    </a>
                  </Button>
                </motion.div>

                <motion.div
                  className="rounded-[1.5rem] border border-white/70 bg-white/55 px-4 py-4 shadow-[0_18px_50px_-40px_rgba(40,42,71,0.7)] backdrop-blur sm:max-w-[34rem]"
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
                        <div className="flex h-10 w-10 items-center justify-center sm:h-11 sm:w-11">
                          <img
                            src={platform.icon}
                            alt={platform.name}
                            className="max-h-8 max-w-[2rem] object-contain sm:max-h-9 sm:max-w-[2.25rem]"
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
                  >
                    <img
                      src="/appstore.png"
                      alt="Download on the App Store"
                      className="h-14 w-auto transition-opacity duration-200 hover:opacity-85"
                    />
                  </a>
                </div>
              </motion.div>
            </div>
          </section>

          <section className="container py-8 sm:py-12">
            <motion.div
              className="rounded-[2rem] border border-white/70 bg-white/65 p-8 shadow-[0_30px_90px_-60px_rgba(40,42,71,0.8)] backdrop-blur"
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
                  Møder tager tid, men de færreste teams forbedrer dem
                  systematisk
                </h2>
                <p className="text-lg leading-8 text-muted-foreground">
                  Når de samme møder vender tilbage uge efter uge, burde
                  kvaliteten kunne følges. I praksis kører formatet ofte videre,
                  uden at nogen samler signalerne op.
                </p>
              </motion.div>

              <motion.div
                className="mt-10 grid gap-5 lg:grid-cols-3"
                variants={stagger}
              >
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
          </section>

          <section className="container py-8 sm:py-12">
            <motion.div
              className="rounded-[2rem] border border-white/70 bg-white/70 p-8 shadow-[0_30px_90px_-60px_rgba(40,42,71,0.8)] backdrop-blur"
              initial="initial"
              whileInView="animate"
              viewport={{ once: true, margin: "-120px" }}
              variants={stagger}
            >
              <motion.div className="max-w-3xl space-y-4" variants={fadeInUp}>
                <span className="text-sm font-semibold uppercase tracking-[0.24em] text-primary">
                  Hvorfor starte her?
                </span>
                <h2 className="text-3xl font-bold text-[#282A47] sm:text-4xl">
                  Det, der går igen, er lettere at forbedre
                </h2>
                <p className="text-lg leading-8 text-muted-foreground">
                  Et engangsmøde giver en enkelt mening. Når noget sker igen,
                  opstår der et mønster. Derfor starter Lets Grow her: det giver
                  de bedste betingelser for at måle kvalitet og følge
                  udviklingen over tid.
                </p>
              </motion.div>

              <motion.div
                className="mt-8 grid gap-4 sm:grid-cols-2 xl:grid-cols-3"
                variants={stagger}
              >
                {wedgeReasons.map((reason) => {
                  const Icon = reason.icon

                  return (
                  <motion.div
                    key={reason.title}
                    className="rounded-[1.5rem] border border-[#DCE3F4] bg-gradient-to-b from-white to-[#F7FAFF] px-5 py-6 shadow-[0_18px_50px_-40px_rgba(40,42,71,0.9)]"
                    variants={fadeInUp}
                    whileHover={{ y: -4, scale: 1.01 }}
                    transition={{ duration: 0.2, ease: "easeOut" }}
                  >
                    <div className="inline-flex rounded-full bg-[#EEF1F5] p-3 text-[#3F4F63]">
                      <Icon className="h-5 w-5" />
                    </div>
                    <h3 className="mt-4 text-lg font-semibold text-[#282A47]">
                      {reason.title}
                    </h3>
                    <p className="mt-3 text-base leading-7 text-muted-foreground">
                      {reason.description}
                    </p>
                  </motion.div>
                  )
                })}
              </motion.div>
            </motion.div>
          </section>

          <section id="how-it-works" className="container py-12 sm:py-16">
            <motion.div
              className="rounded-[2rem] border border-[#DCE3F4] bg-gradient-to-br from-white via-[#F8FAFF] to-[#EEF4FF] p-6 shadow-[0_28px_80px_-55px_rgba(40,42,71,0.95)] sm:p-8 lg:p-10"
              initial="initial"
              whileInView="animate"
              viewport={{ once: true, margin: "-120px" }}
              variants={stagger}
            >
              <motion.div
                className="mb-6 space-y-4"
                variants={fadeInUp}
              >
                <span className="text-sm font-semibold uppercase tracking-[0.24em] text-primary">
                  Sådan virker det
                </span>
                <h2 className="text-3xl font-bold text-[#282A47] sm:text-4xl">
                  Fra møde til indsigt og handling i fire enkle trin
                </h2>
                <p className="max-w-3xl text-lg leading-8 text-muted-foreground">
                  Ingen tung opsætning og ingen lange spørgeskemaer. Bare en
                  enkel feedbackvane, hvor mødeholderen kan tilpasse
                  spørgsmålene, se svarene og bruge dem til at forbedre næste
                  møde.
                </p>
              </motion.div>

              <motion.div
                className="grid gap-4 md:grid-cols-2"
                variants={stagger}
              >
                {workflowSteps.map((step, index) => {
                  return (
                    <motion.div
                      key={step.title}
                      className="rounded-[1.5rem] border border-[#DCE3F4] bg-white px-5 py-5 shadow-[0_18px_40px_-35px_rgba(40,42,71,0.85)]"
                      variants={fadeInUp}
                    >
                      <div className="flex items-start gap-4">
                        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-[#EEF1F5] text-lg font-semibold text-[#282A47]">
                          {index + 1}
                        </div>
                        <div className="min-w-0">
                          <div className="flex items-center">
                            <h3 className="text-lg font-semibold text-[#282A47]">
                              {step.title}
                            </h3>
                          </div>
                          <p className="mt-3 text-base leading-7 text-muted-foreground">
                            {step.description}
                          </p>
                        </div>
                      </div>
                    </motion.div>
                  )
                })}
              </motion.div>

              <motion.div
                className="mt-8 rounded-[1.5rem] border border-[#DCE3F4] bg-[#EEF1F5] px-6 py-5 shadow-[0_18px_40px_-35px_rgba(40,42,71,0.16)]"
                variants={fadeInUp}
              >
                <div className="text-xs font-semibold uppercase tracking-[0.22em] text-[#4F5563]">
                  Kort fortalt
                </div>
                <p className="mt-2 max-w-3xl text-base leading-7 text-[#3F4654] sm:text-lg">
                  I beholder jeres nuværende værktøjer, deltagerne giver få
                  svar, og mødeholderen får både konkrete input at handle på og
                  et klart billede af, om mødet udvikler sig i den rigtige
                  retning.
                </p>
              </motion.div>
            </motion.div>
          </section>

          <section className="container py-12 sm:py-16">
            <motion.div
              initial="initial"
              whileInView="animate"
              viewport={{ once: true, margin: "-120px" }}
              variants={stagger}
            >
              <motion.div className="max-w-3xl space-y-4" variants={fadeInUp}>
                <span className="text-sm font-semibold uppercase tracking-[0.24em] text-primary">
                  Hvad du får ud af det
                </span>
                <h2 className="text-3xl font-bold text-[#282A47] sm:text-4xl">
                  Et klart billede af om jeres møder faktisk bliver bedre
                </h2>
                <p className="text-lg leading-8 text-muted-foreground">
                  Fokus for launch er enkelt: gøre møder mere målbare og nemmere
                  at forbedre. Ikke et HR-værktøj og ikke en bred
                  surveyplatform.
                </p>
              </motion.div>

              <motion.div
                className="mt-10 grid gap-5 md:grid-cols-2 xl:grid-cols-4"
                variants={stagger}
              >
                {outcomes.map((outcome) => {
                  const Icon = outcome.icon

                  return (
                    <motion.div
                      key={outcome.title}
                      className="rounded-[1.75rem] border border-white/70 bg-white/80 p-6 shadow-[0_22px_60px_-45px_rgba(40,42,71,0.95)] backdrop-blur"
                      variants={fadeInUp}
                    >
                      <div className="mb-5 inline-flex rounded-full bg-[#EEF1F5] p-3 text-[#3F4F63]">
                        <Icon className="h-5 w-5" />
                      </div>
                      <h3 className="text-xl font-semibold text-[#282A47]">
                        {outcome.title}
                      </h3>
                      <p className="mt-3 text-base leading-7 text-muted-foreground">
                        {outcome.description}
                      </p>
                    </motion.div>
                  )
                })}
              </motion.div>
            </motion.div>
          </section>

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
                <p className="text-lg leading-8 text-muted-foreground">
                  De mest almindelige spørgsmål handler om workflow, tidsforbrug
                  og hvilke møder det giver mening at starte med.
                </p>
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
                      onClick={() =>
                        setOpenFaqIndex(openFaqIndex === index ? null : index)
                      }
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
                            openFaqIndex === index
                              ? "translate-y-0"
                              : "-translate-y-2"
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

          <section className="container pb-16 pt-6 sm:pb-24">
            <motion.div
              className="rounded-[2rem] border border-[#27AB85]/45 bg-gradient-to-b from-[#26A783] to-[#28AE88] p-8 text-white shadow-[0_35px_90px_-55px_rgba(39,171,133,0.62)] sm:p-10"
              initial="initial"
              whileInView="animate"
              viewport={{ once: true, margin: "-120px" }}
              variants={stagger}
            >
              <motion.div
                className="max-w-3xl space-y-5"
                variants={fadeInUp}
              >
                <span className="text-sm font-semibold uppercase tracking-[0.24em] text-white/70">
                  Tidlig adgang
                </span>
                <h2 className="text-3xl font-bold sm:text-4xl">
                  Vil I prøve Lets Grow?
                </h2>
                <p className="text-lg leading-8 text-white/80">
                    Du kan prøve Let’s Grow helt gratis og teste det i praksis. Hvis du har lyst til at være blandt de første brugere og give feedback undervejs, så vil vi meget gerne have dig med. Målet er at gøre tilbagevendende møder mere
                  målbare uden tung opsætning.
                </p>
              </motion.div>

              <motion.div
                className="mt-8 flex flex-col gap-4 sm:flex-row sm:items-center"
                variants={fadeInUp}
              >
                <Button
                  asChild
                  size="lg"
                  className="h-12 rounded-full border border-white/70 bg-white px-6 text-[#1F8F71] shadow-[0_16px_40px_-18px_rgba(15,23,42,0.35)] hover:bg-white/95"
                >
                  <a
                    href={earlyAccessUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    {earlyAccessLabel}
                    <ArrowRight className="ml-2 h-4 w-4" />
                  </a>
                </Button>
                <a
                  href="#how-it-works"
                  onClick={(event) => scrollToSection(event, "how-it-works")}
                  className="inline-flex h-12 items-center rounded-full border border-white/20 bg-white/10 px-5 text-sm font-semibold text-white/90 transition-colors hover:bg-white/16 hover:text-white"
                >
                  Se workflowet igen
                  <ArrowRight className="ml-2 h-4 w-4" />
                </a>
              </motion.div>

              <motion.p
                className="mt-4 text-sm leading-6 text-white/75"
                variants={fadeInUp}
              >
                Ingen offentlig pris endnu. Vi starter med udvalgte teams og et
                enkelt setup omkring jeres tilbagevendende møder.
              </motion.p>
            </motion.div>
          </section>
        </main>

        <Footer />
      </div>
    </div>
  )
}

export default App
