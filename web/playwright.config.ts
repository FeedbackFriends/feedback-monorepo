import { defineConfig, devices } from "@playwright/test"

const defaultPort = 3100
const defaultBaseURL =
  process.env.PLAYWRIGHT_BASE_URL ?? `http://127.0.0.1:${defaultPort}`

export default defineConfig({
  testDir: "./tests",
  fullyParallel: true,
  reporter: "list",
  use: {
    baseURL: defaultBaseURL,
    trace: "retain-on-failure",
  },
  webServer: process.env.PLAYWRIGHT_BASE_URL
    ? undefined
    : {
        command: `npm run dev -- --hostname 127.0.0.1 --port ${defaultPort}`,
        env: {
          ...process.env,
          NEXT_PUBLIC_E2E_AUTH: "1",
        },
        reuseExistingServer: false,
        timeout: 120 * 1000,
        url: defaultBaseURL,
      },
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
  ],
})
