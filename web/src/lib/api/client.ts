import type { components } from "./generated/openapi"

export type APILanguage = "da" | "en"
export type ErrorPresentation = { title: string; message: string }
type ErrorPayload = Omit<Partial<components["schemas"]["ApiError"]>, "domainCode"> & {
  domainCode?: string
}

export class APIHTTPError extends Error {
  constructor(
    public readonly status: number,
    public readonly domainCode: string | undefined,
    public readonly copy: ErrorPresentation | undefined
  ) {
    super(`API request failed (${status})`)
    this.name = "APIHTTPError"
  }
}

function stringField(payload: unknown, field: keyof ErrorPayload) {
  if (typeof payload !== "object" || payload === null || Array.isArray(payload)) return
  const value: unknown = (payload as Record<string, unknown>)[field]
  return typeof value === "string" ? value : undefined
}

function isCancellation(error: unknown) {
  return error instanceof Error && error.name === "AbortError"
}

/** The caller supplies its selected app language; device language is not a substitute. */
export async function requestAPI(
  input: RequestInfo | URL,
  { language, ...init }: RequestInit & { language: APILanguage },
  fetcher: typeof fetch = fetch
): Promise<Response> {
  const headers = new Headers(init.headers)
  headers.set("Accept-Language", language)
  const response = await fetcher(input, { ...init, headers })
  if (response.ok) return response

  let payload: unknown
  try {
    payload = await response.json()
  } catch (error) {
    if (init.signal?.aborted || isCancellation(error)) throw error
  }
  const title = stringField(payload, "userTitle")?.trim()
  const message = stringField(payload, "userMessage")?.trim()
  throw new APIHTTPError(
    response.status,
    stringField(payload, "domainCode"),
    title && message ? { title, message } : undefined
  )
}

const fallbackCopy = {
  da: {
    title: "Der opstod en fejl",
    generic: "Noget gik galt. Prøv igen.",
    signInTitle: "Log ind igen",
    signIn: "Du skal logge ind igen for at fortsætte.",
    forbiddenTitle: "Ingen adgang",
    forbidden: "Du har ikke adgang til dette indhold.",
    notFound: "Indholdet findes ikke længere. Opdater, og prøv igen.",
    conflict: "Indholdet er blevet ændret. Opdater, og prøv igen.",
    rateLimited: "Der er for mange forsøg lige nu. Vent lidt, og prøv igen.",
    server: "Der opstod en serverfejl. Prøv igen om lidt.",
    timeout: "Forbindelsen tog for lang tid. Prøv igen.",
  },
  en: {
    title: "An error occurred",
    generic: "Something went wrong. Try again.",
    signInTitle: "Log in again",
    signIn: "Log in again to continue.",
    forbiddenTitle: "Access denied",
    forbidden: "You do not have access to this content.",
    notFound: "This content is no longer available. Refresh and try again.",
    conflict: "The content has changed. Refresh and try again.",
    rateLimited: "There are too many attempts right now. Wait a moment and try again.",
    server: "A server error occurred. Try again in a moment.",
    timeout: "The connection took too long. Try again.",
  },
} as const

/** Render returned strings as text. Diagnostics and HTML response bodies are never display copy. */
export function apiErrorPresentation(error: unknown, language: APILanguage): ErrorPresentation | null {
  if (isCancellation(error)) return null
  if (error instanceof APIHTTPError && error.copy) return error.copy
  const copy = fallbackCopy[language]
  if (error instanceof APIHTTPError) {
    switch (error.status) {
      case 401: return { title: copy.signInTitle, message: copy.signIn }
      case 403: return { title: copy.forbiddenTitle, message: copy.forbidden }
      case 404: return { title: copy.title, message: copy.notFound }
      case 408: return { title: copy.title, message: copy.timeout }
      case 409: return { title: copy.title, message: copy.conflict }
      case 429: return { title: copy.title, message: copy.rateLimited }
      default:
        if (error.status >= 500) return { title: copy.title, message: copy.server }
    }
  }
  if (error instanceof Error && error.name === "TimeoutError") {
    return { title: copy.title, message: copy.timeout }
  }
  return { title: copy.title, message: copy.generic }
}
