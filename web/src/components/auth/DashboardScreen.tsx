"use client"

import Link from "next/link"
import { useRouter } from "next/navigation"
import { useEffect, useState } from "react"
import {
  BarChart3,
  CalendarClock,
  FolderKanban,
  LayoutGrid,
  LoaderCircle,
  LogOut,
  MoveLeft,
  Settings2,
  Sparkles,
  Users,
} from "lucide-react"
import Background from "@/components/layout/Background"
import BrandLogo from "@/components/layout/BrandLogo"
import { useAuth } from "@/components/auth/AuthProvider"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { signOut } from "@/lib/auth"
import { cn } from "@/lib/utils"

type DashboardTabId =
  | "overview"
  | "meetings"
  | "templates"
  | "insights"
  | "workspace"
  | "settings"

type DashboardTab = {
  description: string
  icon: typeof LayoutGrid
  id: DashboardTabId
  label: string
  stageLabel: string
}

const dashboardTabs: DashboardTab[] = [
  {
    id: "overview",
    label: "Overview",
    description: "Your default dashboard landing tab for status, focus, and next actions.",
    icon: LayoutGrid,
    stageLabel: "Ready now",
  },
  {
    id: "meetings",
    label: "Meetings",
    description: "Meeting flows and coaching moments will live here next.",
    icon: CalendarClock,
    stageLabel: "Staged",
  },
  {
    id: "templates",
    label: "Templates",
    description: "Reusable feedback rituals and meeting blueprints are planned here.",
    icon: FolderKanban,
    stageLabel: "Staged",
  },
  {
    id: "insights",
    label: "Insights",
    description: "Signals, trends, and analysis surfaces will expand into this space.",
    icon: BarChart3,
    stageLabel: "Staged",
  },
  {
    id: "workspace",
    label: "Workspace",
    description: "Workspace context, people, and setup controls are reserved for this tab.",
    icon: Users,
    stageLabel: "Staged",
  },
  {
    id: "settings",
    label: "Settings",
    description: "Account and product preferences will be introduced here later.",
    icon: Settings2,
    stageLabel: "Staged",
  },
]

const overviewStats = [
  {
    label: "Navigation tabs",
    value: "6",
    detail: "Overview, Meetings, Templates, Insights, Workspace, and Settings.",
  },
  {
    label: "Delivery mode",
    value: "Client-side",
    detail: "Tab switching stays local and deterministic without touching backend state.",
  },
  {
    label: "Current milestone",
    value: "Shell",
    detail: "The information architecture is in place so each tab can ship independently.",
  },
]

const overviewSignals = [
  {
    label: "Meetings pipeline",
    value: "Next up",
    detail: "Create flows, history, and call preparation can land here without revisiting layout.",
  },
  {
    label: "Templates library",
    value: "Structured",
    detail: "The shell now has a clear home for reusable feedback formats and prompts.",
  },
  {
    label: "Insights surfaces",
    value: "Reserved",
    detail: "Analytics and summaries can be layered in when the real data model exists.",
  },
]

function getErrorMessage(error: unknown, fallback: string) {
  if (error instanceof Error && error.message) {
    return error.message
  }

  return fallback
}

function getUserLabel(name?: string | null, email?: string | null) {
  return name ?? email ?? "Lets Grow user"
}

function getUserInitials(name?: string | null, email?: string | null) {
  const source = getUserLabel(name, email).trim()
  const parts = source.split(/\s+/).slice(0, 2)

  if (parts.length === 0) {
    return "LG"
  }

  return parts
    .map((part) => part.charAt(0).toUpperCase())
    .join("")
    .slice(0, 2)
}

function getProviderLabel(providerIds: string[]) {
  if (providerIds.length === 0) {
    return "Configured provider"
  }

  return providerIds
    .map((providerId) => providerId.replace(".com", "").replace(/\./g, " "))
    .join(", ")
}

type TabNavigationProps = Readonly<{
  activeTab: DashboardTabId
  className?: string
  onChange: (tabId: DashboardTabId) => void
  orientation?: "horizontal" | "vertical"
}>

