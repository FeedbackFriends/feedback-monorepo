"use client"

import Link from "next/link"
import { usePathname, useRouter } from "next/navigation"
import { useEffect, useState, type ReactNode } from "react"
import { LoaderCircle, LogOut } from "lucide-react"
import { useAuth } from "@/components/auth/AuthProvider"
import { dashboardNavItems, getDashboardNavItem } from "@/components/auth/dashboard-nav"
import BrandLogo from "@/components/layout/BrandLogo"
import { Button } from "@/components/ui/button"
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarInset,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarProvider,
} from "@/components/ui/sidebar"
import { signOut } from "@/lib/auth"
import { cn } from "@/lib/utils"

type DashboardShellProps = Readonly<{
  children: ReactNode
}>

function getErrorMessage(error: unknown, fallback: string) {
  if (error instanceof Error && error.message) {
    return error.message
  }

  return fallback
}

const sidebarPreset = {
  accountGroup: "mt-auto border-t border-[#d9e2f0] pt-5",
  footerButton:
    "h-10 w-full justify-start rounded-md px-0 text-[#667085] shadow-none hover:bg-transparent hover:text-[#282A47]",
  iconWrapActive: "bg-transparent text-[#27AB85]",
  iconWrapInactive: "bg-transparent text-[#7b849d]",
  menu: "gap-1",
  menuButtonActive: "bg-[#eaf0f8] text-[#27AB85]",
  menuButtonBase: "rounded-full px-4 py-2.5",
  menuButtonInactive: "text-[#667085] hover:bg-[#eef4fb] hover:text-[#1f2140]",
  menuGroup: "",
  sidebar: "bg-[#f7f9fd]",
} as const

export default function DashboardShell({ children }: DashboardShellProps) {
  const pathname = usePathname()
  const router = useRouter()
  const { authError, configured, status, user } = useAuth()
  const [errorMessage, setErrorMessage] = useState<string | null>(null)
  const [isSigningOut, setIsSigningOut] = useState(false)

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
      setErrorMessage(getErrorMessage(error, "Kunne ikke logge ud lige nu."))
    } finally {
      setIsSigningOut(false)
    }
  }

  const isLoading = status === "loading" || status === "unauthenticated"
  const displayError = configured ? errorMessage ?? authError : errorMessage
  const hasInviteSenderEmail = Boolean(user?.email)
  const inviteSenderEmail = user?.email ?? "Tilføj afsender-email i Profil"
  const inviteStatusDescription = hasInviteSenderEmail
    ? "Vi matcher invitationer på afsender-emailen, ikke på kalenderappen."
    : "Tilføj den email, I sender kalenderinvitationer fra, under Profil."

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-[radial-gradient(circle_at_top,#f5fffc,transparent_38%),linear-gradient(135deg,#eff8ff_0%,#f7fcfb_48%,#ffffff_100%)] px-6">
        <div className="flex items-center gap-3 rounded-2xl border border-white/80 bg-white/90 px-5 py-4 text-sm font-medium text-slate-700 shadow-lg shadow-slate-900/10 backdrop-blur-sm">
          <LoaderCircle className="h-4 w-4 animate-spin" />
          <span>Indlæser din session...</span>
        </div>
      </div>
    )
  }

  const activeItem = getDashboardNavItem(pathname)

  return (
    <div className="min-h-screen bg-slate-50">
      <SidebarProvider>
        <Sidebar className={sidebarPreset.sidebar}>
          <SidebarHeader>
            <BrandLogo className="justify-center space-x-3 py-3" href="/dashboard" />
          </SidebarHeader>

          <SidebarContent>
            <SidebarGroup className={cn("pt-8", sidebarPreset.menuGroup)}>
              <SidebarMenu className={sidebarPreset.menu}>
                {dashboardNavItems.map((item) => {
                  const Icon = item.icon
                  const isActive = activeItem.href === item.href

                  return (
                    <SidebarMenuItem key={item.href}>
                      <SidebarMenuButton
                        asChild
                        active={isActive}
                        className={cn(
                          sidebarPreset.menuButtonBase,
                          isActive
                            ? sidebarPreset.menuButtonActive
                            : sidebarPreset.menuButtonInactive
                        )}
                      >
                        <Link href={item.href}>
                          <span
                            className={cn(
                              "flex h-8 w-8 shrink-0 items-center justify-center rounded-lg transition-colors",
                              isActive
                                ? sidebarPreset.iconWrapActive
                                : sidebarPreset.iconWrapInactive
                            )}
                          >
                            <Icon className="h-4 w-4" />
                          </span>
                          <span className="transition-colors">{item.title}</span>
                        </Link>
                      </SidebarMenuButton>
                    </SidebarMenuItem>
                  )
                })}
              </SidebarMenu>
            </SidebarGroup>

            <SidebarGroup className={sidebarPreset.accountGroup}>
              <SidebarGroupLabel className="text-slate-400">Invitationer</SidebarGroupLabel>
              <SidebarGroupContent>
                <div className="rounded-2xl border border-slate-200 bg-white/80 p-4">
                  <div className="flex items-center gap-3">
                    <span className="relative flex h-3 w-3 shrink-0">
                      <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-[#27AB85]/35" />
                      <span className="relative inline-flex h-3 w-3 rounded-full bg-[#27AB85]" />
                    </span>
                    <p className="text-sm font-semibold text-slate-950">Lytter efter nye invitationer</p>
                  </div>

                  <p className="mt-4 text-xs font-semibold uppercase tracking-[0.18em] text-slate-400">
                    Afsender-email
                  </p>
                  <p className="mt-2 break-all text-sm font-semibold leading-6 text-slate-950">
                    {inviteSenderEmail}
                  </p>

                  <p className="mt-3 text-sm leading-6 text-slate-500">{inviteStatusDescription}</p>
                </div>
              </SidebarGroupContent>
            </SidebarGroup>
          </SidebarContent>

          <SidebarFooter>
            <Button
              className={sidebarPreset.footerButton}
              disabled={isSigningOut}
              onClick={handleSignOut}
              type="button"
              variant="ghost"
            >
              <LogOut className="mr-3 h-4 w-4" />
              {isSigningOut ? "Logger ud..." : "Log ud"}
            </Button>
          </SidebarFooter>
        </Sidebar>

        <SidebarInset className="bg-[radial-gradient(circle_at_top_left,rgba(39,171,133,0.10),transparent_26%),linear-gradient(180deg,#f8fbff_0%,#f9fbfd_55%,#ffffff_100%)] px-5 py-6 sm:px-6 lg:px-10 lg:py-8">
          <div className="mx-auto w-full max-w-6xl">
            <div className="mb-6 border-b border-slate-200/70 pb-6">
              <div className="space-y-2">
                <p className="text-sm font-semibold uppercase tracking-[0.22em] text-slate-500">
                  Oversigt
                </p>
                <h2 className="text-3xl font-semibold tracking-tight text-slate-950">
                  {activeItem.title}
                </h2>
                <p className="max-w-2xl text-sm leading-6 text-slate-600 sm:text-base">
                  {activeItem.description}
                </p>
              </div>
            </div>

            {!configured ? (
              <div className="mb-6 rounded-2xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-950">
                Firebase er ikke konfigureret endnu, så dashboardet kan ikke åbnes.
              </div>
            ) : null}

            {displayError ? (
              <div className="mb-6 rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-950">
                {displayError}
              </div>
            ) : null}

            {status === "authenticated" && user ? children : null}
          </div>
        </SidebarInset>
      </SidebarProvider>
    </div>
  )
}
