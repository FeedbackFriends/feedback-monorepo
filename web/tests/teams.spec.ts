import { expect, test, type Page } from "@playwright/test"

async function mockTeams(page: Page, existing = false) {
  let organization: { id: string; name: string } | undefined = existing
    ? { id: "org", name: "Acme" }
    : undefined
  const teams = existing
    ? [
        {
          id: "it",
          organizationId: "org",
          organizationName: "Acme",
          name: "IT",
        },
      ]
    : []
  let pending = [
    { id: "request", name: "Ada", status: "Pending", team: teams[0] },
  ]
  let members: { accountId: string; name: string }[] = []
  let code = "original-code"
  await page.route("**/api/leader/teams/**", async (route) => {
    expect(route.request().headers().authorization).toBe(
      "Bearer playwright-test-token",
    )
    const path = new URL(route.request().url()).pathname.replace(
      "/api/leader/teams",
      "",
    )
    const body =
      route.request().method() === "POST" && route.request().postData()
        ? route.request().postDataJSON()
        : null
    if (path === "/leader-invitations") return route.fulfill({ json: [] })
    if (path === "/context")
      return route.fulfill({
        json: { organization, isOwner: true, managedTeams: teams },
      })
    if (path === "/organizations") {
      organization = { id: body.id, name: body.name }
      teams.push({
        id: body.teamId,
        organizationId: body.id,
        organizationName: body.name,
        name: body.teamName,
      })
      return route.fulfill({
        json: { organization, isOwner: true, managedTeams: teams },
      })
    }
    if (path.startsWith("/organizations/")) {
      const team = {
        id: body.id,
        name: body.name,
        organizationId: organization!.id,
        organizationName: organization!.name,
      }
      teams.push(team)
      return route.fulfill({ json: team })
    }
    if (path.endsWith("/suggestions/inbox")) return route.fulfill({ json: { suggestions: [], responsiblePeople: [] } })
    if (path.endsWith("/suggestions/reports")) return route.fulfill({ json: [] })
    if (path.endsWith("/leaders"))
      return route.fulfill({ json: { leaders: [], invitations: [] } })
    const team = teams.find((team) => path.split("/")[1] === team.id)!
    if (path.endsWith("/approve")) {
      members = [{ accountId: "ada", name: "Ada" }]
      pending = []
    }
    if (path.endsWith("/reject")) pending = []
    if (path.endsWith("/members/ada")) members = []
    if (path.endsWith("/invite")) code = "rotated-code"
    return route.fulfill({
      json: {
        team,
        inviteCode: `${team.id}-${code}`,
        pendingRequests: team.id === "it" ? pending : [],
        members: team.id === "it" ? members : [],
        memberCount: team.id === "it" ? members.length : 0,
      },
    })
  })
}
async function login(page: Page) {
  await page.goto("/login")
  await page.getByRole("button", { name: "Fortsæt med Google" }).click()
  await expect(page).toHaveURL(/\/dashboard$/)
}

test("leader creates organization and additional teams and switches context", async ({
  page,
}) => {
  await mockTeams(page)
  await login(page)
  await page.getByLabel("Dit navn").fill("Ada")
  await page.getByLabel("Organisation", { exact: true }).fill("Acme")
  await page.getByLabel("Teamnavn").fill("IT")
  await page.getByRole("button", { name: "Opret organisation og team" }).click()
  await expect(
    page.getByRole("heading", { name: "IT", exact: true }),
  ).toBeVisible({ timeout: 15000 })
  await page.getByRole("link", { name: "Alle teams" }).click()
  await expect(
    page.getByRole("heading", { name: "Teams", exact: true }),
  ).toBeVisible()
  await expect(page.getByLabel("Invitationslink")).not.toBeVisible()
  await page.screenshot({
    path: "test-results/teams-overview.png",
    fullPage: true,
  })
  await page.getByRole("button", { name: "Opret team", exact: true }).click()
  await page.getByRole("dialog").getByLabel("Teamnavn").fill("Marketing")
  await page
    .getByRole("dialog")
    .getByRole("button", { name: "Opret team", exact: true })
    .click()
  await expect(
    page.getByRole("heading", { name: "Marketing", exact: true }),
  ).toBeVisible()
  await page.getByRole("link", { name: "Alle teams" }).click()
  await page.getByRole("link", { name: "Åbn IT", exact: true }).click()
  await expect(
    page.getByRole("heading", { name: "IT", exact: true }),
  ).toBeVisible()
  await page.reload()
  await expect(
    page.getByRole("heading", { name: "IT", exact: true }),
  ).toBeVisible()
})

