import Link from "next/link"
import BrandLogo from "@/components/layout/BrandLogo"

function Footer() {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="mt-16 border-t border-[#27AB85]/15 bg-white/70">
      <div className="container py-12 sm:py-14">
        <div className="flex flex-col gap-8 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <BrandLogo href="/" className="inline-flex space-x-3" />
          </div>

          <div className="flex flex-col items-start gap-3 text-sm text-muted-foreground sm:items-end">
            <Link
              href="/privacy-policy"
              className="transition-colors hover:text-foreground"
            >
              Privatlivspolitik
            </Link>
            <a
              href="mailto:kontakt@letsgrow.dk"
              className="transition-colors hover:text-foreground"
            >
              kontakt@letsgrow.dk
            </a>
          </div>
        </div>

        <div className="mt-10 flex flex-col gap-3 border-t border-[#27AB85]/10 pt-6 text-sm text-muted-foreground sm:flex-row sm:items-center sm:justify-between">
          <p>© {currentYear} Lets Grow. Alle rettigheder forbeholdes.</p>
        </div>
      </div>
    </footer>
  )
}

export default Footer
