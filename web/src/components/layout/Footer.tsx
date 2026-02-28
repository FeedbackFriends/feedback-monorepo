import { Link } from "react-router-dom"
import LetsGrowIcon from "@/assets/icon_transparent.png"
import Headline from "@/assets/headline4.png"

function Footer() {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="mt-16 border-t border-[#27AB85]/15 bg-white/70">
      <div className="container py-12 sm:py-14">
        <div className="flex flex-col gap-8 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <Link to="/" className="inline-flex items-center gap-3">
              <img
                src={LetsGrowIcon}
                alt="Lets Grow"
                className="h-8 object-contain"
                style={{ maxWidth: "3rem" }}
              />
              <img src={Headline} alt="Lets Grow" className="h-10 object-contain" />
            </Link>
          </div>

          <div className="flex flex-col items-start gap-3 text-sm text-muted-foreground sm:items-end">
            <Link
              to="/privacy-policy"
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
