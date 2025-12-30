import { Link } from 'react-router-dom'
import LetsGrowIcon from '@/assets/icon_transparent.png'
import Headline from '@/assets/headline4.png'

function Navbar() {
  return (
    <nav className="border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/100">
      <div className="container flex h-16 items-center">
        <div className="flex gap-6 md:gap-10">
          <Link to="/" className="flex items-center space-x-4">
          <img 
            src={LetsGrowIcon}
            alt="Lets Grow Icon" 
            className="h-8 object-contain"
            style={{ maxWidth: '3rem' }} 
          />

          <img 
            src={Headline}
            alt="Headline" 
            className="h-10 object-contain"
          />
          </Link>
        </div>
      </div>
    </nav>
  )
}

export default Navbar 