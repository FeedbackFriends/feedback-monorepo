import './App.css'
import { motion } from "framer-motion"
import PhoneFrames from './components/sections/hero/PhoneFrames'
import ScreenshotsSection from './components/sections/screenshotsSection/ScreenshotsSection'
import Navbar from '@/components/layout/Navbar'
import Background from '@/components/layout/Background'
import Footer from '@/components/layout/Footer'

function App() {
  const fadeIn = {
    initial: { opacity: 0, y: 10 },
    animate: { opacity: 1, y: 0 },
    transition: { duration: 0.8 }
  }

  const stagger = {
    animate: {
      transition: {
        staggerChildren: 0.15
      }
    }
  }


  return (
    <div className="min-h-screen bg-background overflow-hidden relative">
      <Background />
      
      {/* Content */}
      <div className="relative">
        <Navbar />
        <main>
          {/* Hero Section */}
          <section className="container pt-4 pb-12 sm:pt-8 sm:pb-24 space-y-8 md:space-y-16 min-h-screen flex items-center justify-center">
            <div className="grid lg:grid-cols-2 gap-8 items-center w-full">
              <motion.div 
                className="space-y-6 text-center lg:text-left"
                initial="initial"
                animate="animate"
                variants={stagger}
              >
                <motion.h2 
                  className="text-3xl sm:text-4xl lg:text-5xl font-bold text-transparent bg-clip-text bg-gradient-to-b from-[#4A4D69] from-0% via-[#282A47] via-50% to-[#282A47] to-100% overflow-hidden text-left"
                >
                  <div className="flex flex-wrap">
                    {["Feedback", "made", "simple"].map((word, wordIndex) => (
                      <div key={wordIndex} className="mr-3 sm:mr-4">
                        {word.split("").map((char, index) => (
                          <span
                            key={index}
                            className="inline-block"
                          >
                            {char}
                          </span>
                        ))}
                      </div>
                    ))}
                  </div>
                  <span 
                    className="text-2xl sm:text-4xl block mt-2 text-left font-light"
                  >
                    Growth made possible.✨
                  </span>
                </motion.h2>
                <motion.p 
                  className="text-base sm:text-lg text-muted-foreground max-w-2xl text-left"
                  variants={fadeIn}
                >
                  Whether you're leading meetings or improving personal skills, 
                  Lets Grow helps you get the feedback you need.
                </motion.p>
                <motion.div 
                  className="space-y-4 text-left"
                  variants={fadeIn}
                >
                  <motion.div
                    className="inline-block cursor-pointer -ml-2"
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    onClick={() => window.open("https://apps.apple.com/app/id6742420307", "_blank")}
                  >
                    <img 
                      src="/appstore.png" 
                      alt="Download on the App Store" 
                      className="h-14 w-auto transition-opacity duration-200 hover:opacity-80"
                    />
                  </motion.div>
                </motion.div>
              </motion.div>
              <PhoneFrames />
            </div>
          </section>
          
          {/* Screenshots Section */}
          <ScreenshotsSection />
        </main>
        <Footer />
      </div>
    </div>
  )
}

export default App
