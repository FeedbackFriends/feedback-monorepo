import { motion } from "framer-motion";
import { useState } from "react";

function ScreenshotsSection() {
  const [imageErrors, setImageErrors] = useState<Set<number>>(new Set());

  // Array of screenshot numbers to try loading
  const screenshotNumbers = [1, 2, 3, 4, 5, 6];

  const handleImageError = (index: number) => {
    setImageErrors(prev => new Set(prev).add(index));
  };

  const fadeInUp = {
    initial: { opacity: 0, y: 60 },
    animate: { opacity: 1, y: 0 },
    transition: { duration: 0.8, ease: "easeOut" }
  };

  const stagger = {
    animate: {
      transition: {
        staggerChildren: 0.1
      }
    }
  };

  const scaleOnHover = {
    initial: { scale: 1 },
    whileHover: { 
      scale: 1.02,
      transition: { duration: 0.3, ease: "easeOut" }
    },
    whileTap: { scale: 0.98 }
  };

  // Filter out images that failed to load
  const availableScreenshots = screenshotNumbers.filter(num => !imageErrors.has(num));

  if (availableScreenshots.length === 0) {
    return null; // Don't render section if no images are available
  }

  return (
    <section className="container pt-2 pb-12 sm:pt-4 sm:pb-16">
      <motion.div
        className="space-y-8"
        initial="initial"
        whileInView="animate"
        viewport={{ once: true, margin: "-100px" }}
        variants={stagger}
      >
        {/* Section Header */}
        <motion.div className="text-center space-y-4" variants={fadeInUp}>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-transparent bg-clip-text bg-gradient-to-b from-[#4A4D69] from-0% via-[#282A47] via-50% to-[#282A47] to-100%">
            Experience Lets Grow
          </h2>
          <p className="text-base sm:text-lg text-muted-foreground max-w-2xl mx-auto">
            A interface designed to make feedback seamless and engaging.
          </p>
        </motion.div>

        {/* Screenshots Grid */}
        <motion.div 
          className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-2 max-w-[1400px] mx-auto"
          variants={stagger}
        >
          {availableScreenshots.map((num) => (
            <motion.div
              key={num}
              className="relative group"
              variants={fadeInUp}
              {...scaleOnHover}
            >
              <div className="relative overflow-hidden rounded-xl shadow-md bg-gradient-to-br from-gray-100 to-gray-200 w-full">
                <img
                  src={`/appstore_${num}.jpg`}
                  alt={`Let's Grow App Screenshot ${num}`}
                  className="w-full h-auto object-cover transition-all duration-300 group-hover:brightness-103"
                  onError={() => handleImageError(num)}
                  loading="lazy"
                />
                
                {/* Overlay for better visual appeal */}
                <div className="absolute inset-0 bg-gradient-to-t from-black/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                
                {/* Subtle border enhancement */}
                <div className="absolute inset-0 rounded-xl ring-1 ring-black/5 ring-inset" />
              </div>
              
              {/* Floating shadow effect */}
              <div className="absolute inset-0 rounded-xl shadow-xl opacity-0 group-hover:opacity-30 transition-opacity duration-300 -z-10 blur-lg bg-emerald-500/20" />
            </motion.div>
          ))}
        </motion.div>

        {/* Call to Action */}
        <motion.div className="text-center pt-8" variants={fadeInUp}>
          <motion.div
            className="inline-block cursor-pointer"
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
    </section>
  );
}

export default ScreenshotsSection;