test("leader approves rejects removes and rotates invitations on mobile", async ({
  page,
}) => {
  await page.setViewportSize({ width: 390, height: 844 })
  await mockTeams(page, true)
  await login(page)
  await page.getByRole("link", { name: "Åbn IT" }).click()
  await page.getByRole("button", { name: "Godkend", exact: true }).click()
  await expect(
    page.getByRole("heading", { name: "Medlemmer (1)" }),
  ).toBeVisible()
  await page.getByRole("button", { name: "Fjern", exact: true }).click()
  await expect(page.getByRole("alertdialog")).toBeVisible()
  await page.getByRole("button", { name: "Annuller" }).click()
  await expect(
    page.getByRole("heading", { name: "Medlemmer (1)" }),
  ).toBeVisible()
  await page.getByRole("button", { name: "Fjern", exact: true }).click()
  await page.getByRole("button", { name: "Fjern medlem", exact: true }).click()
  await expect(
    page.getByRole("heading", { name: "Medlemmer (0)" }),
  ).toBeVisible()
  await page.getByRole("button", { name: "Invitér medarbejdere" }).click()
  await page.getByRole("button", { name: "Nyt invitationslink" }).click()
  await page.keyboard.press("Escape")
  await expect(page.getByRole("alertdialog")).not.toBeVisible()
  await expect(
    page.getByRole("button", { name: "Nyt invitationslink" }),
  ).toBeFocused()
  await expect(page.getByLabel("Invitationslink")).toHaveValue(/original-code$/)
  await page.getByRole("button", { name: "Nyt invitationslink" }).click()
  await page.screenshot({ path: "test-results/team-invite-mobile.png" })
  await page.getByRole("button", { name: "Opret nyt link" }).click()
  await expect(page.getByLabel("Invitationslink")).toHaveValue(/rotated-code$/)
  await page.getByRole("dialog").getByRole("button", { name: "Close" }).click()
  expect(
    await page.evaluate(
      () => document.documentElement.scrollWidth <= window.innerWidth,
    ),
  ).toBe(true)
  await page.screenshot({
    path: "test-results/teams-mobile.png",
    fullPage: true,
  })
})

test("rejection removes applicant and context failures offer retry", async ({
  page,
}) => {
  await mockTeams(page, true)
  await login(page)
  await page.getByRole("link", { name: "Åbn IT" }).click()
  await page.getByRole("button", { name: "Afvis", exact: true }).click()
  await expect(
    page.getByRole("heading", { name: /Afventer godkendelse/ }),
  ).not.toBeVisible()
  await page.screenshot({
    path: "test-results/teams-desktop.png",
    fullPage: true,
  })
  await page.route("**/api/leader/teams/context", (route) =>
    route.fulfill({ status: 503, json: {} }),
  )
  await page.goto("/dashboard")
  await expect(
    page.getByRole("alert").filter({ hasText: "Der opstod en serverfejl" }),
  ).toBeVisible()
  await expect(page.getByRole("button", { name: "Prøv igen" })).toBeVisible()
})

