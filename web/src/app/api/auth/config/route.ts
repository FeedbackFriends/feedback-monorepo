import { NextResponse } from "next/server"
import { readSupabaseConfigFromEnv } from "@/lib/auth/supabase-config"

export const dynamic = "force-dynamic"

export async function GET() {
  return NextResponse.json(readSupabaseConfigFromEnv(), {
    headers: {
      "Cache-Control": "no-store",
    },
  })
}
