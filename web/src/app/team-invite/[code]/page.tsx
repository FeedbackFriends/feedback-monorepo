import MarketingShell from "@/components/layout/MarketingShell"
import { appStoreUrl } from "@/components/landing/content"
import { Button } from "@/components/ui/button"
import { notFound } from "next/navigation"

export const metadata = { title: "Teaminvitation | Lets Grow" }
export default async function TeamInvitePage({
  params,
}: {
  params: Promise<{ code: string }>
}) {
  const { code } = await params
  if (!/^[A-Za-z0-9_-]{1,64}$/.test(code)) notFound()
  return (
    <MarketingShell>
      <div className="mx-auto max-w-xl space-y-6 px-6 py-32">
        <h1 className="text-3xl font-semibold">Bliv en del af dit team</h1>
        <p>
          Medarbejdere bruger Lets Grow i iOS-appen. Åbn invitationen i appen,
          skriv dit navn, og anmod om adgang. Din leder godkender dig.
        </p>
        <div className="flex flex-wrap gap-3">
          <Button asChild>
            <a href={`letsgrow://team-invite?code=${encodeURIComponent(code)}`}>
              Åbn i appen
            </a>
          </Button>
          <Button variant="outline" asChild>
            <a href={appStoreUrl}>Hent iOS-appen</a>
          </Button>
        </div>
        <p className="text-sm text-slate-600">
          Efter installation kan du åbne dette link igen eller indtaste koden i
          appen. Android understøttes ikke endnu.
        </p>
        <div className="rounded-lg border bg-white p-4">
          <p className="mb-2 text-sm text-slate-500">Invitationskode</p>
          <p className="break-all font-mono">{code}</p>
        </div>
      </div>
    </MarketingShell>
  )
}
