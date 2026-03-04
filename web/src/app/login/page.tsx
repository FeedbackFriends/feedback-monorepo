import type { Metadata } from "next"
import LoginScreen from "@/components/auth/LoginScreen"

export const metadata: Metadata = {
  title: "Login | Lets Grow",
  description: "Sign in to Lets Grow with Google or a secure email link.",
}

export default function LoginPage() {
  return <LoginScreen />
}
