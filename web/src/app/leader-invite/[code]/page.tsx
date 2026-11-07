import type { Metadata } from "next"
import LeaderInviteScreen from "@/components/auth/LeaderInviteScreen"

export const metadata: Metadata = {
  title: "Lederinvitation | Lets Grow",
  robots: { index: false, follow: false },
  referrer: "no-referrer",
}

export default async function LeaderInvitePage({
  params,
}: {
  params: Promise<{ code: string }>
}) {
  const { code } = await params
  return <LeaderInviteScreen key={code} code={code} />
}
