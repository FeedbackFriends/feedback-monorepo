import { NextRequest, NextResponse } from "next/server"

export function proxy(request: NextRequest) {
  const host = request.headers.get("host")?.split(":")[0].toLowerCase()
  const path = request.nextUrl.pathname
  const isLocalDomain = process.env.NODE_ENV === "development" &&
    (host === "letsgrow.localhost" || host === "app.letsgrow.localhost")
  const appOrigin = isLocalDomain ? "https://app.letsgrow.localhost" : "https://app.letsgrow.dk"
  const isAppHost = host === "app.letsgrow.dk" || (isLocalDomain && host === "app.letsgrow.localhost")
  const isMarketingHost = host === "letsgrow.dk" || host === "www.letsgrow.dk" ||
    (isLocalDomain && host === "letsgrow.localhost")
  // Older email links use the configured site root. Keep the PKCE code until
  // the account route initializes Supabase and exchanges it for a session.
  if (path === "/" && request.nextUrl.searchParams.has("code")) {
    const destination = new URL(
      "/login" + request.nextUrl.search,
      isMarketingHost || isAppHost
        ? appOrigin
        : request.url,
    )
    const response = NextResponse.redirect(destination)
    response.headers.set("Cache-Control", "no-store")
    return response
  }
  if (isAppHost && path === "/") {
    return NextResponse.redirect(new URL("/dashboard", appOrigin))
  }
  if (
    isMarketingHost &&
    (path === "/login" ||
      path.startsWith("/leader-invite/") ||
      path === "/dashboard" ||
      path.startsWith("/dashboard/"))
  ) {
    return NextResponse.redirect(
      new URL(path + request.nextUrl.search, appOrigin),
    )
  }
  const response = NextResponse.next()
  if (isAppHost)
    response.headers.set("X-Robots-Tag", "noindex, nofollow")
  return response
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico).*)"],
}
