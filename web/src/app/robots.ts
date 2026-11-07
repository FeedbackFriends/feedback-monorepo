import type { MetadataRoute } from "next"

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: "*",
      allow: "/",
      // Crawl public/account HTML so its noindex metadata can be observed.
      disallow: ["/api/"],
    },
    sitemap: "https://letsgrow.dk/sitemap.xml",
  }
}
