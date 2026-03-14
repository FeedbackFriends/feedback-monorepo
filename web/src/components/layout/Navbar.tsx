'use client'

import { useEffect, useState } from 'react'
import BrandLogo from '@/components/layout/BrandLogo'
import EarlyAccessButton from '@/components/ui/EarlyAccessButton'

type NavbarProps = {
  earlyAccessUrl: string
}

function Navbar({ earlyAccessUrl }: NavbarProps) {
  const [isScrolled, setIsScrolled] = useState(false)

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 24)
    }

    handleScroll()
    window.addEventListener('scroll', handleScroll, { passive: true })

    return () => {
      window.removeEventListener('scroll', handleScroll)
    }
  }, [])

  return (
    <nav
      className={`transition-all duration-300 sm:sticky sm:top-0 sm:z-50 ${
        isScrolled
          ? 'border-b border-white/55 bg-white/52 shadow-[0_16px_40px_-30px_rgba(40,42,71,0.45)] backdrop-blur-2xl supports-backdrop-filter:bg-white/40'
          : 'border-b border-transparent bg-white/18 backdrop-blur-xl supports-backdrop-filter:bg-white/12'
      }`}
    >
      <div className="container flex h-16 items-center justify-between gap-4">
        <div className="flex gap-6 md:gap-10">
          <BrandLogo />
        </div>
        <EarlyAccessButton
          className="hidden px-4 sm:inline-flex"
          href={earlyAccessUrl}
          showIcon={false}
          size="sm"
        />
      </div>
    </nav>
  )
}

export default Navbar
