import "server-only"
import { unstable_noStore as noStore } from "next/cache"

export function readEarlyAccessUrlFromEnv(
  env: NodeJS.ProcessEnv = process.env
) {
  noStore()

  const earlyAccessUrl = env.NEXT_PUBLIC_LETSGROW_EARLY_ACCESS_URL

  if (!earlyAccessUrl) {
    throw new Error("Missing NEXT_PUBLIC_LETSGROW_EARLY_ACCESS_URL.")
  }

  return earlyAccessUrl
}
