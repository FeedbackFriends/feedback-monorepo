import type { ReactNode } from "react"
import { CheckCircle2, ShieldCheck, Sparkles } from "lucide-react"
import { cn } from "@/lib/utils"

type AuthShellProps = Readonly<{
  badge: string
  children: ReactNode
  className?: string
  description: string
  title: string
}>

const highlights = [
  "Google sign-in for quick access",
  "Browser-local session persistence until sign-out",
  "Protected dashboard routing for signed-in users",
]

export default function AuthShell({
  badge,
  children,
  className,
  description,
  title,
}: AuthShellProps) {
  return (
    <div className="relative min-h-screen overflow-hidden bg-[radial-gradient(circle_at_top,#f5fffc,transparent_38%),linear-gradient(135deg,#eff8ff_0%,#f7fcfb_48%,#ffffff_100%)]">
      <div className="pointer-events-none absolute inset-0">
        <div className="absolute left-[-10%] top-[-12rem] h-[28rem] w-[28rem] rounded-full bg-emerald-300/20 blur-3xl" />
        <div className="absolute right-[-8%] top-[12%] h-[24rem] w-[24rem] rounded-full bg-sky-300/20 blur-3xl" />
        <div className="absolute bottom-[-10rem] left-[22%] h-[26rem] w-[26rem] rounded-full bg-cyan-200/30 blur-3xl" />
      </div>

      <main className="relative mx-auto flex min-h-screen w-full max-w-6xl flex-col justify-center gap-10 px-6 py-12 lg:flex-row lg:items-center lg:px-10">
        <section className="max-w-xl space-y-6">
          <div className="inline-flex items-center gap-2 rounded-full border border-emerald-200/80 bg-white/75 px-4 py-1.5 text-sm font-semibold text-emerald-900 shadow-sm backdrop-blur">
            <Sparkles className="h-4 w-4" />
            {badge}
          </div>

          <div className="space-y-4">
            <h1 className="max-w-lg text-4xl font-semibold tracking-tight text-slate-950 sm:text-5xl">
              {title}
            </h1>
            <p className="max-w-xl text-base leading-7 text-slate-600 sm:text-lg">
              {description}
            </p>
          </div>

          <div className="grid gap-3 text-sm text-slate-700">
            {highlights.map((highlight) => (
              <div
                key={highlight}
                className="flex items-center gap-3 rounded-2xl border border-white/80 bg-white/70 px-4 py-3 shadow-sm backdrop-blur"
              >
                <CheckCircle2 className="h-5 w-5 text-emerald-600" />
                <span>{highlight}</span>
              </div>
            ))}
          </div>

          <div className="flex items-center gap-3 rounded-2xl border border-slate-200/80 bg-slate-950 px-4 py-4 text-sm text-slate-100 shadow-lg shadow-slate-900/10">
            <ShieldCheck className="h-5 w-5 text-emerald-300" />
            <p>
              Firebase runs client-side here. Configure only public
              `NEXT_PUBLIC_` values and keep sensitive credentials out of the
              app bundle.
            </p>
          </div>
        </section>

        <section className={cn("w-full max-w-md", className)}>{children}</section>
      </main>
    </div>
  )
}
