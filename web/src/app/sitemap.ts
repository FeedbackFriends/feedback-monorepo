import type { MetadataRoute } from "next"

export default function sitemap(): MetadataRoute.Sitemap {
  return ["https://letsgrow.dk/", "https://letsgrow.dk/privacy-policy"].map(
    (url) => ({ url }),
  )
}
