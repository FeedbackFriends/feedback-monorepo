export const requiredFirebaseConfigKeys = [
  "apiKey",
  "authDomain",
  "projectId",
  "appId",
] as const

const optionalFirebaseConfigKeys = [
  "storageBucket",
  "messagingSenderId",
  "measurementId",
] as const

export const firebaseConfigKeys = [
  ...requiredFirebaseConfigKeys,
  ...optionalFirebaseConfigKeys,
] as const

export type FirebaseConfigKey = (typeof firebaseConfigKeys)[number]

export type FirebaseConfigInput = Partial<Record<FirebaseConfigKey, string>>

export function readFirebaseConfigFromEnv(
  env: NodeJS.ProcessEnv = process.env
): FirebaseConfigInput {
  const runtimeConfig = {
    apiKey: env.NEXT_PUBLIC_FIREBASE_API_KEY,
    authDomain: env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
    projectId: env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
    appId: env.NEXT_PUBLIC_FIREBASE_APP_ID,
    storageBucket: env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
    messagingSenderId: env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
    measurementId: env.NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID,
  } satisfies Record<FirebaseConfigKey, string | undefined>

  return Object.fromEntries(
    Object.entries(runtimeConfig).filter(([, value]) => Boolean(value))
  ) as FirebaseConfigInput
}
