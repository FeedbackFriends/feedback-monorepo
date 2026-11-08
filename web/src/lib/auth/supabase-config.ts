export type SupabaseConfigInput = { url?: string; publishableKey?: string }

export function readSupabaseConfigFromEnv(env: NodeJS.ProcessEnv = process.env): SupabaseConfigInput {
  return { url: env.NEXT_PUBLIC_SUPABASE_URL, publishableKey: env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY }
}
