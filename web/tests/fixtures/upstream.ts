// Controlled HTTP upstream for exercising the real Next.js relay, not backend authorization.
import { createServer } from "node:http"

createServer(async (request, response) => {
  if (request.url === "/health") {
    response.end("ready")
    return
  }
  if (request.url === "/teams/relay-timeout") return
  if (request.url === "/teams/relay-redirect") {
    response.writeHead(302, { Location: "http://127.0.0.1:3199/health" })
    response.end()
    return
  }
  if (request.headers.authorization !== "Bearer relay-test") {
    response.writeHead(401, { "Content-Type": "application/json" })
    response.end(
      JSON.stringify({
        userTitle: "Log ind igen",
        userMessage: "Sessionen er ugyldig.",
      }),
    )
    return
  }
  const chunks: Buffer[] = []
  for await (const chunk of request) chunks.push(Buffer.from(chunk))
  const rawBody = Buffer.concat(chunks).toString()
  response.writeHead(request.url === "/teams/relay-conflict" ? 409 : 200, {
    "Content-Type": "application/json",
  })
  response.end(
    JSON.stringify({
      path: request.url,
      method: request.method,
      authorization: request.headers.authorization,
      language: request.headers["accept-language"],
      body: rawBody ? JSON.parse(rawBody) : null,
    }),
  )
}).listen(3199, "127.0.0.1")