test("team invitation opens iOS and retains manual installation code", async ({
  page,
}) => {
  await page.goto("/team-invite/example-code")
  await expect(page.getByRole("link", { name: "Åbn i appen" })).toHaveAttribute(
    "href",
    "letsgrow://team-invite?code=example-code",
  )
  await expect(page.getByText("example-code", { exact: true })).toBeVisible()
  await expect(page.getByRole("link", { name: "Hent iOS-appen" })).toBeVisible()
})

test("production host routes separate landing and leader application", async ({
  request,
}) => {
  const app = await request.get("/", {
    headers: { host: "app.letsgrow.dk" },
    maxRedirects: 0,
  })
  expect(app.status()).toBe(307)
  expect(app.headers().location).toContain("/dashboard")
  const marketing = await request.get("/dashboard", {
    headers: { host: "letsgrow.dk" },
    maxRedirects: 0,
  })
  expect(marketing.headers().location).toBe("https://app.letsgrow.dk/dashboard")
})

test("relay requires authentication and cannot forward unrelated API paths", async ({
  request,
}) => {
  expect((await request.get("/api/leader/teams/context")).status()).toBe(401)
  expect(
    (
      await request.get("/api/leader/account", {
        headers: { authorization: "Bearer test" },
      })
    ).status(),
  ).toBe(404)
})

test("creation retries retain the submission IDs after a network failure", async ({
  page,
}) => {
  await mockTeams(page)
  let submission: unknown
  let calls = 0
  await page.route("**/api/leader/teams/organizations", async (route) => {
    const body = route.request().postDataJSON()
    if (++calls === 1) {
      submission = body
      return route.abort()
    }
    expect(body).toEqual(submission)
    return route.fallback()
  })
  await login(page)
  await page.getByLabel("Dit navn").fill("Ada")
  await page.getByLabel("Organisation", { exact: true }).fill("Acme")
  await page.getByLabel("Teamnavn").fill("IT")
  await page.getByRole("button", { name: "Opret organisation og team" }).click()
  await expect(page.getByRole("button", { name: "Prøv igen" })).toBeVisible()
  await page.getByRole("button", { name: "Opret organisation og team" }).click()
  await expect(
    page.getByRole("heading", { name: "IT", exact: true }),
  ).toBeVisible()
})

test("sidebar collapses on desktop and opens account navigation on mobile", async ({
  page,
}) => {
  await mockTeams(page, true)
  await login(page)
  await expect(
    page.getByRole("link", { name: "Teams", exact: true }),
  ).toBeVisible()
  await page.getByRole("button", { name: "Vis eller skjul navigation" }).click()
  await expect(
    page.locator('[data-slot="sidebar"][data-collapsible="icon"]'),
  ).toBeVisible()
  await expect(
    page.getByRole("heading", { name: "Teams", exact: true }),
  ).toBeVisible()
  await page.getByRole("button", { name: "Vis eller skjul navigation" }).click()
  await page.setViewportSize({ width: 390, height: 844 })
  await expect(
    page.getByRole("button", { name: "Log ud", exact: true }),
  ).not.toBeVisible()
  await page.getByRole("button", { name: "Vis eller skjul navigation" }).click()
  await expect(page.getByRole("dialog")).toBeVisible()
  await expect(
    page.getByText("Playwright Test User", { exact: true }),
  ).toBeVisible()
  await page.screenshot({ path: "test-results/teams-mobile-sidebar.png" })
  await page.keyboard.press("Escape")
  await expect(page.getByRole("dialog")).not.toBeVisible()
  await page.getByRole("button", { name: "Vis eller skjul navigation" }).click()
  await page
    .getByRole("dialog")
    .getByRole("link", { name: "Teams", exact: true })
    .click()
  await expect(page.getByRole("dialog")).not.toBeVisible()
  await page.getByRole("button", { name: "Vis eller skjul navigation" }).click()
  await page.getByRole("button", { name: "Log ud", exact: true }).click()
  await expect(page).toHaveURL(/\/login$/)
})

