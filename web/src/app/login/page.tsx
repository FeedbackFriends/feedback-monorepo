import type { Metadata } from "next"
import LoginScreen from "@/components/auth/LoginScreen"

export const metadata: Metadata = {
  title: "Log ind | Lets Grow",
  description: "Log ind i Lets Grow med Google.",
}

export default function LoginPage() {
  return <LoginScreen />
}
