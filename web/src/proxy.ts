import { NextRequest, NextResponse } from "next/server"

export function proxy(request: NextRequest) {
  const host = request.headers.get("host")?.split(":")[0].toLowerCase()
  const path = request.nextUrl.pathname
  if (host === "app.letsgrow.dk" && path === "/") {
    return NextResponse.redirect(new URL("https://app.letsgrow.dk/dashboard"))
  }
  if (
    (host === "letsgrow.dk" || host === "www.letsgrow.dk") &&
    (path === "/login" ||
      path.startsWith("/leader-invite/") ||
      path === "/dashboard" ||
      path.startsWith("/dashboard/"))
  ) {
    return NextResponse.redirect(
      new URL(path + request.nextUrl.search, "https://app.letsgrow.dk"),
    )
  }
  const response = NextResponse.next()
  if (host === "app.letsgrow.dk")
    response.headers.set("X-Robots-Tag", "noindex, nofollow")
  return response
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico).*)"],
}