test("employees overview manages requests across teams without mixing membership", async ({
  page,
}) => {
  await mockTeams(page, true)
  const product = {
    id: "product",
    name: "Produkt",
    organizationId: "org",
    organizationName: "Acme",
  }
  await page.route("**/api/leader/teams/context", (route) =>
    route.fulfill({
      json: {
        organization: { id: "org", name: "Acme" },
        managedTeams: [{ ...product, id: "it", name: "IT" }, product],
      },
    }),
  )
  await page.route("**/api/leader/teams/product", (route) =>
    route.fulfill({
      json: {
        team: product,
        inviteCode: "product-code",
        pendingRequests: [],
        members: [{ accountId: "bo", name: "Bo" }],
        memberCount: 1,
      },
    }),
  )
  await login(page)
  await page.getByRole("link", { name: "Medarbejdere", exact: true }).click()
  await expect(page).toHaveURL(/\/dashboard\/employees$/)
  await expect(
    page.getByRole("link", { name: "Medarbejdere", exact: true }),
  ).toHaveAttribute("aria-current", "page")
  const ada = page.getByRole("row").filter({ hasText: "Ada" })
  const bo = page.getByRole("row").filter({ hasText: "Bo" })
  await expect(ada).toContainText("Afventer godkendelse")
  await expect(bo).toContainText("Produkt")
  await ada.getByRole("button", { name: "Godkend", exact: true }).click()
  await expect(ada).toContainText("Aktiv")
  await expect(bo).toContainText("Aktiv")
  await page.screenshot({
    path: "test-results/employees-desktop.png",
    fullPage: true,
  })
  await ada.getByRole("button", { name: "Fjern", exact: true }).click()
  await page.getByRole("button", { name: "Annuller" }).click()
  await expect(ada).toBeVisible()
  await ada.getByRole("button", { name: "Fjern", exact: true }).click()
  await page
    .getByRole("button", { name: "Fjern medarbejder", exact: true })
    .click()
  await expect(ada).not.toBeVisible()
  await expect(bo).toBeVisible()
  await page.setViewportSize({ width: 390, height: 844 })
  await page.screenshot({
    path: "test-results/employees-mobile.png",
    fullPage: true,
  })
  expect(
    await page.evaluate(
      () => document.documentElement.scrollWidth <= window.innerWidth,
    ),
  ).toBe(true)
  await bo.getByRole("link", { name: "Produkt", exact: true }).click()
  await expect(
    page.getByRole("heading", { name: "Produkt", exact: true }),
  ).toBeVisible()
})

test("employee load errors offer retry rather than a misleading empty list", async ({
  page,
}) => {
  await mockTeams(page, true)
  let fail = true
  await page.route("**/api/leader/teams/it", (route) =>
    fail ? route.fulfill({ status: 503, json: {} }) : route.fallback(),
  )
  await login(page)
  await page.goto("/dashboard/employees")
  await expect(
    page.getByRole("alert").filter({ hasText: "Der opstod en serverfejl" }),
  ).toContainText("Der opstod en serverfejl")
  await expect(page.getByText(/Ingen medarbejdere endnu/)).not.toBeVisible()
  fail = false
  await page.getByRole("button", { name: "Prøv igen" }).click()
  await expect(page.getByRole("row").filter({ hasText: "Ada" })).toBeVisible()
  await page.getByRole("button", { name: "Afvis", exact: true }).click()
  await expect(
    page.getByRole("row").filter({ hasText: "Ada" }),
  ).not.toBeVisible()
  await expect(page.getByText(/Ingen medarbejdere endnu/)).toBeVisible()
})

