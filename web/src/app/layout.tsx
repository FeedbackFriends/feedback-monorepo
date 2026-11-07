import type { Metadata } from "next"
import type { ReactNode } from "react"
import { Montserrat } from "next/font/google"
import "./globals.css"

const montserrat = Montserrat({
  subsets: ["latin"],
  variable: "--font-montserrat",
  display: "swap",
})

export const metadata: Metadata = {
  title: "Lets Grow – Fra feedback til forbedring",
  description:
    "Snart: Gør medarbejdernes idéer til en bedre arbejdsdag. Lets Grow samler forslag, opbakning og synlig opfølgning.",
}

type RootLayoutProps = Readonly<{
  children: ReactNode
}>

export default function RootLayout({ children }: RootLayoutProps) {
  return (
    <html
      data-scroll-behavior="smooth"
      lang="da"
      className={`relative ${montserrat.variable}`}
    >
      <body className="font-sans">{children}</body>
    </html>
  )
}
