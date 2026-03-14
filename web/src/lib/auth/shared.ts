import type { UserInfo } from "firebase/auth"

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
