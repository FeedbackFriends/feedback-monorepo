import { NextResponse } from "next/server"
import { readFirebaseConfigFromEnv } from "@/lib/auth/firebase-config"

export const dynamic = "force-dynamic"

export async function GET() {
  return NextResponse.json(readFirebaseConfigFromEnv(), {
    headers: {
      "Cache-Control": "no-store",
    },
  })
}
