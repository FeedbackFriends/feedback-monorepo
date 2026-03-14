import Image from "next/image"
import Link from "next/link"
import { cn } from "@/lib/utils"

type BrandLogoProps = Readonly<{
  className?: string
  href?: string
}>

function BrandLogo({ className, href = "/" }: BrandLogoProps) {
  return (
    <Link href={href} className={cn("flex items-center space-x-4", className)}>
      <Image
        src="/branding/icon_transparent.png"
        alt="Lets Grow Icon"
        width={555}
        height={438}
        sizes="48px"
        className="h-8 w-auto object-contain"
      />

      <Image
        src="/branding/headline4.png"
        alt="Lets Grow"
        width={732}
        height={268}
        sizes="110px"
        className="h-10 w-auto object-contain"
      />
    </Link>
  )
}

export default BrandLogo