test("team creation can be canceled and a direct team URL handles failure and retry", async ({
  page,
}) => {
  await mockTeams(page, true)
  await login(page)
  await page.getByRole("button", { name: "Opret team", exact: true }).click()
  await page.keyboard.press("Escape")
  await expect(page.getByRole("dialog")).not.toBeVisible()
  await expect(page).toHaveURL(/\/dashboard$/)
  let fail = true
  await page.route("**/api/leader/teams/it", (route) =>
    fail ? route.fulfill({ status: 503, json: {} }) : route.fallback(),
  )
  await page.goto("/dashboard/teams/it")
  await expect(
    page.getByRole("alert").filter({ hasText: "Der opstod en serverfejl" }),
  ).toContainText("Der opstod en serverfejl")
  fail = false
  await page.getByRole("button", { name: "Prøv igen" }).click()
  await expect(
    page.getByRole("heading", { name: "IT", exact: true }),
  ).toBeVisible()
  await page.reload()
  await expect(
    page.getByRole("heading", { name: "IT", exact: true }),
  ).toBeVisible()
})

test("owner manages leaders and assigned leader loses controls on revocation", async ({
  page,
}) => {
  await mockTeams(page, true)
  let leaders = [{ accountId: "bo", email: "bo@example.com" }]
  let invitations: {
    id: string
    email: string
    code: string
    expiresAt: number
  }[] = []
  await page.route("**/api/leader/teams/it/leaders**", (route) => {
    const request = route.request()
    if (request.method() === "POST")
      invitations = [
        {
          ...request.postDataJSON(),
          code: "personal-code",
          expiresAt: Date.now() + 100000,
        },
      ]
    if (request.method() === "DELETE") {
      if (request.url().includes("/invitations/")) invitations = []
      else leaders = []
    }
    return route.fulfill({ json: { leaders, invitations } })
  })
  await login(page)
  await page.getByRole("link", { name: "Åbn IT" }).click()
  await page.getByRole("button", { name: "Invitér leder", exact: true }).click()
  await page.getByLabel("Lederens e-mail").fill("ada@example.com")
  await page.getByRole("button", { name: "Send lederinvitation" }).click()
  await expect(page.getByLabel("ada@example.com", { exact: true })).toHaveValue(
    /\/leader-invite\/personal-code$/,
  )
  await page.keyboard.press("Escape")
  await page.getByRole("button", { name: "Tilbagekald" }).click()
  await page.getByRole("button", { name: "Fjern leder", exact: true }).click()
  await page.getByRole("button", { name: "Fjern adgang" }).click()
  await expect(page.getByText("Ingen ekstra ledere endnu.")).toBeVisible()
  await page.setViewportSize({ width: 390, height: 844 })
  await page.screenshot({
    path: "test-results/team-leaders-mobile.png",
    fullPage: true,
  })
  await page.route("**/api/leader/teams/context", (route) =>
    route.fulfill({
      json: {
        organization: { id: "org", name: "Acme" },
        isOwner: false,
        managedTeams: [
          {
            id: "it",
            name: "IT",
            organizationId: "org",
            organizationName: "Acme",
          },
        ],
      },
    }),
  )
  await page.goto("/dashboard")
  await expect(page.getByRole("link", { name: "Åbn IT" })).toBeVisible()
  await expect(page.getByRole("button", { name: "Opret team" })).toHaveCount(0)
  await page.getByRole("link", { name: "Åbn IT" }).click()
  await expect(
    page.getByRole("button", { name: "Invitér medarbejdere" }),
  ).toBeVisible()
  await expect(
    page.getByRole("button", { name: "Invitér leder", exact: true }),
  ).toHaveCount(0)
  await page.route("**/api/leader/teams/it", (route) =>
    route.fulfill({ status: 403, json: {} }),
  )
  await page.getByRole("button", { name: "Opdater", exact: true }).click()
  await expect(
    page.getByRole("heading", { name: "IT", exact: true }),
  ).toHaveCount(0)
  await expect(
    page.getByRole("button", { name: "Invitér medarbejdere" }),
  ).toHaveCount(0)
})

