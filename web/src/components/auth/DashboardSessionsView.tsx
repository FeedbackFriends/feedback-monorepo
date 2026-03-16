import { BellRing, CalendarPlus2, Mail, Radio, Sparkles } from "lucide-react"
import { Card, CardContent } from "@/components/ui/card"

const steps = [
  {
    description: "Opret mødet i Google Calendar, Outlook, Apple Calendar eller Teams som normalt.",
    icon: CalendarPlus2,
    title: "1. Opret eventet",
  },
  {
    description: "Tilføj feedback@letsgrow.dk som deltager i invitationen, når du sender mødet ud.",
    icon: Mail,
    title: "2. Inviter Lets Grow",
  },
  {
    description: "Når invitationen er modtaget, opretter Lets Grow en ny session, som vises her i oversigten.",
    icon: Sparkles,
    title: "3. Sessionen lander her",
  },
] as const

const listensFor = [
  "Nye mødeinvitationer sendt til feedback@letsgrow.dk",
  "Opdateringer til eksisterende events",
  "Tilbagevendende møder, der skal følges over tid",
] as const

export default function DashboardSessionsView() {
  return (
    <div className="grid gap-6 xl:grid-cols-[minmax(0,1.15fr)_minmax(20rem,0.85fr)]">
      <Card className="overflow-hidden border-[#dbe4f0] bg-white shadow-[0_18px_45px_-35px_rgba(40,42,71,0.85)]">
        <CardContent className="space-y-6 p-6 sm:p-8">
          <div className="space-y-3">
            <p className="text-sm font-semibold uppercase tracking-[0.24em] text-primary">
              Sessions
            </p>
            <h3 className="text-3xl font-semibold tracking-tight text-slate-950">
              Sådan får du et event ind her
            </h3>
            <p className="max-w-2xl text-sm leading-7 text-slate-600 sm:text-base">
              Denne side bliver fyldt, når Lets Grow modtager en kalenderinvitation.
              Hvis du vil have et møde til at dukke op her, skal du bare invitere{" "}
              <span className="font-semibold text-primary">feedback@letsgrow.dk</span>{" "}
              med i eventet.
            </p>
          </div>

          <div className="grid gap-3">
            {steps.map((step) => {
              const Icon = step.icon

              return (
                <div
                  key={step.title}
                  className="flex items-start gap-4 rounded-[1.4rem] border border-slate-200 bg-slate-50/85 px-4 py-4"
                >
                  <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-white text-primary shadow-sm">
                    <Icon className="h-5 w-5" />
                  </span>
                  <div className="min-w-0">
                    <p className="text-base font-semibold text-slate-950">{step.title}</p>
                    <p className="mt-1 text-sm leading-6 text-slate-600">
                      {step.description}
                    </p>
                  </div>
                </div>
              )
            })}
          </div>

          <div className="rounded-[1.5rem] border border-[#dbe7f2] bg-[linear-gradient(180deg,#f9fcff_0%,#f3faf6_100%)] p-5">
            <div className="flex items-start gap-3">
              <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-2xl bg-white text-primary shadow-sm">
                <BellRing className="h-5 w-5" />
              </span>
              <div>
                <p className="text-sm font-semibold uppercase tracking-[0.18em] text-slate-400">
                  Vigtigt
                </p>
                <p className="mt-2 text-sm leading-6 text-slate-700">
                  Et event dukker ikke op her automatisk bare fordi det findes i din
                  kalender. Det skal sendes til Lets Grow via invitationen.
                </p>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      <div className="space-y-6">
        <Card className="border-[#dbe4f0] bg-white/90 shadow-[0_18px_45px_-38px_rgba(40,42,71,0.9)] backdrop-blur-sm">
          <CardContent className="space-y-5 p-6">
            <div className="flex items-center gap-3">
              <div className="relative flex h-11 w-11 items-center justify-center rounded-2xl bg-[#ecf8f3] text-primary">
                <span className="absolute h-3.5 w-3.5 rounded-full bg-[#27AB85]/25 animate-ping" />
                <span className="relative h-2.5 w-2.5 rounded-full bg-[#27AB85]" />
              </div>
              <div>
                <p className="text-sm font-semibold uppercase tracking-[0.2em] text-slate-400">
                  Status
                </p>
                <p className="mt-1 text-lg font-semibold text-slate-950">
                  Lytter efter nye session invites
                </p>
              </div>
            </div>

            <div className="rounded-[1.3rem] border border-slate-200 bg-slate-50/80 p-4">
              <p className="text-sm text-slate-500">Inbox</p>
              <p className="mt-2 break-all text-base font-semibold text-slate-950">
                feedback@letsgrow.dk
              </p>
            </div>

            <div className="space-y-3">
              {listensFor.map((item) => (
                <div key={item} className="flex items-start gap-3">
                  <span className="mt-1 flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-[#eef6f3] text-primary">
                    <Radio className="h-3.5 w-3.5" />
                  </span>
                  <p className="text-sm leading-6 text-slate-600">{item}</p>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        <Card className="border-dashed border-slate-300 bg-white/80 shadow-sm backdrop-blur-sm">
          <CardContent className="space-y-4 p-6">
            <p className="text-sm font-semibold uppercase tracking-[0.22em] text-slate-500">
              Når det virker
            </p>
            <p className="text-lg font-semibold text-slate-950">
              Eventet bliver til en ny session her.
            </p>
            <p className="text-sm leading-6 text-slate-600">
              Når invitationen er modtaget, kan denne side senere vise sessionens
              navn, tidspunkt, status og næste handling.
            </p>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
