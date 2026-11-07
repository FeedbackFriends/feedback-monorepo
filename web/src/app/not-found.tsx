import Link from "next/link"
import { Button } from "@/components/ui/button"

export default function NotFound() {
  return (
    <main className="mx-auto max-w-xl space-y-4 px-4 py-20">
      <h1 className="text-2xl font-semibold">Siden findes ikke</h1>
      <p>Linket er muligvis ændret. Gå til forsiden for at fortsætte.</p>
      <Button asChild>
        <Link href="/">Gå til forsiden</Link>
      </Button>
    </main>
  )
}
