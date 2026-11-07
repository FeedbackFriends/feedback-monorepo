"use client"

import Link from "next/link"
import { usePathname, useRouter } from "next/navigation"
import { useEffect, useState, type ReactNode } from "react"
import { Leaf, LogOut, Users, UserRound } from "lucide-react"
import { useAuth } from "@/components/auth/AuthProvider"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Separator } from "@/components/ui/separator"
import { Skeleton } from "@/components/ui/skeleton"
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarInset,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarProvider,
  SidebarRail,
  SidebarTrigger,
  useSidebar,
} from "@/components/ui/sidebar"
import { signOut } from "@/lib/auth"

export default function DashboardShell({ children }: { children: ReactNode }) {
  const { status, user } = useAuth()
  const router = useRouter()
  useEffect(() => {
    if (status === "unauthenticated") router.replace("/login")
  }, [status, router])
  if (status !== "authenticated")
    return (
      <main
        className="space-y-4 p-8"
        role="status"
        aria-label="Indlæser din session"
      >
        <Skeleton className="h-8 w-48" />
        <Skeleton className="h-32 w-full" />
      </main>
    )
  return (
    <SidebarProvider>
      <LeaderLayout key={user?.uid}>{children}</LeaderLayout>
    </SidebarProvider>
  )
}

function LeaderLayout({ children }: { children: ReactNode }) {
  const { user } = useAuth()
  const router = useRouter()
  const { isMobile, setOpenMobile } = useSidebar()
  const pathname = usePathname()
  const employeesActive = pathname.startsWith("/dashboard/employees")
  const [error, setError] = useState(false)
  const [busy, setBusy] = useState(false)
  return (
    <>
      <Sidebar collapsible="icon">
        <SidebarHeader>
          <SidebarTrigger
            aria-label="Luk navigation"
            className="self-end md:hidden"
          />
          <SidebarMenu>
            <SidebarMenuItem>
              <SidebarMenuButton
                asChild
                size="lg"
                tooltip={isMobile ? undefined : "Lets Grow"}
              >
                <Link href="/dashboard" onClick={() => setOpenMobile(false)}>
                  <Leaf />
                  <span className="font-semibold">Lets Grow</span>
                </Link>
              </SidebarMenuButton>
            </SidebarMenuItem>
          </SidebarMenu>
        </SidebarHeader>
        <SidebarContent>
          <SidebarGroup>
            <SidebarGroupLabel>Lederapp</SidebarGroupLabel>
            <SidebarMenu>
              <SidebarMenuItem>
                <SidebarMenuButton
                  asChild
                  isActive={!employeesActive}
                  tooltip={isMobile ? undefined : "Teams"}
                >
                  <Link
                    href="/dashboard"
                    aria-current={!employeesActive ? "page" : undefined}
                    onClick={() => setOpenMobile(false)}
                  >
                    <Users />
                    <span>Teams</span>
                  </Link>
                </SidebarMenuButton>
              </SidebarMenuItem>
              <SidebarMenuItem>
                <SidebarMenuButton
                  asChild
                  isActive={employeesActive}
                  tooltip={isMobile ? undefined : "Medarbejdere"}
                >
                  <Link
                    href="/dashboard/employees"
                    aria-current={employeesActive ? "page" : undefined}
                    onClick={() => setOpenMobile(false)}
                  >
                    <UserRound />
                    <span>Medarbejdere</span>
                  </Link>
                </SidebarMenuButton>
              </SidebarMenuItem>
            </SidebarMenu>
          </SidebarGroup>
        </SidebarContent>
        <SidebarFooter>
          <div className="grid gap-1 px-2 py-2 text-sm group-data-[collapsible=icon]:hidden">
            <span className="truncate font-medium">
              {user?.displayName ?? user?.email}
            </span>
            {user?.displayName && (
              <span className="truncate text-xs text-muted-foreground">
                {user.email}
              </span>
            )}
          </div>
          <SidebarMenu>
            <SidebarMenuItem>
              <SidebarMenuButton
                tooltip={isMobile ? undefined : "Log ud"}
                aria-label={busy ? "Logger ud…" : "Log ud"}
                disabled={busy}
                onClick={async () => {
                  setBusy(true)
                  setError(false)
                  try {
                    await signOut()
                    router.replace("/login")
                  } catch {
                    setError(true)
                  } finally {
                    setBusy(false)
                  }
                }}
              >
                <LogOut />
                <span>{busy ? "Logger ud…" : "Log ud"}</span>
              </SidebarMenuButton>
            </SidebarMenuItem>
          </SidebarMenu>
        </SidebarFooter>
        <SidebarRail />
      </Sidebar>
      <SidebarInset className="min-w-0 bg-card">
        <header className="flex h-16 shrink-0 items-center gap-2 border-b px-4">
          <SidebarTrigger
            aria-label="Vis eller skjul navigation"
            className="-ml-1"
          />
          <Separator
            orientation="vertical"
            className="mr-2 data-[orientation=vertical]:h-4"
          />
          <span className="text-sm font-medium">
            {employeesActive ? "Medarbejdere" : "Teams"}
          </span>
        </header>
        <div className="mx-auto w-full max-w-6xl space-y-6 p-4 sm:p-6 lg:p-8">
          {error && (
            <Alert variant="destructive">
              <AlertDescription>
                Kunne ikke logge ud. Prøv igen.
              </AlertDescription>
            </Alert>
          )}
          {children}
        </div>
      </SidebarInset>
    </>
  )
}
