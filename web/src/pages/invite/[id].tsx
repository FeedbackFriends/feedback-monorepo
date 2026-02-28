import { useParams } from 'react-router-dom'
import { Button } from "@/components/ui/button"
import { GlassCard } from "@/components/ui/glass-card"
import Background from '@/components/layout/Background'
import Footer from '@/components/layout/Footer'
import Navbar from '@/components/layout/Navbar'

function InvitePage() {
  const { id } = useParams()
  const appStoreUrl = "https://apps.apple.com/app/lets-grow/id6742420307"
  const deepLink = `letsgrow://invite?pin_code=${id}`

  return (
    <div className="min-h-screen bg-background overflow-hidden relative">
      <Background />
      
      {/* Content */}
      <div className="relative">
        <Navbar />
        <div className="container max-w-2xl lg:max-w-3xl xl:max-w-4xl mx-auto py-6 sm:py-12 px-6 sm:px-8">
          <div className="space-y-6 sm:space-y-8">
            <div className="space-y-2 sm:space-y-4">
              <h1 className="text-3xl sm:text-4xl font-bold text-left">You have been invited</h1>
              <p className="text-base sm:text-lg text-muted-foreground text-left">
                You've been invited to provide feedback for an event.
              </p>
            </div>

            <GlassCard>
              <div className="p-4 sm:p-8 space-y-6 sm:space-y-8 relative z-10">
                {/* Step 1 */}
                <div className="space-y-3 sm:space-y-4">
                  <div className="flex items-center gap-3 sm:gap-4">
                    <div className="w-7 h-7 sm:w-8 sm:h-8 rounded-full bg-[#27AB85] text-white flex items-center justify-center font-bold shadow-md">
                      1
                    </div>
                    <h2 className="text-lg sm:text-xl font-semibold text-gray-800">Download Let's Grow</h2>
                  </div>
                  <div className="pl-10 sm:pl-12">
                    <p className="text-sm sm:text-base text-muted-foreground mb-3 sm:mb-4">
                      Get started by downloading Let's Grow from the App Store
                    </p>
                    <Button 
                      className="bg-gradient-to-b from-[#37B791] to-[#27AB85] hover:opacity-90 text-white rounded-full font-medium px-8"
                      onClick={() => window.open(appStoreUrl, '_blank')}
                    >
                      Download on App Store
                    </Button>
                  </div>
                </div>

                <div className="border-t border-gray-100 my-4 sm:my-6" />

                {/* Step 2 */}
                <div className="space-y-3 sm:space-y-4">
                  <div className="flex items-center gap-3 sm:gap-4">
                    <div className="w-7 h-7 sm:w-8 sm:h-8 rounded-full bg-[#27AB85] text-white flex items-center justify-center font-bold shadow-md">
                      2
                    </div>
                    <h2 className="text-lg sm:text-xl font-semibold text-gray-800">Join the Event</h2>
                  </div>
                  <div className="pl-10 sm:pl-12 space-y-3 sm:space-y-4">
                    <div>
                      <p className="text-sm sm:text-base text-muted-foreground mb-3">
                        After installing the app, tap below to join the event
                      </p>
                      <Button 
                        className="w-auto rounded-full bg-gradient-to-b from-[#37B791] to-[#27AB85] hover:opacity-90 text-white font-medium px-8"
                        onClick={() => window.location.href = deepLink}
                      >
                        Join Event
                      </Button>
                      
                      <div className="mt-6">
                        <p className="text-sm sm:text-base text-muted-foreground">
                          You also have the possibility to join the event manually
                        </p>
                        <div className="text-2xl sm:text-3xl font-medium tracking-[.25em] text-gray-800 mt-2">
                          {id}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </GlassCard>
          </div>
        </div>
        <Footer />
      </div>
    </div>
  )
}

export default InvitePage 
