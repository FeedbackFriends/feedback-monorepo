import { expect, test } from "@playwright/test"

const authorization = "Bearer relay-test"

test("real relay forwards method, bearer, language and body, preserves status and disables caching", async ({
  request,
}) => {
  for (const method of ["GET", "POST", "DELETE"]) {
    const response = await request.fetch("/api/leader/teams/relay-conflict", {
      method,
      headers: { authorization },
      ...(method === "POST" ? { data: { id: "stable-submission-id" } } : {}),
    })
    expect(response.status()).toBe(409)
    expect(response.headers()["cache-control"]).toBe("no-store")
    expect(await response.json()).toEqual({
      path: "/teams/relay-conflict",
      method,
      authorization,
      language: "da",
      body: method === "POST" ? { id: "stable-submission-id" } : null,
    })
  }
})

test("relay rejects missing bearer and forbidden paths; upstream rejects invalid identity", async ({
  request,
}) => {
  expect((await request.get("/api/leader/teams/context")).status()).toBe(401)
  expect(
    (
      await request.get("/api/leader/account", { headers: { authorization } })
    ).status(),
  ).toBe(404)
  expect(
    (
      await request.put("/api/leader/teams/context", {
        headers: { authorization },
      })
    ).status(),
  ).toBe(405)
  const denied = await request.get("/api/leader/teams/context", {
    headers: { authorization: "Bearer invalid" },
  })
  expect(denied.status()).toBe(401)
  expect(await denied.json()).toMatchObject({ userTitle: "Log ind igen" })
})

test("relay does not follow upstream redirects", async ({ request }) => {
  const response = await request.get("/api/leader/teams/relay-redirect", {
    headers: { authorization },
  })
  expect(response.status()).toBe(502)
  expect(await response.json()).toEqual({})
})

test("relay times out upstream without exposing diagnostics", async ({
  request,
}) => {
  const response = await request.get("/api/leader/teams/relay-timeout", {
    headers: { authorization },
  })
  expect(response.status()).toBe(502)
  expect(await response.json()).toEqual({})
})
