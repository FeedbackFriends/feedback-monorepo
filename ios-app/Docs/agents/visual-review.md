# iOS visual review

Paths are relative to `ios-app/` unless stated otherwise.

## Visual Review

- Use stable fixtures and bounded layout/presentation readiness waits. Capture once, then review every current screenshot manually or with an agent. Pixel comparisons are optional diagnostics; they are not a pass/fail gate. Record reviewed IDs/hashes, meaningful findings, and uncertainty.
- After changing iOS UI, follow [the screenshot skill](../../.agents/skills/letsgrow-screenshots/SKILL.md) to capture the complete catalog and generate the local before/after review report before finishing. Shared design changes require the same full-catalog comparison. Capture one representative layout per screen. Add state variants only for meaningful content or layout differences; do not require loading, saving, disabled, or partial-input screenshots on every screen. Only named previews marked with `// Screenshot: <reason>` enter the capture catalog; unmarked previews stay available in Xcode. Regenerate snapshot factories after selection changes. Captures use Point-Free SnapshotTesting through the `ScreenSnapshots` plan.
- Report reviewed/pending, added, and removed counts and link `screenshots/index.html` in the final response. If native capture is blocked, report the blocker; do not present old captures as fresh verification.
- Capturing and reviewing must preserve approved baselines. Only run the review script's `--accept` or `--accept-all` after the user explicitly accepts those visual changes. Approval does not authorize a Git commit or push.
- Keep [simulator verification](simulator.md#simulator-verification) for behavior and native presentations; app-hosted snapshot tests verify fixture layouts. Native alerts are captured and reviewed in the same catalog, with presentation and text assertions before capture.
