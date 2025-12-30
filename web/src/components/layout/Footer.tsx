import { motion } from "framer-motion"

function Footer() {
  return (
    <div className="container py-8 border-t mt-12">
      <div className="text-sm text-gray-500 flex items-center justify-center gap-1">
        Made with 
        <motion.svg 
          className="w-4 h-4 text-red-500 inline-block"
          viewBox="0 0 24 24"
          fill="currentColor"
          animate={{ 
            scale: [1, 1.2, 1],
          }}
          transition={{
            duration: 1.5,
            repeat: Infinity,
            ease: "easeInOut"
          }}
        >
          <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" />
        </motion.svg>
        by <a 
          href="https://www.linkedin.com/in/nicolai-dam/"
          target="_blank"
          rel="noopener noreferrer"
          className="text-gray-500 hover:text-primary underline decoration-gray-500 hover:decoration-primary transition-all duration-300"
        >
          Nicolai Dam
        </a>
      </div>
      <div className="mt-4 flex justify-center gap-4">
        <a
          href="https://github.com/FeedbackFriends"
          target="_blank"
          rel="noopener noreferrer"
          className="text-sm text-gray-700 hover:text-primary underline transition-all duration-200"
        >
          GitHub
        </a>
        <a
          href="/privacy-policy"
          className="text-sm text-gray-700 hover:text-primary underline transition-all duration-200"
        >
          Privacy Policy
        </a>
        <a
          href="mailto:nicolaidam96@gmail.com"
          className="text-sm text-gray-700 hover:text-primary underline transition-all duration-200"
        >
          Contact
        </a>
      </div>
    </div>
  )
}

export default Footer
