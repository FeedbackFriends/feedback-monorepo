import { expect, test } from "@playwright/test"

for (const path of [
  "/",
  "/privacy-policy",
  "/invite/PUBLIC",
  "/team-invite/PUBLIC",
]) {
  test(`public route ${path} renders without auth initialization`, async ({
    page,
  }) => {
    const authRequests: string[] = []
    page.on("request", (request) => {
      if (
        request.url().includes("/api/auth/config") ||
        request.url().includes("identitytoolkit")
      )
        authRequests.push(request.url())
    })
    await page.goto(path)
    await expect(page.getByRole("heading", { level: 1 })).toBeVisible()
    await page.evaluate(async () => {
      // Observe two paint cycles after hydration for eager effects.
      await new Promise((resolve) =>
        requestAnimationFrame(() => requestAnimationFrame(resolve)),
      )
    })
    expect(authRequests).toEqual([])
  })
}

test("unknown routes offer recovery without authentication", async ({
  page,
}) => {
  const response = await page.goto("/route-that-does-not-exist")
  expect(response?.status()).toBe(404)
  await expect(
    page.getByRole("heading", { name: "Siden findes ikke" }),
  ).toBeVisible()
  await page.getByRole("link", { name: "Gå til forsiden" }).click()
  await expect(page).toHaveURL("/")
})

test("only public marketing pages appear in sitemap; app host and account routes are noindex", async ({
  request,
  page,
}) => {
  const sitemap = await (await request.get("/sitemap.xml")).text()
  expect(sitemap).toContain("https://letsgrow.dk/privacy-policy")
  expect(sitemap).not.toMatch(/dashboard|invite|login|app\.letsgrow/)
  const app = await request.get("/privacy-policy", {
    headers: { host: "app.letsgrow.dk" },
  })
  expect(app.headers()["x-robots-tag"]).toBe("noindex, nofollow")
  await page.goto("/login")
  await expect(page.locator('meta[name="robots"]')).toHaveAttribute(
    "content",
    "noindex, nofollow",
  )
})

for (const width of [320, 390, 1280]) {
  test(`landing navigation remains usable at ${width}px with reduced motion`, async ({
    page,
  }) => {
    await page.setViewportSize({ width, height: 900 })
    await page.emulateMedia({ reducedMotion: "reduce" })
    await page.goto("/")
    await page
      .getByRole("link", { name: "Se hvad der kommer", exact: true })
      .click()
    await expect(page).toHaveURL(/#how-it-works$/)
    await expect(
      page.getByRole("heading", {
        name: "Snart: Fra idé til forbedring i 4 enkle trin",
      }),
    ).toBeInViewport()
    expect(
      await page.evaluate(
        () => document.documentElement.scrollWidth <= window.innerWidth,
      ),
    ).toBe(true)
  })
}


for (const host of ["localhost:3100", "app.letsgrow.dk", "letsgrow.dk", "www.letsgrow.dk"]) {
  test(`email callbacks at the site root reach login on ${host}`, async ({ request }) => {
    const response = await request.get("/?code=test-auth-code", {
      headers: { host }, maxRedirects: 0,
    })
    expect(response.status()).toBe(307)
    const destination = new URL(response.headers().location, response.url())
    expect(destination.pathname).toBe("/login")
    expect(destination.searchParams.get("code")).toBe("test-auth-code")
    if (host.includes("letsgrow.dk")) {
      expect(destination.host).toBe("app.letsgrow.dk")
      expect(destination.protocol).toBe("https:")
    }
    expect(response.headers()["cache-control"]).toBe("no-store")
  })
}


for (const host of ["letsgrow.localhost", "app.letsgrow.localhost"]) {
  test(`local domains keep account routing local on ${host}`, async ({ request }) => {
    for (const path of ["/?code=local-test-code", "/login", "/dashboard", "/leader-invite/personal"]) {
      const response = await request.get(path, { headers: { host }, maxRedirects: 0 })
      if (host === "letsgrow.localhost" || path.startsWith("/?")) {
        expect(response.status()).toBe(307)
        const destination = new URL(response.headers().location, response.url())
        expect(destination.origin).toBe("https://app.letsgrow.localhost")
        expect(destination.pathname).toBe(path.startsWith("/?") ? "/login" : path)
        if (path.startsWith("/?")) expect(destination.searchParams.get("code")).toBe("local-test-code")
      }
    }
    const root = await request.get("/", { headers: { host }, maxRedirects: 0 })
    if (host === "app.letsgrow.localhost") {
      expect(root.status()).toBe(307)
      expect(root.headers().location).toBe("https://app.letsgrow.localhost/dashboard")
    } else {
      expect(root.status()).toBe(200)
    }
  })
}
