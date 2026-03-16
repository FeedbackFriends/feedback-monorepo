import {
  CalendarDays,
  CircleHelp,
  ClipboardList,
  UserRound,
  type LucideIcon,
} from "lucide-react"

export type DashboardHref =
  | "/dashboard"
  | "/dashboard/how-it-works"
  | "/dashboard/sessions"
  | "/dashboard/surveys"

export type DashboardNavItem = {
  description: string
  href: DashboardHref
  icon: LucideIcon
  title: string
}

export const dashboardNavItems: DashboardNavItem[] = [
  {
    href: "/dashboard/sessions",
    title: "Sessions",
    description: "Se kladder, kommende sessions og feedbackflowet for hvert møde.",
    icon: CalendarDays,
  },
  {
    href: "/dashboard/how-it-works",
    title: "Sådan virker det",
    description: "Et hurtigt overblik over hvordan Lets Grow kobler sig på jeres møder og samler feedback.",
    icon: CircleHelp,
  },
  {
    href: "/dashboard/surveys",
    title: "Spørgeskemaer",
    description: "Administrer de korte spørgsmål, som deltagerne besvarer efter mødet.",
    icon: ClipboardList,
  },
  {
    href: "/dashboard",
    title: "Profil",
    description: "Se kontoen, der er koblet til jeres workspace, og den aktuelle loginstatus.",
    icon: UserRound,
  },
]

export function getDashboardNavItem(pathname: string) {
  const normalizedPathname =
    pathname.length > 1 && pathname.endsWith("/") ? pathname.slice(0, -1) : pathname

  const item = dashboardNavItems.find((navItem) => navItem.href === normalizedPathname)

  if (!item) {
    throw new Error(`Unknown dashboard route: ${pathname}`)
  }

  return item
}
