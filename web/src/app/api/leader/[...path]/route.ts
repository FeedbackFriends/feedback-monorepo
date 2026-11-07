import { NextRequest } from "next/server"

// The browser supplies a Firebase ID token. The Kotlin API owns all authorization.
async function forward(
  request: NextRequest,
  context: { params: Promise<{ path: string[] }> }
) {
  const { path } = await context.params
  const allowed =
    path[0] === "teams" &&
    path.every((segment) => /^[A-Za-z0-9_-]+$/.test(segment))
  if (!allowed) return Response.json({ error: "Not found" }, { status: 404 })
  const authorization = request.headers.get("authorization")
  if (!authorization?.startsWith("Bearer "))
    return Response.json({}, { status: 401 })
  const origin = process.env.FEEDBACK_API_ORIGIN
  if (!origin)
    return Response.json(
      { error: "FEEDBACK_API_ORIGIN is required" },
      { status: 503 }
    )
  try {
    const response = await fetch(new URL(`/${path.join("/")}`, origin), {
      method: request.method,
      headers: {
        Authorization: authorization,
        "Content-Type": "application/json",
        "Accept-Language": "da",
      },
      body: request.method === "POST" ? await request.text() : undefined,
      cache: "no-store",
      redirect: "error",
      signal: AbortSignal.timeout(15000),
    })
    return new Response(await response.text(), {
      status: response.status,
      headers: {
        "Content-Type": "application/json",
        "Cache-Control": "no-store",
      },
    })
  } catch {
    return Response.json({}, { status: 502 })
  }
}

export { forward as GET, forward as POST, forward as DELETE }
