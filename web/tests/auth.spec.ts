import { expect, test } from "@playwright/test"

test.describe("login and logout", () => {
  test("redirects unauthenticated visitors from the dashboard to login", async ({
    page,
  }) => {
    await page.goto("/dashboard")

    await expect(page).toHaveURL(/\/login$/)
    await expect(page.getByRole("heading", { name: "Log ind" })).toBeVisible()
  })

  test("signs in with Google, persists the session, and signs out cleanly", async ({
    page,
  }) => {
    await page.goto("/login")

    await page.getByRole("button", { name: "Fortsæt med Google" }).click()

    await expect(page).toHaveURL(/\/dashboard$/)
    await expect(page.getByText("Playwright Test User", { exact: true })).toBeVisible()
    await page.goto("/login")
    await expect(page).toHaveURL(/\/dashboard$/)

    await page.reload()
    await expect(page).toHaveURL(/\/dashboard$/)
    await expect(page.getByText("Playwright Test User", { exact: true })).toBeVisible()

    await page.getByRole("button", { name: "Log ud" }).click()

    await expect(page).toHaveURL(/\/login$/)
    await expect(page.getByRole("heading", { name: "Log ind" })).toBeVisible()

    await page.goto("/dashboard")
    await expect(page).toHaveURL(/\/login$/)
  })
})
