import type { Metadata } from "next"
import MarketingShell from "@/components/layout/MarketingShell"
import { GlassCard } from "@/components/ui/glass-card"
import { Button } from "@/components/ui/button"
import { readEarlyAccessUrlFromEnv } from "@/lib/letsgrow-server"

type InvitePageProps = {
  params: Promise<{
    id: string
  }>
}

export const metadata: Metadata = {
  title: "Invitation | Lets Grow",
}

export const dynamic = "force-dynamic"

export default async function InvitePage({ params }: InvitePageProps) {
  const { id } = await params
  const appStoreUrl = "https://apps.apple.com/app/lets-grow/id6742420307"
  const deepLink = `letsgrow://invite?pin_code=${id}`
  const earlyAccessUrl = readEarlyAccessUrlFromEnv()

  return (
    <MarketingShell earlyAccessUrl={earlyAccessUrl}>
      <div className="container mx-auto max-w-2xl px-6 py-8 sm:px-8 sm:py-12">
        <GlassCard>
          <div className="relative z-10 space-y-6 p-6 sm:p-8">
            <div className="space-y-3">
              <h1 className="text-3xl font-bold text-gray-900 sm:text-4xl">
                Deltag i dit event
              </h1>
              <p className="text-base text-muted-foreground sm:text-lg">
                Download appen, og åbn derefter din invitation.
              </p>
            </div>

            <div className="flex flex-col gap-3 sm:flex-row">
              <Button
                asChild
                className="h-11 rounded-full bg-linear-to-b from-[#37B791] to-[#27AB85] px-6 font-medium text-white hover:opacity-90"
              >
                <a
                  href={appStoreUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Download appen
                </a>
              </Button>

              <Button
                asChild
                className="h-11 rounded-full bg-linear-to-b from-[#37B791] to-[#27AB85] px-6 font-medium text-white hover:opacity-90"
              >
                <a href={deepLink}>Åbn invitation</a>
              </Button>
            </div>

            <div className="rounded-2xl border border-white/70 bg-white/70 p-4">
              <p className="text-sm text-muted-foreground">Invitationskode</p>
              <div className="mt-2 text-2xl font-semibold tracking-[0.25em] text-gray-900 sm:text-3xl">
                {id}
              </div>
            </div>
          </div>
        </GlassCard>
      </div>
    </MarketingShell>
  )
}
