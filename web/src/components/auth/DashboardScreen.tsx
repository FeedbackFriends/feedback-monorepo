"use client"

import { BadgeCheck, ShieldCheck, Sparkles, UserRound } from "lucide-react"
import { useAuth } from "@/components/auth/AuthProvider"
import { Card, CardContent } from "@/components/ui/card"

export default function DashboardScreen() {
  const { user } = useAuth()

  if (!user) {
    throw new Error("Dashboard profile requires an authenticated user.")
  }

  return (
    <div className="grid gap-6 xl:grid-cols-[minmax(0,1.15fr)_minmax(18rem,0.85fr)]">
      <Card className="overflow-hidden border-[#dbe4f0] bg-white shadow-[0_18px_45px_-35px_rgba(40,42,71,0.85)]">
        <CardContent className="space-y-6 p-6 sm:p-8">
          <div className="space-y-3">
            <p className="text-sm font-semibold uppercase tracking-[0.24em] text-primary">
              Logget ind
            </p>
            <h3 className="text-3xl font-semibold tracking-tight text-slate-950">
              {user.displayName ?? user.email}
            </h3>
            <p className="text-sm leading-7 text-slate-600 sm:text-base">
              {user.email
                ? `Autentificeret som ${user.email}.`
                : "Din Firebase-session er aktiv og gemmes lokalt i denne browser."}
            </p>
          </div>

          <div className="grid gap-3 rounded-[1.5rem] border border-slate-200 bg-slate-50/80 p-4 text-sm text-slate-700">
            <div className="flex items-center justify-between gap-4">
              <span className="text-slate-500">Bruger-ID</span>
              <span className="font-medium text-slate-950">{user.uid}</span>
            </div>
            <div className="flex items-center justify-between gap-4">
              <span className="text-slate-500">Loginmetoder</span>
              <span className="font-medium capitalize text-slate-950">
                {user.providerData.map((provider) => provider.providerId).join(", ")}
              </span>
            </div>
          </div>

          <div className="grid gap-3 sm:grid-cols-3">
            <div className="rounded-[1.4rem] border border-[#dfe6ef] bg-[linear-gradient(180deg,#ffffff_0%,#f7fafc_100%)] p-4">
              <span className="flex h-10 w-10 items-center justify-center rounded-2xl bg-[#eef6f3] text-primary">
                <ShieldCheck className="h-5 w-5" />
              </span>
              <p className="mt-4 text-sm text-slate-500">Session</p>
              <p className="mt-1 text-lg font-semibold text-slate-950">Beskyttet</p>
            </div>
            <div className="rounded-[1.4rem] border border-[#dfe6ef] bg-[linear-gradient(180deg,#ffffff_0%,#f7fafc_100%)] p-4">
              <span className="flex h-10 w-10 items-center justify-center rounded-2xl bg-[#eef6f3] text-primary">
                <BadgeCheck className="h-5 w-5" />
              </span>
              <p className="mt-4 text-sm text-slate-500">Workspace-adgang</p>
              <p className="mt-1 text-lg font-semibold text-slate-950">Aktiv</p>
            </div>
            <div className="rounded-[1.4rem] border border-[#dfe6ef] bg-[linear-gradient(180deg,#ffffff_0%,#f7fafc_100%)] p-4">
              <span className="flex h-10 w-10 items-center justify-center rounded-2xl bg-[#eef6f3] text-primary">
                <Sparkles className="h-5 w-5" />
              </span>
              <p className="mt-4 text-sm text-slate-500">Rolle</p>
              <p className="mt-1 text-lg font-semibold text-slate-950">Workspace-medlem</p>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card className="border-[#dbe4f0] bg-white/85 shadow-[0_18px_45px_-38px_rgba(40,42,71,0.9)] backdrop-blur-sm">
        <CardContent className="space-y-5 p-6">
          <div className="flex items-center gap-3">
            <span className="flex h-11 w-11 items-center justify-center rounded-2xl bg-[#eef4fb] text-slate-700">
              <UserRound className="h-5 w-5" />
            </span>
            <div>
              <p className="text-sm font-semibold uppercase tracking-[0.22em] text-slate-400">
                Profilstatus
              </p>
              <p className="mt-1 text-lg font-semibold text-slate-950">
                Klar til dashboard-adgang
              </p>
            </div>
          </div>

          <div className="space-y-3">
            <div className="rounded-2xl border border-slate-200 bg-slate-50/80 p-4">
              <p className="text-sm text-slate-500">Vist navn</p>
              <p className="mt-2 text-base font-semibold text-slate-950">
                {user.displayName ?? "Intet vist navn er sat"}
              </p>
            </div>
            <div className="rounded-2xl border border-slate-200 bg-slate-50/80 p-4">
              <p className="text-sm text-slate-500">Primær email</p>
              <p className="mt-2 text-base font-semibold text-slate-950">
                {user.email ?? "Ingen email tilgængelig"}
              </p>
            </div>
          </div>

          <p className="text-sm leading-6 text-slate-600">
            Profilsiden ligger nu i det fælles dashboard-layout, så hver sektion i
            sidemenuen kan opføre sig som sin egen side.
          </p>
        </CardContent>
      </Card>
    </div>
  )
}
