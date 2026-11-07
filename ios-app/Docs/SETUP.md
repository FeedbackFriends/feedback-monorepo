# Setup and running

Open `ios-app/Feedback.xcodeproj` from the LetsGrow monorepo. The Swift package in `ios-app/Modules/Package.swift` owns module dependencies.

Use Xcode 27 with Swift 6.2 or newer and the installed iOS 27 simulator runtime. SwiftLint is required for verification (`brew install swiftlint`); the lint helper also requires Python 3.

For agent setup, Xcode MCP connection checks, test configuration, local authentication, and CI, follow the [iOS harness overview](agent-harness.md). The [simulator skill](../../.agents/skills/lg-ios-run-simulator/SKILL.md) owns the execution procedure.

For manual development, select the `Feedback Localhost` scheme and an iOS simulator in Xcode, then Build & Run. Run the shared `UnitTests` plan from the same scheme. Other schemes target different configurations; `Feedback Production` is the production scheme.

Live authentication requires the Firebase configuration read from the app's Info.plist, populated through `App/Config/secrets.xcconfig`. Keep that file local and ignored by Git. See [configuration](CONFIGURATION.md) and the harness overview for local backend addressing and test-account login.

The backend owns the API contract. Regenerate the committed contract and both clients from the monorepo root using `./scripts/generate-api-artifacts.sh`; do not hand-edit generated Swift sources.

## Project configuration format

`Feedback.xcodeproj/project.xcproj` is Xcode's native JSON project configuration. Xcode 27 or later is required to open it; Xcode 27.2 performed the migration from `project.pbxproj`. The `.xcodeproj` bundle, shared schemes, test plans, and command entry points retain their existing paths. The format permits trailing commas; use Xcode or format-aware tools when editing it.

Apple documents the conversion and rollback in [Updating your Xcode project configuration file format](https://developer.apple.com/documentation/xcode/updating-your-xcode-project-configuration-file-format). Its [open source format library](https://github.com/apple/xcode-project-format) describes the schema.

### Repository guidance in the navigator

The **Repository guidance** group mirrors paths from the monorepo root:
root/app `AGENTS.md` and READMEs, `docs/`, `tasks/`, `.agents/`, `.codex/`,
and the iOS/backend/web documentation directories. Only custom `lg-` skills appear from
root `.agents/skills/`; community skill packages are excluded.

These are explicit navigator groups with no target membership. They expose
checked-in documentation, approved screenshot baselines, skill metadata,
templates, references, and helpers without adding Sources or Resources.
Local secrets, untracked files, dependencies, build output, and generated
screenshots outside those documentation roots are excluded.

After adding guidance files to Git's index, moving files, or removing tasks, run
from the monorepo root:

```sh
python3 ios-app/scripts/sync-guidance-navigator.py
python3 ios-app/scripts/sync-guidance-navigator.py --check
```

The [refresh helper](../scripts/sync-guidance-navigator.py) reads `git ls-files`,
skips deleted files and valid aliases, and rejects broken aliases. It only
rewrites the Repository guidance group; target settings, other file groups,
schemes, and packages are preserved. New untracked files intentionally remain
invisible until staged and refreshed. This explicit inventory trades automatic
folder discovery for control over which repository files Xcode exposes.
