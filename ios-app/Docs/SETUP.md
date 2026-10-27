# Setup and running

Open `ios-app/Feedback.xcodeproj` from the LetsGrow monorepo. The Swift package in `ios-app/Modules/Package.swift` owns module dependencies.

Use Xcode 27 with Swift 6.2 or newer and the installed iOS 27 simulator runtime. SwiftLint is required for verification (`brew install swiftlint`); the lint helper also requires Python 3.

For agent setup, Xcode MCP connection checks, test configuration, local authentication, and CI, follow the [iOS harness overview](agent-harness.md). The [simulator skill](../.agents/skills/letsgrow-ios-run-simulator/SKILL.md) owns the execution procedure.

For manual development, select the `Feedback Localhost` scheme and an iOS simulator in Xcode, then Build & Run. Run the shared `UnitTests` plan from the same scheme. Other schemes target different configurations; `Feedback Production` is the production scheme.

Live authentication requires the Firebase configuration read from the app's Info.plist, populated through `App/Config/secrets.xcconfig`. Keep that file local and ignored by Git. See [configuration](CONFIGURATION.md) and the harness overview for local backend addressing and test-account login.

The backend owns the API contract. Regenerate the committed contract and both clients from the monorepo root using `./scripts/generate-api-artifacts.sh`; do not hand-edit generated Swift sources.
