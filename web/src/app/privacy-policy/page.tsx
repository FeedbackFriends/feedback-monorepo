import type { Metadata } from "next"
import MarketingShell from "@/components/layout/MarketingShell"

export const metadata: Metadata = {
  title: "Privacy Policy | Lets Grow",
}

export default function PrivacyPolicyPage() {
  return (
    <MarketingShell>
      <div className="container mx-auto max-w-4xl px-6 py-6 sm:px-8 sm:py-12">
        <div className="space-y-8">
          <div>
            <h1 className="mb-4 text-3xl font-bold sm:text-4xl">
              Privacy Policy
            </h1>
            <p className="text-muted-foreground">
              Effective Date: April 14, 2025
            </p>
          </div>

          <p className="text-muted-foreground">
            We at Lets Grow value your privacy and are committed to protecting
            your personal data. This privacy policy outlines how we collect,
            use, and protect your information when you use our app.
          </p>

          <section className="space-y-4">
            <h2 className="text-2xl font-semibold">1. Data Collection</h2>
            <div className="space-y-4">
              <div>
                <h3 className="mb-2 text-l font-medium">
                  Personal Data We Collect
                </h3>
                <p className="text-muted-foreground">
                  We collect the following personal data when you use our app:
                </p>
                <ul className="list-disc space-y-2 pl-6 text-muted-foreground">
                  <li>Name</li>
                  <li>Email address</li>
                  <li>Phone number</li>
                </ul>
              </div>

              <div>
                <h3 className="mb-2 text-l font-medium">Sensitive Data</h3>
                <p className="text-muted-foreground">
                  We do not collect any sensitive data, such as health
                  information or payment details.
                </p>
              </div>

              <div>
                <h3 className="mb-2 text-l font-medium">
                  Automatic Data Collection
                </h3>
                <p className="text-muted-foreground">
                  We automatically collect certain data related to your use of
                  our app, including:
                </p>
                <ul className="list-disc space-y-2 pl-6 text-muted-foreground">
                  <li>Device information</li>
                  <li>Usage data within the app</li>
                </ul>
              </div>
            </div>
          </section>

          <section className="space-y-4">
            <h2 className="text-2xl font-semibold">2. Data Usage</h2>
            <div className="space-y-4">
              <div>
                <h3 className="mb-2 text-l font-medium">How We Use Your Data</h3>
                <p className="text-muted-foreground">
                  We use the data we collect to:
                </p>
                <ul className="list-disc space-y-2 pl-6 text-muted-foreground">
                  <li>Improve the performance and functionality of the app</li>
                  <li>
                    Conduct analytics to enhance user experience and
                    troubleshoot issues
                  </li>
                </ul>
              </div>

              <div>
                <h3 className="mb-2 text-l font-medium">Data Sharing</h3>
                <p className="text-muted-foreground">
                  We do not share your data with third parties.
                </p>
              </div>
            </div>
          </section>

          <section className="space-y-4">
            <h2 className="text-2xl font-semibold">3. Third-Party Integrations</h2>
            <div className="space-y-4">
              <div>
                <p className="text-muted-foreground">
                  Our app uses third-party services for analytics and crash
                  reporting.
                </p>
              </div>
            </div>
          </section>

          <section className="space-y-4">
            <h2 className="text-2xl font-semibold">4. Data Storage &amp; Security</h2>
            <div className="space-y-4">
              <div>
                <h3 className="mb-2 text-l font-medium">Data Storage</h3>
                <p className="text-muted-foreground">
                  Your data is stored on a server that we own and is located
                  within the European Union.
                </p>
              </div>
            </div>
          </section>

          <section className="space-y-4">
            <h2 className="text-2xl font-semibold">5. User Rights</h2>
            <div className="space-y-4">
              <h3 className="mb-2 text-l font-medium">GDPR Rights</h3>
              <p className="text-muted-foreground">
                Under the General Data Protection Regulation (GDPR), users have
                the right to:
              </p>
              <ul className="list-disc space-y-2 pl-6 text-muted-foreground">
                <li>Access their personal data</li>
                <li>Correct or update their data</li>
                <li>Delete their data</li>
                <li>Opt-out of data collection</li>
              </ul>
              <p className="mt-2 text-muted-foreground">
                Please contact us via email at{" "}
                <a
                  href="mailto:nicolaidam96@gmail.com"
                  className="text-primary hover:underline"
                >
                  nicolaidam96@gmail.com
                </a>{" "}
                if you wish to exercise these rights.
              </p>
            </div>
          </section>

          <section className="space-y-4">
            <h2 className="text-2xl font-semibold">6. Children&apos;s Privacy</h2>
            <p className="text-muted-foreground">
              Our app is not intended for children under the age of 13, and we
              do not knowingly collect data from children.
            </p>
          </section>

          <section className="space-y-4">
            <h2 className="text-2xl font-semibold">7. Cookies &amp; Tracking</h2>
            <p className="text-muted-foreground">
              We do not use cookies or any other tracking technologies in our
              app.
            </p>
          </section>

          <section className="space-y-4">
            <h2 className="text-2xl font-semibold">
              8. Changes to This Privacy Policy
            </h2>
            <p className="text-muted-foreground">
              We may update this privacy policy from time to time. If we make
              significant changes, we will notify you through the app or via
              email. It is your responsibility to review this policy
              periodically to stay informed about how we are protecting your
              data.
            </p>
          </section>
        </div>
      </div>
    </MarketingShell>
  )
}
