'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import {
  earlyAccessButtonClass,
  earlyAccessLabel,
  earlyAccessUrl,
} from '@/lib/letsgrow'

function Navbar() {
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
          ? 'border-b border-white/55 bg-white/52 shadow-[0_16px_40px_-30px_rgba(40,42,71,0.45)] backdrop-blur-2xl supports-[backdrop-filter]:bg-white/40'
          : 'border-b border-transparent bg-white/18 backdrop-blur-xl supports-[backdrop-filter]:bg-white/12'
      }`}
    >
      <div className="container flex h-16 items-center justify-between gap-4">
        <div className="flex gap-6 md:gap-10">
          <Link href="/" className="flex items-center space-x-4">
            <img
              src="/branding/icon_transparent.png"
              alt="Lets Grow Icon"
              className="h-8 object-contain"
              style={{ maxWidth: '3rem' }}
            />

            <img
              src="/branding/headline4.png"
              alt="Headline"
              className="h-10 object-contain"
            />
          </Link>
        </div>
        <Button
          asChild
          size="sm"
          className={`${earlyAccessButtonClass} hidden rounded-full px-4 sm:inline-flex`}
        >
          <a
            href={earlyAccessUrl}
            target="_blank"
            rel="noopener noreferrer"
          >
            {earlyAccessLabel}
          </a>
        </Button>
      </div>
    </nav>
  )
}

export default Navbar
