import { expect, test } from "@playwright/test"

test.describe("route smoke tests", () => {
  test("renders the landing page", async ({ page }) => {
    await page.goto("/")

    await expect(
      page.getByRole("heading", {
        name: "Gør jeres faste møder bedre, uge for uge",
      })
    ).toBeVisible()
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
