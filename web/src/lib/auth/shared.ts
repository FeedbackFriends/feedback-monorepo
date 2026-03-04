import type { UserInfo } from "firebase/auth"

export const emailStorageKey = "feedback.auth.email-link"

export function normalizeEmail(email: string) {
  return email.trim().toLowerCase()
}

export function getStoredEmailLinkAddress() {
  if (typeof window === "undefined") {
    return null
  }

  return window.localStorage.getItem(emailStorageKey)
}

export function clearStoredEmailLinkAddress() {
  if (typeof window !== "undefined") {
    window.localStorage.removeItem(emailStorageKey)
  }
}

export function createProviderData(
  providerId: string,
  email: string | null,
  displayName: string | null
): UserInfo[] {
  return [
    {
      displayName,
      email,
      phoneNumber: null,
      photoURL: null,
      providerId,
      uid: email ?? providerId,
    },
  ]
}
