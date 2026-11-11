import { expect, test } from "@playwright/test"

test.describe("route smoke tests", () => {
  test("renders the landing page", async ({ page }) => {
    await page.goto("/")

    await expect(
      page.getByRole("heading", {
        name: "Gør arbejdsdagen lidt bedre",
      })
    ).toBeVisible()
    await expect(page.getByRole("link", { name: "Kom i gang", exact: true }).first()).toHaveAttribute("href", "/login")
    await expect(page.getByRole("link", { name: "hello@letsgrow.dk", exact: true })).toHaveAttribute("href", "mailto:hello@letsgrow.dk")
    await expect(page.getByRole("heading", { name: "Snart: Fra idé til forbedring i 4 enkle trin" })).toBeAttached()
    await expect(page.getByRole("link", { name: /Hent.*app|App Store/i })).toHaveCount(0)
    await expect(page.getByText("Integreret med disse kalenderværktøjer")).toHaveCount(0)
    await expect(page.locator("html")).toHaveAttribute("lang", "da")
    await expect(page).toHaveTitle("Lets Grow – Fra feedback til forbedring")
  })

  test("renders the privacy policy page", async ({ page }) => {
    await page.goto("/privacy-policy")

    await expect(
      page.getByRole("heading", { level: 1, name: "Privacy Policy" })
    ).toBeVisible()
  })

  test("renders the invite page without async params errors", async ({ page }) => {
    await page.goto("/invite/PLAYWRIGHT")

    await expect(
      page.getByRole("heading", { name: "Deltag i dit event" })
    ).toBeVisible()
    await expect(page.getByText("PLAYWRIGHT")).toBeVisible()
  })

  test("serves the health route", async ({ request }) => {
    const response = await request.get("/api/health")

    expect(response.ok()).toBeTruthy()
    await expect(await response.json()).toEqual({ ok: true })
  })
})
