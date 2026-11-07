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