function TabNavigation({
  activeTab,
  className,
  onChange,
  orientation = "vertical",
}: TabNavigationProps) {
  return (
    <div
      aria-label="Dashboard sections"
      className={cn(
        "flex gap-2",
        orientation === "horizontal"
          ? "overflow-x-auto pb-1"
          : "flex-col",
        className
      )}
      role="tablist"
    >
      {dashboardTabs.map((tab) => {
        const Icon = tab.icon
        const isActive = tab.id === activeTab

        return (
          <Button
            aria-selected={isActive}
            className={cn(
              "h-auto min-w-fit justify-start gap-3 rounded-2xl border px-4 py-3 text-left whitespace-nowrap transition-all",
              isActive
                ? "border-slate-950 bg-slate-950 text-white shadow-lg shadow-slate-900/15 hover:bg-slate-900"
                : "border-white/60 bg-white/65 text-slate-600 hover:bg-white hover:text-slate-950"
            )}
            key={tab.id}
            onClick={() => onChange(tab.id)}
            role="tab"
            tabIndex={isActive ? 0 : -1}
            type="button"
            variant="ghost"
          >
            <Icon className={cn("h-4 w-4 shrink-0", isActive ? "text-emerald-300" : "text-emerald-600")} />
            <span className="flex flex-col items-start">
              <span className="text-sm font-semibold">{tab.label}</span>
              <span
                className={cn(
                  "text-xs",
                  isActive ? "text-slate-300" : "text-slate-500"
                )}
              >
                {tab.stageLabel}
              </span>
            </span>
          </Button>
        )
      })}
    </div>
  )
}

