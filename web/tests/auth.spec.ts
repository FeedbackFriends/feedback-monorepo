import { expect, test } from "@playwright/test"

test.describe("login and logout", () => {
  test("redirects unauthenticated visitors from the dashboard to login", async ({
    page,
  }) => {
    await page.goto("/dashboard")

    await expect(page).toHaveURL(/\/login$/)
    await expect(page.getByRole("heading", { name: "Log ind" })).toBeVisible()
  })

  test("signs in with email, persists the session, and signs out cleanly", async ({
    page,
  }) => {
    await page.goto("/login")

    await expect(page.getByRole("button", { name: /Google/ })).toHaveCount(0)
  await page.getByRole("button", { name: "Log ind med email", exact: true }).click()
  await page.getByLabel("Arbejdsmail").fill("playwright@example.com")
  await page.getByRole("button", { name: "Fortsæt", exact: true }).click()
  await page.getByLabel("Engangskode", { exact: true }).fill("123456")
  await page.getByRole("button", { name: "Bekræft kode" }).click()

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


test("email code supports invalid-code recovery, resend wait and changing email", async ({ page }) => {
  await page.route("**/api/leader/teams/context", route => route.fulfill({ json: { isOwner: false, managedTeams: [] } }))
  await page.route("**/api/leader/teams/leader-invitations", route => route.fulfill({ json: [] }))
  await page.goto("/login")
  await page.getByRole("button", { name: "Opret med email", exact: true }).click()
  await page.getByLabel("Dit navn").fill("Ada Lovelace")
  await page.getByLabel("Arbejdsmail").fill("ada@example.com")
  await page.getByRole("button", { name: "Fortsæt", exact: true }).click()
  await expect(page.getByRole("status")).toContainText("ada@example.com")
  await page.getByLabel("Engangskode", { exact: true }).fill("000000")
  await page.getByRole("button", { name: "Bekræft kode" }).click()
  await expect(page.getByRole("alert").filter({ hasText: "ugyldig eller udløbet" })).toBeVisible()
  await page.getByRole("button", { name: "Send ny kode" }).click()
  await expect(page.getByRole("alert").filter({ hasText: "Vent et minut" })).toBeVisible()
  await page.getByRole("button", { name: "Brug en anden e-mail" }).click()
  await expect(page.getByLabel("Arbejdsmail")).toBeEnabled()
  await page.getByRole("button", { name: "Fortsæt", exact: true }).click()
  await page.getByLabel("Engangskode", { exact: true }).fill("123456")
  await page.getByRole("button", { name: "Bekræft kode" }).click()
  await expect(page).toHaveURL(/\/dashboard$/)
  await expect(page.getByText("Ada Lovelace", { exact: true })).toBeVisible()
  await page.reload()
  await expect(page.getByText("Ada Lovelace", { exact: true })).toBeVisible()
})

test("pending personal invitations take precedence over creating an organization", async ({ page }) => {
  await page.route("**/api/leader/teams/context", route => route.fulfill({ json: { isOwner: false, managedTeams: [] } }))
  await page.route("**/api/leader/teams/leader-invitations", route => route.fulfill({ json: [
    { code: "personal", team: { id: "it", name: "IT", organizationName: "Acme" } },
  ] }))
  await page.goto("/login")
  await expect(page.getByRole("button", { name: /Google/ })).toHaveCount(0)
  await page.getByRole("button", { name: "Log ind med email", exact: true }).click()
  await page.getByLabel("Arbejdsmail").fill("playwright@example.com")
  await page.getByRole("button", { name: "Fortsæt", exact: true }).click()
  await page.getByLabel("Engangskode", { exact: true }).fill("123456")
  await page.getByRole("button", { name: "Bekræft kode" }).click()
  await expect(page.getByRole("link", { name: "Acme · IT" })).toBeVisible()
  await expect(page.getByRole("button", { name: "Opret organisation og team" })).not.toBeVisible()
})


test("existing users can log in with email without entering a name", async ({ page }) => {
  await page.goto("/login")
  await expect(page.getByLabel("Arbejdsmail")).not.toBeVisible()
  await page.getByRole("button", { name: "Log ind med email", exact: true }).click()
  await expect(page.getByLabel("Dit navn")).not.toBeVisible()
  await page.getByLabel("Arbejdsmail").fill("existing@example.com")
  await page.getByRole("button", { name: "Fortsæt", exact: true }).click()
  await page.getByLabel("Engangskode", { exact: true }).fill("123456")
  await page.getByRole("button", { name: "Bekræft kode" }).click()
  await expect(page).toHaveURL(/\/dashboard$/)
})
