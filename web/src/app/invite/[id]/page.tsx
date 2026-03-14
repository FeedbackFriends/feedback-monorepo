import type { Metadata } from "next"
import MarketingShell from "@/components/layout/MarketingShell"
import { GlassCard } from "@/components/ui/glass-card"
import { Button } from "@/components/ui/button"

type InvitePageProps = {
  params: Promise<{
    id: string
  }>
}

export const metadata: Metadata = {
  title: "Invitation | Lets Grow",
}

export default async function InvitePage({ params }: InvitePageProps) {
  const { id } = await params
  const appStoreUrl = "https://apps.apple.com/app/lets-grow/id6742420307"
  const deepLink = `letsgrow://invite?pin_code=${id}`

  return (
    <MarketingShell>
      <div className="container mx-auto max-w-2xl px-6 py-6 sm:px-8 sm:py-12 lg:max-w-3xl xl:max-w-4xl">
        <div className="space-y-6 sm:space-y-8">
          <div className="space-y-2 sm:space-y-4">
            <h1 className="text-left text-3xl font-bold sm:text-4xl">
              You have been invited
            </h1>
            <p className="text-left text-base text-muted-foreground sm:text-lg">
              You&apos;ve been invited to provide feedback for an event.
            </p>
          </div>

          <GlassCard>
            <div className="relative z-10 space-y-6 p-4 sm:space-y-8 sm:p-8">
              <div className="space-y-3 sm:space-y-4">
                <div className="flex items-center gap-3 sm:gap-4">
                  <div className="flex h-7 w-7 items-center justify-center rounded-full bg-[#27AB85] font-bold text-white shadow-md sm:h-8 sm:w-8">
                    1
                  </div>
                  <h2 className="text-lg font-semibold text-gray-800 sm:text-xl">
                    Download Let&apos;s Grow
                  </h2>
                </div>
                <div className="pl-10 sm:pl-12">
                  <p className="mb-3 text-sm text-muted-foreground sm:mb-4 sm:text-base">
                    Get started by downloading Let&apos;s Grow from the App
                    Store
                  </p>
                  <Button
                    asChild
                    className="rounded-full bg-gradient-to-b from-[#37B791] to-[#27AB85] px-8 font-medium text-white hover:opacity-90"
                  >
                    <a
                      href={appStoreUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      Download on App Store
                    </a>
                  </Button>
                </div>
              </div>

              <div className="my-4 border-t border-gray-100 sm:my-6" />

              <div className="space-y-3 sm:space-y-4">
                <div className="flex items-center gap-3 sm:gap-4">
                  <div className="flex h-7 w-7 items-center justify-center rounded-full bg-[#27AB85] font-bold text-white shadow-md sm:h-8 sm:w-8">
                    2
                  </div>
                  <h2 className="text-lg font-semibold text-gray-800 sm:text-xl">
                    Join the Event
                  </h2>
                </div>
                <div className="space-y-3 pl-10 sm:space-y-4 sm:pl-12">
                  <div>
                    <p className="mb-3 text-sm text-muted-foreground sm:text-base">
                      After installing the app, tap below to join the event
                    </p>
                    <Button
                      asChild
                      className="w-auto rounded-full bg-gradient-to-b from-[#37B791] to-[#27AB85] px-8 font-medium text-white hover:opacity-90"
                    >
                      <a href={deepLink}>Join Event</a>
                    </Button>

                    <div className="mt-6">
                      <p className="text-sm text-muted-foreground sm:text-base">
                        You also have the possibility to join the event manually
                      </p>
                      <div className="mt-2 text-2xl font-medium tracking-[.25em] text-gray-800 sm:text-3xl">
                        {id}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </GlassCard>
        </div>
      </div>
    </MarketingShell>
  )
}
