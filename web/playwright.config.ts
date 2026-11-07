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
    : [
        {
          command: "node tests/fixtures/upstream.ts",
          url: "http://127.0.0.1:3199/health",
          reuseExistingServer: false,
        },
        {
          command: `npm run dev -- --hostname 127.0.0.1 --port ${defaultPort}`,
          env: {
            ...process.env,
            NEXT_PUBLIC_LETSGROW_EARLY_ACCESS_URL:
              "https://form.typeform.com/to/RSs7TZAj",
            NEXT_PUBLIC_E2E_AUTH: "1",
            FEEDBACK_API_ORIGIN: "http://127.0.0.1:3199",
          },
          reuseExistingServer: false,
          timeout: 120 * 1000,
          url: defaultBaseURL,
        },
      ],
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
  ],
})
