import { expect, test } from "@playwright/test"
import { APIHTTPError, apiErrorPresentation, requestAPI } from "../src/lib/api/client"

test("sends the selected language and preserves successful responses and auth headers", async () => {
  const success = new Response("unchanged", { status: 200 })
  const response = await requestAPI("https://example.test", {
    language: "en", headers: { Authorization: "Bearer test-token" },
  }, async (_, init) => {
    const headers = new Headers(init?.headers)
    expect(headers.get("Accept-Language")).toBe("en")
    expect(headers.get("Authorization")).toBe("Bearer test-token")
    return success
  })
  expect(response).toBe(success)
  expect(await response.text()).toBe("unchanged")
})

for (const language of ["da", "en"] as const) {
  test(`prefers backend copy with an unknown code in ${language}`, async () => {
    const copy = language === "da"
      ? { title: "Ugyldig PIN-kode", message: "Kontrollér koden." }
      : { title: "Invalid PIN code", message: "Check the code." }
    try {
      await requestAPI("https://example.test", { language }, async () => Response.json({
        domainCode: "FUTURE_CODE", userTitle: copy.title, userMessage: copy.message,
        message: "sensitive diagnostic",
      }, { status: 404 }))
      throw new Error("Expected request failure")
    } catch (error) {
      expect(error).toBeInstanceOf(APIHTTPError)
      expect((error as APIHTTPError).domainCode).toBe("FUTURE_CODE")
      expect(apiErrorPresentation(error, language)).toEqual(copy)
    }
  })
}

for (const body of ["<html>diagnostic gateway failure</html>", JSON.stringify({
  userTitle: " ", userMessage: "incomplete", message: "sensitive diagnostic",
}), JSON.stringify({ userTitle: 42, userMessage: "wrong type" })]) {
  test(`rejects unusable copy ${body.slice(0, 30)}`, async () => {
    await expect(requestAPI("https://example.test", { language: "da" }, async () => new Response(body, {
      status: 503,
    }))).rejects.toMatchObject({ status: 503, copy: undefined })
    expect(apiErrorPresentation(new APIHTTPError(503, undefined, undefined), "da")?.message)
      .toBe("Der opstod en serverfejl. Prøv igen om lidt.")
  })
}

test("preserves cancellation and hides network diagnostics", async () => {
  const cancellation = new DOMException("private diagnostic", "AbortError")
  await expect(requestAPI("https://example.test", { language: "da" }, async () => {
    throw cancellation
  })).rejects.toBe(cancellation)
  expect(apiErrorPresentation(cancellation, "da")).toBeNull()
  expect(apiErrorPresentation(new TypeError("private diagnostic"), "en")?.message)
    .toBe("Something went wrong. Try again.")
})
