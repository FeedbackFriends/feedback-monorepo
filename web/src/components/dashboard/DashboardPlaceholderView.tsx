import { ArrowRight } from "lucide-react"
import { Card, CardContent } from "@/components/ui/card"

type DashboardPlaceholderViewProps = Readonly<{
  description: string
  eyebrow: string
  highlights: readonly string[]
  title: string
}>

export default function DashboardPlaceholderView({
  description,
  eyebrow,
  highlights,
  title,
}: DashboardPlaceholderViewProps) {
  return (
    <div className="grid gap-6 xl:grid-cols-[minmax(0,1.15fr)_minmax(18rem,0.85fr)]">
      <Card className="overflow-hidden border-[#dbe4f0] bg-white shadow-[0_18px_45px_-35px_rgba(40,42,71,0.85)]">
        <CardContent className="space-y-5 p-6 sm:p-8">
          <div className="space-y-3">
            <p className="text-sm font-semibold uppercase tracking-[0.24em] text-primary">
              {eyebrow}
            </p>
            <h3 className="text-3xl font-semibold tracking-tight text-slate-950">
              {title}
            </h3>
            <p className="max-w-2xl text-sm leading-7 text-slate-600 sm:text-base">
              {description}
            </p>
          </div>

          <div className="grid gap-3">
            {highlights.map((highlight) => (
              <div
                key={highlight}
                className="flex items-start gap-3 rounded-2xl border border-slate-200 bg-slate-50/80 px-4 py-4"
              >
                <span className="mt-1 flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-white text-primary shadow-sm">
                  <ArrowRight className="h-3.5 w-3.5" />
                </span>
                <p className="text-sm leading-6 text-slate-700">{highlight}</p>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      <Card className="border-dashed border-slate-300 bg-white/80 shadow-sm backdrop-blur-sm">
        <CardContent className="space-y-4 p-6">
          <p className="text-sm font-semibold uppercase tracking-[0.22em] text-slate-500">
            Næste skridt
          </p>
          <p className="text-lg font-semibold text-slate-950">
            Denne sektion har nu sin egen side.
          </p>
          <p className="text-sm leading-6 text-slate-600">
            Dashboard-menuen linker nu direkte hertil, så næste skridt er at koble
            visningen til rigtige produktdata i stedet for placeholder-indhold.
          </p>
        </CardContent>
      </Card>
    </div>
  )
}