test("personal leader link preserves invitation through Google login", async ({
  page,
}) => {
  await mockTeams(page, true)
  await page.route("**/api/leader/teams/leader-invitations/**", (route) => {
    if (route.request().method() === "POST") {
      expect(route.request().postDataJSON()).toEqual({ code: "personal-code" })
      return route.fulfill({
        json: { isOwner: false, managedTeams: [{ id: "it" }] },
      })
    }
    return route.fulfill({
      json: {
        email: "ada@example.com",
        team: { id: "it", name: "IT", organizationName: "Acme" },
      },
    })
  })
  await page.goto("/leader-invite/personal-code")
  await page.getByRole("button", { name: "Fortsæt med Google" }).click()
  await expect(page).toHaveURL(/\/leader-invite\/personal-code$/)
  await expect(
    page.getByText(/Invitationen gælder ada@example.com/),
  ).toBeVisible()
  await page.getByRole("button", { name: "Acceptér invitation" }).click()
  await expect(page).toHaveURL(/\/dashboard\/teams\/it$/)
})

test("invalid leader links and wrong Google accounts show clear errors", async ({
  page,
}) => {
  await page.route("**/api/leader/teams/leader-invitations/**", (route) =>
    route.fulfill({ status: 404, json: {} }),
  )
  await page.goto("/leader-invite/expired")
  await page.getByRole("button", { name: "Fortsæt med Google" }).click()
  await expect(page.getByText(/Invitationen er udløbet/)).toBeVisible()
  await expect(
    page.getByRole("button", { name: "Acceptér invitation" }),
  ).toHaveCount(0)
  await page.route("**/api/leader/teams/leader-invitations/valid", (route) =>
    route.fulfill({
      json: {
        email: "ada@example.com",
        team: { id: "it", name: "IT", organizationName: "Acme" },
      },
    }),
  )
  await page.route("**/api/leader/teams/leader-invitations/accept", (route) =>
    route.fulfill({ status: 403, json: {} }),
  )
  await page.goto("/leader-invite/valid")
  await page.getByRole("button", { name: "Acceptér invitation" }).click()
  await expect(
    page.getByText(/Log ind med den verificerede e-mail/),
  ).toBeVisible()
})

test("a response from a previous login cannot replace the current team's data", async ({ page }) => {
  await mockTeams(page, true)
  await login(page)
  await page.goto("/dashboard/teams/it")
  await expect(page.getByRole("button", { name: "Godkend", exact: true })).toBeVisible()
  let release!: () => void
  const pending = new Promise<void>((resolve) => { release = resolve })
  let started!: () => void
  const requested = new Promise<void>((resolve) => { started = resolve })
  await page.route("**/api/leader/teams/it/requests/request/approve", async (route) => {
    started()
    await pending
    await route.fulfill({ json: {
      team: { id: "it", name: "OLD RESPONSE", organizationName: "Acme", organizationId: "org" },
      inviteCode: "old", pendingRequests: [], members: [], memberCount: 0,
    } }).catch(() => {}) // The old fetch is intentionally canceled on logout.
  })
  try {
    await page.getByRole("button", { name: "Godkend", exact: true }).click()
    await requested
    await page.getByRole("button", { name: "Log ud", exact: true }).click()
    await expect(page).toHaveURL(/\/login$/)
    await page.getByRole("button", { name: "Fortsæt med Google" }).click()
    await expect(page).toHaveURL(/\/dashboard$/)
    await page.goto("/dashboard/teams/it")
    await expect(page.getByRole("heading", { name: "IT", exact: true })).toBeVisible()
    release()
    await expect(page.getByRole("button", { name: "Godkend", exact: true })).toBeVisible()
    await expect(page.getByRole("heading", { name: "OLD RESPONSE", exact: true })).toHaveCount(0)
  } finally { release() }
})

test("team invitation dialog restores keyboard focus after Escape", async ({ page }) => {
  await mockTeams(page, true)
  await login(page)
  await page.goto("/dashboard/teams/it")
  const trigger = page.getByRole("button", { name: "Invitér medarbejdere", exact: true })
  await trigger.focus()
  await page.keyboard.press("Enter")
  await expect(page.getByRole("dialog")).toBeVisible()
  await page.keyboard.press("Escape")
  await expect(page.getByRole("dialog")).toHaveCount(0)
  await expect(trigger).toBeFocused()
})

