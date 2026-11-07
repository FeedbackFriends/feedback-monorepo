import type { Metadata } from "next"
import EmployeesScreen from "@/components/teams/EmployeesScreen"

export const metadata: Metadata = { title: "Medarbejdere | Lets Grow" }

export default function EmployeesPage() {
  return <EmployeesScreen />
}
