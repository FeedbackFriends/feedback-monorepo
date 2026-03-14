import { cn } from "@/lib/utils"

interface BackgroundProps {
  className?: string
}

function Background({ className }: BackgroundProps) {
  return (
    <>
      {/* Background Blobs - Mobile Optimized */}
      <div className="absolute -top-20 sm:-top-40 -right-20 sm:-right-40 w-64 sm:w-96 h-64 sm:h-96 bg-blue-500/10 rounded-full blur-2xl sm:blur-3xl" />
      <div className="absolute top-1/3 -left-20 sm:-left-40 w-64 sm:w-96 h-64 sm:h-96 bg-indigo-500/5 rounded-full blur-2xl sm:blur-3xl" />
      
      {/* Additional Blobs - Hide some on mobile, adjust others */}
      <div className="hidden sm:block absolute top-1/4 right-1/4 w-[500px] h-[500px] bg-blue-300/5 rounded-full blur-3xl" />
      <div className="absolute bottom-1/3 left-1/4 w-[300px] sm:w-[600px] h-[300px] sm:h-[600px] bg-indigo-400/[0.07] rounded-full blur-2xl sm:blur-3xl" />
      <div className="hidden sm:block absolute -top-20 left-1/3 w-[400px] h-[400px] bg-blue-400/5 rounded-full blur-3xl" />
      <div className={cn("absolute top-2/3 right-1/4 w-[250px] sm:w-[450px] h-[250px] sm:h-[450px] bg-blue-500/8 rounded-full blur-2xl sm:blur-3xl animate-pulse", className)} />
    </>
  )
}

export default Background 