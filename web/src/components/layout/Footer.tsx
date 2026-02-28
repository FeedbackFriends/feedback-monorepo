function Footer() {
  return (
    <div className="container py-8 border-t mt-12">
      <div className="flex justify-center gap-4">
        <a
          href="/privacy-policy"
          className="text-sm text-gray-700 hover:text-primary underline transition-all duration-200"
        >
          Privatlivspolitik
        </a>
        <a
          href="mailto:nicolaidam96@gmail.com"
          className="text-sm text-gray-700 hover:text-primary underline transition-all duration-200"
        >
          Kontakt
        </a>
      </div>
    </div>
  )
}

export default Footer
