import { expect, test } from "@playwright/test"

test.describe("login and logout", () => {
  test("redirects unauthenticated visitors from the dashboard to login", async ({
    page,
  }) => {
    await page.goto("/dashboard")

    await expect(page).toHaveURL(/\/login$/)
    await expect(
      page.getByRole("heading", {
        name: "Sign in to your meeting feedback dashboard",
      })
    ).toBeVisible()
  })

  test("signs in with Google, persists the session, and signs out cleanly", async ({
    page,
  }) => {
    await page.goto("/login")

    await page.getByRole("button", { name: "Continue with Google" }).click()

    await expect(page).toHaveURL(/\/dashboard$/)
    await expect(page.getByText("Signed in")).toBeVisible()
    await expect(
      page.getByRole("heading", { name: "Playwright Test User" })
    ).toBeVisible()
    await expect(page.getByText("Authenticated as playwright@example.com.")).toBeVisible()

    await page.goto("/login")
    await expect(page).toHaveURL(/\/dashboard$/)

    await page.reload()
    await expect(page).toHaveURL(/\/dashboard$/)
    await expect(page.getByText("Authenticated as playwright@example.com.")).toBeVisible()

    await page.getByRole("button", { name: "Sign out" }).click()

    await expect(page).toHaveURL(/\/login$/)
    await expect(
      page.getByRole("heading", {
        name: "Sign in to your meeting feedback dashboard",
      })
    ).toBeVisible()

    await page.goto("/dashboard")
    await expect(page).toHaveURL(/\/login$/)
  })

  test("completes the email-link sign-in flow", async ({ page }) => {
    await page.goto("/login")

    await page.getByLabel("Email address").fill("Tester@Example.com")
    await page.getByRole("button", { name: "Send sign-in link" }).click()

    await expect(
      page.getByText("Magic link sent to tester@example.com. Open it in this browser.")
    ).toBeVisible()

    await page.goto("/login?mode=signIn&oobCode=playwright")

    await expect(page).toHaveURL(/\/dashboard$/)
    await expect(page.getByText("Authenticated as tester@example.com.")).toBeVisible()
    await expect(page.getByText("emailLink")).toBeVisible()
  })
})
