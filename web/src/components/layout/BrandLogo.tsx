import Link from "next/link"
import { cn } from "@/lib/utils"

type BrandLogoProps = Readonly<{
  className?: string
  href?: string
}>

function BrandLogo({ className, href = "/" }: BrandLogoProps) {
  return (
    <Link href={href} className={cn("flex items-center space-x-4", className)}>
      <img
        src="/branding/icon_transparent.png"
        alt="Lets Grow Icon"
        className="h-8 object-contain"
        style={{ maxWidth: "3rem" }}
      />

      <img
        src="/branding/headline4.png"
        alt="Lets Grow"
        className="h-10 object-contain"
      />
    </Link>
  )
}

export default BrandLogo
