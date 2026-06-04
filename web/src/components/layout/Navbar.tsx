'use client'

import { Menu } from "lucide-react"
import Link from "next/link"
import BrandLogo from '@/components/layout/BrandLogo'
import { appStoreUrl } from "@/components/landing/content"
import PrimaryButton from "@/components/ui/PrimaryButton"
import { Button } from "@/components/ui/button"
import {
  Sheet,
  SheetClose,
  SheetContent,
  SheetDescription,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet"
import { navbarSurfaceShadowClass } from "@/lib/letsgrow"

type NavbarProps = {
  ctaHref?: string
  ctaLabel?: string
}

const navItems = [
  { href: "/#problem", label: "Problem" },
  { href: "/#how-it-works", label: "Fra møde til feedback" },
  { href: "/#app-store", label: "Hent appen" },
]

function Navbar({ ctaHref, ctaLabel }: NavbarProps) {
  const buttonHref = ctaHref ?? appStoreUrl
  const buttonLabel = ctaLabel ?? "Hent appen"

  return (
    <nav
      aria-label="Primær navigation"
      className="fixed inset-x-0 top-4 z-40 px-4"
    >
      <div className="mx-auto flex w-full max-w-6xl justify-center">
        <div className={`flex w-full max-w-5xl items-center justify-between gap-3 rounded-full border border-border/75 bg-background/60 px-3 py-2 ring-1 ring-border/35 ${navbarSurfaceShadowClass} backdrop-blur-2xl`}>
          <BrandLogo className="shrink-0 rounded-full px-2 py-1" />

          <div className="hidden items-center lg:flex">
            {navItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className="px-4 py-2 text-sm font-medium text-muted-foreground transition-colors hover:text-foreground"
              >
                {item.label}
              </Link>
            ))}
          </div>

          <div className="flex items-center gap-2">
            <PrimaryButton asChild size="sm" className="hidden sm:inline-flex">
              <a href={buttonHref} target="_blank" rel="noopener noreferrer">
                {buttonLabel}
              </a>
            </PrimaryButton>

            <Sheet>
              <SheetTrigger asChild>
                <Button
                  variant="outline"
                  size="icon"
                  className="rounded-full border-border/90 bg-background/85 shadow-[0_8px_20px_-16px_rgba(40,42,71,0.6)] backdrop-blur-xl lg:hidden"
                  aria-label="Åbn navigation"
                >
                  <Menu />
                </Button>
              </SheetTrigger>
              <SheetContent
                side="right"
                className="right-3 top-3 h-[calc(100dvh-1.5rem)] w-[88vw] rounded-[2rem] border border-white/70 bg-background/80 pr-6 shadow-[0_32px_90px_-36px_rgba(40,42,71,0.55)] backdrop-blur-2xl sm:max-w-sm"
              >
              <SheetTitle className="sr-only">Mobil navigation</SheetTitle>
              <SheetDescription className="sr-only">
                Naviger mellem sektionerne på Lets Grow-siden.
              </SheetDescription>

                <div className="mt-8 flex h-full flex-col gap-6">
                  <BrandLogo className="rounded-[1.25rem] bg-white/50 px-4 py-4 backdrop-blur-xl" />

                  <div className="flex flex-col gap-2">
                    {navItems.map((item) => (
                      <SheetClose asChild key={item.href}>
                        <Link
                          href={item.href}
                          className="rounded-[1.25rem] border border-border/80 bg-card px-4 py-3.5 text-sm font-medium text-foreground/80 shadow-[0_10px_24px_-18px_rgba(40,42,71,0.35)] transition-colors hover:text-foreground"
                        >
                          {item.label}
                        </Link>
                      </SheetClose>
                    ))}
                  </div>

                  <SheetClose asChild>
                    <PrimaryButton asChild className="mt-auto mb-8 h-11">
                      <a href={buttonHref} target="_blank" rel="noopener noreferrer">
                        {buttonLabel}
                      </a>
                    </PrimaryButton>
                  </SheetClose>
                </div>
              </SheetContent>
            </Sheet>
          </div>
        </div>
      </div>
    </nav>
  )
}

export default Navbar