test("dashboard error boundary retries the real rendering path", async ({ page }) => {
  await mockTeams(page, true)
  await login(page)
  await page.route("**/api/leader/teams/it", (route) => route.fulfill({ json: { team: null } }))
  await page.goto("/dashboard/teams/it")
  await expect(page.getByText("Siden kunne ikke vises", { exact: true })).toBeVisible()
  await page.unroute("**/api/leader/teams/it")
  await page.getByRole("button", { name: "Prøv igen", exact: true }).click()
  await expect(page.getByRole("heading", { name: "IT", exact: true })).toBeVisible()
})

test("leader reviews anonymous suggestion reports and handles removal failures and revoked access", async ({ page }) => {
  await mockTeams(page, true)
  let reports = [
    { id: "first", problem: "Identificerende forslag", impact: "Personoplysninger", solution: null },
    { id: "second", problem: "Personangreb", impact: "Utryghed", solution: "Fjern navne" },
  ]
  let failRemoval = true
  let denied = false
  await page.route("**/api/leader/teams/it/suggestions/**", async (route) => {
    if (route.request().url().endsWith("/inbox")) return route.fallback()
    if (denied) return route.fulfill({ status: 403, json: { userTitle: "Ingen adgang", userMessage: "Du har ikke længere adgang til teamet." } })
    if (route.request().method() === "POST") {
      const id = new URL(route.request().url()).pathname.split("/").at(-2)
      const { remove } = route.request().postDataJSON()
      if (remove && failRemoval) return route.fulfill({ status: 503, json: { userTitle: "Prøv igen", userMessage: "Forslaget kunne ikke fjernes. Prøv igen." } })
      reports = reports.filter((item) => item.id !== id)
    }
    return route.fulfill({ json: reports })
  })
  await login(page)
  await page.getByRole("link", { name: "Åbn IT" }).click()
  const section = page.getByRole("region", { name: "Rapporterede forslag" })
  await expect(section.getByText("Identificerende forslag", { exact: true })).toBeVisible()
  await section.getByRole("row").filter({ hasText: "Identificerende forslag" }).getByRole("button", { name: "Behold forslag" }).click()
  await expect(section.getByText("Identificerende forslag", { exact: true })).not.toBeVisible()
  await section.getByRole("button", { name: "Fjern forslag" }).click()
  await page.getByRole("alertdialog").getByRole("button", { name: "Annuller" }).click()
  await expect(section.getByText("Personangreb", { exact: true })).toBeVisible()
  await section.getByRole("button", { name: "Fjern forslag" }).click()
  await page.getByRole("alertdialog").getByRole("button", { name: "Fjern forslag", exact: true }).click()
  await expect(section.getByRole("alert")).toContainText("Forslaget kunne ikke fjernes")
  await expect(section.getByText("Personangreb", { exact: true })).toBeVisible()
  failRemoval = false
  await section.getByRole("button", { name: "Fjern forslag" }).click()
  await page.getByRole("alertdialog").getByRole("button", { name: "Fjern forslag", exact: true }).click()
  await expect(section.getByText("Ingen forslag afventer gennemgang.")).toBeVisible()
  reports = [{ id: "third", problem: "Beskyttet indhold", impact: "Skal ryddes ved mistet adgang", solution: null }]
  await section.getByRole("button", { name: "Opdater rapporter" }).click()
  await expect(section.getByText("Beskyttet indhold", { exact: true })).toBeVisible()
  denied = true
  await section.getByRole("button", { name: "Opdater rapporter" }).click()
  await expect(section.getByText("Beskyttet indhold", { exact: true })).not.toBeVisible()
  await expect(section.getByRole("alert")).toContainText("Du har ikke længere adgang")
})


