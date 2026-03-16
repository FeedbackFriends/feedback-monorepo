"use client"

import Image from "next/image"
import Link from "next/link"
import {
  ArrowUpRight,
  CalendarDays,
  ClipboardCheck,
  MailPlus,
} from "lucide-react"
import { useAuth } from "@/components/auth/AuthProvider"
import { calendarPlatforms } from "@/components/landing/content"

const howItWorksSteps = [
  {
    description:
      "I opretter mødet i Google Calendar, Outlook, Apple Calendar eller Teams, præcis som I plejer.",
    icon: CalendarDays,
    title: "Opret mødet som normalt",
  },
  {
    description:
      "Tilføj feedback@letsgrow.dk til kalenderinvitationen. Det er den eneste ekstra handling i jeres eksisterende flow.",
    icon: MailPlus,
    title: "Tilføj Lets Grow til invitationen",
  },
  {
    description:
      "Lets Grow opretter en session, så mødeholderen kan vælge spørgsmål, følge svarene og se udviklingen over tid.",
    icon: ClipboardCheck,
    title: "Tilpas og følg op i Lets Grow",
  },
] as const

const supportedPlatformNames = [
  "Google Calendar",
  "Microsoft Outlook",
  "Apple Calendar",
  "Microsoft Teams",
] as const

const supportedPlatforms = supportedPlatformNames
  .map((name) => {
    const platform = calendarPlatforms.find((item) => item.name === name)

    if (!platform) {
      throw new Error(`Missing platform asset for ${name}.`)
    }

    return platform
  })

function formatAccountEmail(accountEmail: string | null) {
  if (!accountEmail) {
    return "Add your calendar account email in Profile"
  }

  return accountEmail
}

export default function DashboardHowItWorksView() {
  const { user } = useAuth()
  const accountEmail = formatAccountEmail(user?.email ?? null)

  return (
    <div className="space-y-8">
      <section className="grid gap-6 xl:grid-cols-[minmax(0,1.1fr)_minmax(18rem,0.9fr)]">
        <div className="space-y-4">
          {howItWorksSteps.map((step, index) => {
            const Icon = step.icon

            return (
              <div
                key={step.title}
                className="rounded-[1.6rem] border border-[#dde6f3] bg-white/90 px-5 py-5 shadow-[0_18px_45px_-38px_rgba(40,42,71,0.9)] backdrop-blur-sm"
              >
                <div className="flex items-start gap-4">
                  <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-[#eef6f3] text-primary">
                    <Icon className="h-5 w-5" />
                  </div>
                  <div className="min-w-0">
                    <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-[0.18em] text-slate-400">
                      <span>Trin {index + 1}</span>
                    </div>
                    <h4 className="mt-2 text-lg font-semibold text-slate-950 sm:text-xl">
                      {step.title}
                    </h4>
                    <p className="mt-2 max-w-2xl text-sm leading-7 text-slate-600 sm:text-base">
                      {step.description}
                    </p>
                  </div>
                </div>
              </div>
            )
          })}
        </div>

        <div className="space-y-6">
          <div className="rounded-[1.75rem] border border-[#dce5f1] bg-[linear-gradient(180deg,rgba(255,255,255,0.92),rgba(244,250,247,0.96))] p-6 shadow-[0_18px_45px_-38px_rgba(40,42,71,0.9)] backdrop-blur-sm">
            <div className="flex items-center gap-3">
              <span className="flex h-11 w-11 items-center justify-center rounded-2xl bg-[#eef6f3] text-primary">
                <MailPlus className="h-5 w-5" />
              </span>
              <div>
                <p className="text-sm font-semibold uppercase tracking-[0.18em] text-slate-400">
                  Kalenderkonto
                </p>
                <p className="mt-1 text-lg font-semibold text-slate-950">{accountEmail}</p>
              </div>
            </div>

            <div className="mt-5 rounded-full border border-[#dbe7f2] bg-white px-4 py-2 text-sm font-medium text-slate-700">
              Mailen skal matche den konto, I bruger til at sende kalenderinvitationer.
            </div>

            <p className="mt-4 text-sm leading-6 text-slate-600">
              Den kan senere opdateres i profilen, hvis I skifter mailkonto eller
              kalenderopsætning.
            </p>
          </div>

          <div className="rounded-[1.75rem] border border-[#dce5f1] bg-white p-6 shadow-[0_18px_45px_-38px_rgba(40,42,71,0.9)]">
            <div className="flex items-center justify-between gap-3">
              <div>
                <p className="text-sm font-semibold uppercase tracking-[0.18em] text-slate-400">
                  Virker med
                </p>
                <p className="mt-1 text-lg font-semibold text-slate-950">
                  Jeres nuværende kalenderstack
                </p>
              </div>
              <Link
                href="/dashboard/sessions"
                className="inline-flex items-center gap-1 text-sm font-semibold text-primary"
              >
                Se sessions
                <ArrowUpRight className="h-4 w-4" />
              </Link>
            </div>

            <div className="mt-5 grid gap-3 sm:grid-cols-2">
              {supportedPlatforms.map((platform) => (
                <div
                  key={platform.name}
                  className="flex items-center gap-3 rounded-2xl border border-[#dde6f2] bg-slate-50/70 px-4 py-3"
                >
                  <span className="flex h-10 w-10 items-center justify-center rounded-2xl bg-white shadow-sm">
                    <Image
                      alt={platform.name}
                      src={platform.icon}
                      width={24}
                      height={24}
                      className="h-6 w-6 object-contain"
                    />
                  </span>
                  <span className="text-sm font-semibold text-slate-800">
                    {platform.name}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>
    </div>
  )
}
