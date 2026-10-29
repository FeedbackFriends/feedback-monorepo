# CI/CD

GitHub Actions live in `.github/workflows/` and are root-owned infrastructure:

- `ci.yml`: validates backend, web, and generated API artifacts.
- `ios.yml`: path-filtered macOS job that builds iOS, runs both unit-test targets, and checks changed-line SwiftLint violations.
- `release.yml`: runs release validation, builds and publishes Docker images, creates a GitHub release, and triggers Coolify deployment.

When editing workflows:

- Use two-space indentation in YAML.
- Call out new required secrets or external integrations.
- Validate with `git diff -- .github/workflows` and the local commands relevant to the change.

For image tags, runtime assumptions, and environment changes, also read [runtime and deployment](runtime-and-deployment.md).