test("leader publishes and revises explained decisions with retry identity and clears denied content", async ({ page }) => {
  await mockTeams(page, true)
  const suggestion = { id: "idea", problem: "Kortere møder", impact: "Mere tid til fokus", hasFiveSupporters: true,
    supportedByMe: false, mine: false, decisions: [] as Record<string, unknown>[] }
  let submission: Record<string, unknown> | undefined
  let attempts = 0
  let denied = false
  await page.route("**/api/leader/teams/it/suggestions/inbox", (route) => denied
    ? route.fulfill({ status: 403, json: {} })
    : route.fulfill({ json: { suggestions: [suggestion], responsiblePeople: [{ accountId: "owner", name: "Ada" }, { accountId: "leader", email: "grace@example.com" }] } }))
  await page.route("**/api/leader/teams/it/suggestions/idea/decisions", (route) => {
    const input = route.request().postDataJSON()
    if (++attempts === 1) {
      submission = input
      return route.abort()
    }
    if (attempts === 2) expect(input).toEqual(submission)
    expect(input.expectedRevision).toBe(suggestion.decisions.length)
    suggestion.decisions.unshift({ id: input.id, revision: input.expectedRevision + 1, status: input.status,
      explanation: input.explanation, responsibleName: input.responsibleName, followUpDate: input.followUpDate, publishedAt: 1794297600000 })
    return route.fulfill({ json: { suggestions: [suggestion], responsiblePeople: [{ accountId: "owner", name: "Ada" }, { accountId: "leader", email: "grace@example.com" }] } })
  })
  await login(page)
  await page.getByRole("link", { name: "Åbn IT" }).click()
  const inbox = page.getByRole("region", { name: "Forslag og beslutninger" })
  await expect(inbox.getByText("5+ støtter", { exact: true })).toBeVisible()
  await inbox.getByRole("button", { name: "Giv svar" }).click()
  const dialog = page.getByRole("dialog")
  const publish = dialog.getByRole("button", { name: "Offentliggør svar", exact: true })
  await expect(publish).toBeDisabled()
  await dialog.getByLabel("Beslutning", { exact: false }).selectOption("Planned")
  await dialog.getByLabel("Begrundelse og næste skridt").fill("Vi planlægger kortere møder")
  await dialog.getByLabel("Ansvarlig person").selectOption("owner")
  await expect(dialog.getByLabel("Ansvarliges navn til teamet")).toHaveValue("Ada")
  await expect(publish).toBeDisabled()
  await dialog.getByLabel("Næste opfølgning").fill("2099-01-01")
  await publish.click()
  await expect(dialog.getByRole("alert")).toBeVisible()
  await publish.click()
  await expect(dialog).not.toBeVisible()
  await expect(inbox.getByText("Seneste svar: Planlagt", { exact: true })).toBeVisible()
  await inbox.getByRole("button", { name: "Revider svar" }).click()
  await dialog.getByLabel("Beslutning", { exact: false }).selectOption("Declined")
  await dialog.getByLabel("Begrundelse og næste skridt").fill("Kunden har brug for mødet")
  await dialog.getByLabel("Ansvarlig person").selectOption({ label: "grace@example.com" })
  await dialog.getByLabel("Ansvarliges navn til teamet").fill("Grace")
  await dialog.getByRole("button", { name: "Offentliggør svar", exact: true }).click()
  await expect(inbox.getByText("Seneste svar: Afvist", { exact: true })).toBeVisible()
  await expect(inbox.getByText("Tidligere svar: Planlagt", { exact: true })).toBeVisible()
  denied = true
  await inbox.getByRole("button", { name: "Opdater forslag" }).click()
  await expect(inbox.getByText("Kortere møder", { exact: true })).toHaveCount(0)
  await expect(inbox.getByRole("button", { name: "Revider svar" })).toHaveCount(0)
})