function OverviewPanel({
  email,
  userName,
}: Readonly<{
  email?: string | null
  userName: string
}>) {
  return (
    <div className="space-y-4">
      <div className="grid gap-4 xl:grid-cols-[minmax(0,1.3fr)_minmax(320px,0.9fr)]">
        <Card className="border-white/70 bg-[linear-gradient(135deg,rgba(12,18,31,0.96),rgba(14,116,144,0.94))] text-white shadow-[0_30px_80px_-50px_rgba(15,23,42,0.8)]">
          <CardHeader className="space-y-4">
            <div className="flex flex-wrap items-center gap-2">
              <Badge className="bg-white/12 text-white" variant="secondary">
                Default landing tab
              </Badge>
              <Badge className="border-white/20 bg-transparent text-emerald-200" variant="outline">
                Dashboard shell
              </Badge>
            </div>
            <div className="space-y-3">
              <CardTitle className="text-3xl leading-tight sm:text-4xl">
                Welcome back, {userName.split(" ")[0]}.
              </CardTitle>
              <CardDescription className="max-w-2xl text-sm leading-6 text-slate-200 sm:text-base">
                The dashboard now has a stable app shell with a persistent tab structure.
                Feature work can land one surface at a time without changing the navigation model.
              </CardDescription>
            </div>
          </CardHeader>
          <CardContent className="grid gap-3 pt-0 sm:grid-cols-2">
            <div className="rounded-3xl border border-white/12 bg-white/10 p-4">
              <p className="text-xs font-semibold uppercase tracking-[0.24em] text-emerald-200">
                Session
              </p>
              <p className="mt-2 text-lg font-semibold text-white">{email ?? "Authenticated in browser"}</p>
              <p className="mt-2 text-sm leading-6 text-slate-200">
                Auth stays client-side and preserved until the user signs out.
              </p>
            </div>
            <div className="rounded-3xl border border-white/12 bg-white/10 p-4">
              <p className="text-xs font-semibold uppercase tracking-[0.24em] text-emerald-200">
                Information architecture
              </p>
              <p className="mt-2 text-lg font-semibold text-white">Overview is active by default</p>
              <p className="mt-2 text-sm leading-6 text-slate-200">
                Unimplemented sections stay visible as staged placeholders so the product map is clear.
              </p>
            </div>
          </CardContent>
        </Card>

        <Card className="border-white/70 bg-white/80 shadow-[0_24px_70px_-50px_rgba(40,42,71,0.8)] backdrop-blur-sm">
          <CardHeader>
            <CardTitle className="text-xl text-slate-950">Next build sequence</CardTitle>
            <CardDescription>
              A clean shell lets the product evolve tab by tab instead of page by page.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-3 pt-0">
            {[
              "Meetings can add creation flows and history without changing navigation.",
              "Templates can introduce saved structures and content libraries in-place.",
              "Insights can layer in analytics once the data model exists.",
            ].map((step) => (
              <div
                className="rounded-2xl border border-slate-200 bg-slate-50/80 px-4 py-3 text-sm leading-6 text-slate-700"
                key={step}
              >
                {step}
              </div>
            ))}
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        {overviewStats.map((stat) => (
          <Card
            className="border-white/70 bg-white/78 shadow-[0_24px_70px_-50px_rgba(40,42,71,0.8)] backdrop-blur-sm"
            key={stat.label}
          >
            <CardHeader className="space-y-2 pb-3">
              <CardDescription className="text-xs font-semibold uppercase tracking-[0.2em] text-emerald-700">
                {stat.label}
              </CardDescription>
              <CardTitle className="text-2xl text-slate-950">{stat.value}</CardTitle>
            </CardHeader>
            <CardContent className="pt-0 text-sm leading-6 text-slate-600">
              {stat.detail}
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="grid gap-4 xl:grid-cols-2">
        <Card className="border-white/70 bg-white/80 shadow-[0_24px_70px_-50px_rgba(40,42,71,0.8)] backdrop-blur-sm">
          <CardHeader>
            <CardTitle className="text-xl text-slate-950">What this shell already solves</CardTitle>
            <CardDescription>
              The layout is ready for feature teams to plug into without revisiting IA.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-3 pt-0">
            {overviewSignals.map((signal) => (
              <div
                className="rounded-2xl border border-slate-200 bg-slate-50/80 p-4"
                key={signal.label}
              >
                <div className="flex items-center justify-between gap-3">
                  <p className="text-sm font-semibold text-slate-950">{signal.label}</p>
                  <Badge className="bg-emerald-50 text-emerald-900" variant="secondary">
                    {signal.value}
                  </Badge>
                </div>
                <p className="mt-2 text-sm leading-6 text-slate-600">{signal.detail}</p>
              </div>
            ))}
          </CardContent>
        </Card>

        <Card className="border-white/70 bg-white/80 shadow-[0_24px_70px_-50px_rgba(40,42,71,0.8)] backdrop-blur-sm">
          <CardHeader>
            <CardTitle className="text-xl text-slate-950">Protected session details</CardTitle>
            <CardDescription>
              This remains the same authenticated area, now presented in a real dashboard frame.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-3 pt-0">
            {[
              {
                label: "Access model",
                value: "Unauthenticated users still redirect to /login.",
              },
              {
                label: "Sign-out",
                value: "Signing out returns the user to /login.",
              },
              {
                label: "Rendering",
                value: "The shell only renders after the client auth state resolves.",
              },
            ].map((item) => (
              <div
                className="flex items-start justify-between gap-4 rounded-2xl border border-slate-200 bg-slate-50/80 px-4 py-3"
                key={item.label}
              >
                <div>
                  <p className="text-sm font-semibold text-slate-950">{item.label}</p>
                  <p className="mt-1 text-sm leading-6 text-slate-600">{item.value}</p>
                </div>
                <Sparkles className="mt-1 h-4 w-4 shrink-0 text-emerald-600" />
              </div>
            ))}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

function PlaceholderPanel({ tab }: Readonly<{ tab: DashboardTab }>) {
  const Icon = tab.icon

  return (
    <Card className="border-white/70 bg-white/80 shadow-[0_24px_70px_-50px_rgba(40,42,71,0.8)] backdrop-blur-sm">
      <CardContent className="flex min-h-[420px] flex-col justify-between gap-8 p-6 sm:p-8">
        <div className="space-y-4">
          <div className="flex items-center gap-3">
            <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-700">
              <Icon className="h-7 w-7" />
            </div>
            <div className="space-y-2">
              <Badge className="bg-amber-50 text-amber-950" variant="secondary">
                {tab.stageLabel}
              </Badge>
              <h3 className="text-2xl font-semibold tracking-tight text-slate-950">
                {tab.label} is staged for a later issue
              </h3>
            </div>
          </div>

          <p className="max-w-2xl text-sm leading-7 text-slate-600 sm:text-base">
            {tab.description} The navigation surface is already live, so the product
            structure is locked in before feature-specific implementation begins.
          </p>
        </div>

        <div className="grid gap-4 lg:grid-cols-2">
          <div className="rounded-3xl border border-slate-200 bg-slate-50/80 p-5">
            <p className="text-xs font-semibold uppercase tracking-[0.24em] text-emerald-700">
              Why this placeholder exists
            </p>
            <p className="mt-3 text-sm leading-6 text-slate-600">
              It makes the future tab explicit instead of silently hiding unfinished
              work, which keeps the information architecture stable for follow-up issues.
            </p>
          </div>
          <div className="rounded-3xl border border-slate-200 bg-slate-50/80 p-5">
            <p className="text-xs font-semibold uppercase tracking-[0.24em] text-emerald-700">
              Current behavior
            </p>
            <p className="mt-3 text-sm leading-6 text-slate-600">
              Switching here is immediate and local to the browser. No API calls or
              persistence are involved yet.
            </p>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

export default function DashboardScreen() {
  const router = useRouter()
  const { authError, configured, status, user } = useAuth()
  const [errorMessage, setErrorMessage] = useState<string | null>(null)
  const [isSigningOut, setIsSigningOut] = useState(false)
  const [activeTab, setActiveTab] = useState<DashboardTabId>("overview")

  useEffect(() => {
    if (status === "unauthenticated") {
      router.replace("/login")
    }
  }, [router, status])

  async function handleSignOut() {
    setIsSigningOut(true)
    setErrorMessage(null)

    try {
      await signOut()
      router.replace("/login")
    } catch (error: unknown) {
      setErrorMessage(getErrorMessage(error, "Unable to sign out right now."))
    } finally {
      setIsSigningOut(false)
    }
  }

  const isLoading = status === "loading" || status === "unauthenticated"
  const displayError = configured ? errorMessage ?? authError : errorMessage
  const activeTabDefinition =
    dashboardTabs.find((tab) => tab.id === activeTab) ?? dashboardTabs[0]
  const providerIds = user?.providerData.map((provider) => provider.providerId) ?? []
  const userName = getUserLabel(user?.displayName, user?.email)
  const userInitials = getUserInitials(user?.displayName, user?.email)

  return (
    <div className="relative min-h-screen overflow-hidden bg-background">
      <div className="pointer-events-none absolute inset-0 overflow-hidden">
        <Background />
        <div className="absolute inset-0 bg-[linear-gradient(to_right,rgba(148,163,184,0.08)_1px,transparent_1px),linear-gradient(to_bottom,rgba(148,163,184,0.08)_1px,transparent_1px)] bg-[size:90px_90px] [mask-image:radial-gradient(circle_at_center,black,transparent_78%)]" />
      </div>

      <main className="relative mx-auto min-h-screen w-full max-w-7xl px-4 py-4 sm:px-6 sm:py-6 lg:px-8">
        {isLoading ? (
          <Card className="mx-auto mt-20 max-w-xl border-white/80 bg-white/88 shadow-[0_24px_70px_-50px_rgba(40,42,71,0.8)] backdrop-blur-sm">
            <CardContent className="flex items-center justify-center gap-3 p-6 text-sm font-medium text-slate-700 sm:p-8">
              <LoaderCircle className="h-4 w-4 animate-spin" />
              <span>Loading your session...</span>
            </CardContent>
          </Card>
        ) : null}

        {!isLoading && status === "authenticated" && user ? (
          <div className="space-y-4">
            <Card className="border-white/70 bg-white/78 shadow-[0_24px_70px_-50px_rgba(40,42,71,0.8)] backdrop-blur-sm md:hidden">
              <CardContent className="space-y-4 p-4">
                <div className="flex items-start justify-between gap-4">
                  <div className="space-y-3">
                    <BrandLogo />
                    <div>
                      <p className="text-xs font-semibold uppercase tracking-[0.22em] text-emerald-700">
                        Signed in
                      </p>
                      <h1 className="mt-2 text-2xl font-semibold tracking-tight text-slate-950">
                        {userName}
                      </h1>
                      <p className="mt-1 text-sm leading-6 text-slate-600">
                        {user.email
                          ? `Authenticated as ${user.email}.`
                          : "Your session is active in this browser."}
                      </p>
                    </div>
                  </div>

                  <Button
                    className="rounded-2xl"
                    disabled={isSigningOut}
                    onClick={handleSignOut}
                    size="icon"
                    type="button"
                    variant="outline"
                  >
                    <LogOut className="h-4 w-4" />
                  </Button>
                </div>

                <TabNavigation
                  activeTab={activeTab}
                  onChange={setActiveTab}
                  orientation="horizontal"
                />
              </CardContent>
            </Card>

            <div className="grid gap-4 md:grid-cols-[280px_minmax(0,1fr)] xl:grid-cols-[300px_minmax(0,1fr)]">
              <aside className="hidden md:block">
                <Card className="sticky top-6 border-white/70 bg-white/76 shadow-[0_24px_70px_-50px_rgba(40,42,71,0.8)] backdrop-blur-sm">
                  <CardContent className="space-y-6 p-5">
                    <BrandLogo />

                    <div className="rounded-3xl border border-white/70 bg-[linear-gradient(135deg,rgba(255,255,255,0.95),rgba(240,253,250,0.95))] p-4 shadow-[0_20px_60px_-45px_rgba(16,24,40,0.45)]">
                      <div className="flex items-start gap-4">
                        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-slate-950 text-sm font-semibold text-white">
                          {userInitials}
                        </div>
                        <div className="min-w-0">
                          <p className="truncate text-lg font-semibold text-slate-950">
                            {userName}
                          </p>
                          <p className="mt-1 truncate text-sm text-slate-600">
                            {user.email ?? "Authenticated browser session"}
                          </p>
                        </div>
                      </div>

                      <div className="mt-4 space-y-3 rounded-2xl border border-slate-200 bg-white/85 p-3">
                        <div className="flex items-center justify-between gap-3 text-sm">
                          <span className="text-slate-500">Providers</span>
                          <span className="text-right font-medium text-slate-950">
                            {getProviderLabel(providerIds)}
                          </span>
                        </div>
                        <div className="flex items-center justify-between gap-3 text-sm">
                          <span className="text-slate-500">User ID</span>
                          <span className="max-w-[11rem] truncate font-medium text-slate-950">
                            {user.uid}
                          </span>
                        </div>
                      </div>
                    </div>

                    <div className="space-y-3">
                      <div className="flex items-center justify-between">
                        <p className="text-xs font-semibold uppercase tracking-[0.22em] text-slate-500">
                          Workspace
                        </p>
                        <Badge className="bg-emerald-50 text-emerald-900" variant="secondary">
                          Shell v1
                        </Badge>
                      </div>
                      <TabNavigation activeTab={activeTab} onChange={setActiveTab} />
                    </div>

                    <div className="space-y-3 rounded-3xl border border-slate-200 bg-slate-50/80 p-4">
                      <p className="text-sm font-semibold text-slate-950">
                        Protected client session
                      </p>
                      <p className="text-sm leading-6 text-slate-600">
                        Redirect and sign-out behavior stay intact while the app shell grows around them.
                      </p>
                    </div>

                    <div className="space-y-3">
                      <Button
                        className="h-11 w-full rounded-2xl"
                        disabled={isSigningOut}
                        onClick={handleSignOut}
                        type="button"
                      >
                        <LogOut className="mr-2 h-4 w-4" />
                        {isSigningOut ? "Signing out..." : "Sign out"}
                      </Button>
                      <Button
                        asChild
                        className="h-11 w-full rounded-2xl"
                        variant="outline"
                      >
                        <Link href="/">
                          <MoveLeft className="mr-2 h-4 w-4" />
                          Return to landing page
                        </Link>
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              </aside>

              <section className="min-w-0 space-y-4">
                {!configured ? (
                  <Card className="border-amber-200 bg-amber-50 shadow-none">
                    <CardContent className="p-4 text-sm text-amber-950">
                      Firebase is not configured, so the dashboard cannot be opened yet.
                    </CardContent>
                  </Card>
                ) : null}

                {displayError ? (
                  <Card className="border-rose-200 bg-rose-50 shadow-none">
                    <CardContent className="p-4 text-sm text-rose-950">
                      {displayError}
                    </CardContent>
                  </Card>
                ) : null}

                <Card className="border-white/70 bg-white/76 shadow-[0_24px_70px_-50px_rgba(40,42,71,0.8)] backdrop-blur-sm">
                  <CardHeader className="space-y-4 border-b border-slate-200/80 pb-5">
                    <div className="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
                      <div className="space-y-3">
                        <div className="flex flex-wrap items-center gap-2">
                          <Badge className="bg-emerald-50 text-emerald-900" variant="secondary">
                            Persistent navigation
                          </Badge>
                          <Badge className="border-slate-300 text-slate-700" variant="outline">
                            {activeTabDefinition.stageLabel}
                          </Badge>
                        </div>
                        <div className="space-y-2">
                          <CardTitle className="text-3xl tracking-tight text-slate-950 sm:text-4xl">
                            {activeTabDefinition.label}
                          </CardTitle>
                          <CardDescription className="max-w-3xl text-sm leading-7 text-slate-600 sm:text-base">
                            {activeTabDefinition.description}
                          </CardDescription>
                        </div>
                      </div>

                      <div className="rounded-3xl border border-slate-200 bg-slate-50/85 px-4 py-3 text-sm leading-6 text-slate-600">
                        Built as a stable dashboard frame first, so feature work can land without
                        reworking layout or navigation.
                      </div>
                    </div>
                  </CardHeader>

                  <CardContent
                    aria-label={`${activeTabDefinition.label} content`}
                    className="p-4 sm:p-6"
                    role="tabpanel"
                  >
                    {activeTab === "overview" ? (
                      <OverviewPanel email={user.email} userName={userName} />
                    ) : (
                      <PlaceholderPanel tab={activeTabDefinition} />
                    )}
                  </CardContent>
                </Card>
              </section>
            </div>
          </div>
        ) : null}
      </main>
    </div>
  )
}
