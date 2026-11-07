import type { Metadata } from "next"
import TeamScreen from "@/components/auth/TeamScreen"

export const metadata: Metadata = { title: "Team | Lets Grow" }

export default async function TeamPage({
  params,
}: {
  params: Promise<{ teamId: string }>
}) {
  const { teamId } = await params
  return <TeamScreen key={teamId} teamId={teamId} />
}
