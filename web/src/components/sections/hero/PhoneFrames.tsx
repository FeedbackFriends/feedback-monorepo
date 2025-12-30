import { motion } from "framer-motion";

function PhoneFrames() {
    return (
      <motion.div 
        className="relative"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8, delay: 0.2 }}
      >
        <motion.div 
          className="relative w-full max-w-[900px] mx-auto"
          animate={{ 
            y: [0, -3, 0]
          }}
          transition={{
            duration: 4,
            repeat: 1,
            ease: "easeInOut"
          }}
        >
          <img 
            src="/hero_image.png" 
            alt="Let's Grow App Interface" 
            className="w-full h-auto"
          />
        </motion.div>
      </motion.div>
    );
  }

  export default PhoneFrames