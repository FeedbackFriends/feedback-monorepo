# Indsigt

Owners have three tabs: **Overblik · Aktiviteter · Giv feedback** and land on Overblik. Participants retain the feedback flow and account entry point; Aktiviteter is owner-only. Both owner tabs use the same shared Bootstrap. Overblik opens activity development and session feedback in a large sheet with its own navigation stack and a design-system close button. Sessions open within their owning activity's sheet navigation. Closing a lookup preserves Overblik's scroll position and the navigation in Aktiviteter. “Vis alle” still pushes the full unread list; opening a result presents a sheet above that list. Aktiviteter retains push navigation for activities and sessions. New activities and feedback notifications use the same presentation rules as their originating tab. Profile remains in the top toolbar.

Overblik prioritizes relevant items instead of listing activities:

1. Unread session feedback, ordered by the latest response timestamp. Show at most two cards and a “Vis alle” route to the full unread list when needed. Opening a card goes directly to session feedback; existing mark-as-seen behavior removes it from the unread section. When no unread feedback remains, “Seneste feedback” links to the session with the most recently received feedback and shows its total response count.
2. The nearest upcoming session across all activities, with its question setup status. Time-sensitive content updates every minute.
3. One recent activity development: improving or declining, with feedback received in the last 30 days. Stable and insufficient-data trends are omitted. “Se udvikling” opens that activity's combined detail.

A quiet “Seneste 30 dage” summary shows the number of sessions starting in the last 30 days whose scheduled end has passed, and how many of those sessions have received feedback. Future and ongoing sessions are excluded. Counts use existing bootstrap session data.

New owners see one “Opret din første aktivitet” action. Owners without actionable items or previous feedback see “Du er opdateret”. The Aktiviteter tab contains the full activity list and its creation action. Profile stays in the top toolbar. Pull to refresh preserves existing data on failure and offers retry.

Selecting an activity opens one detail screen: feedback trend and chart, session management, and collapsible question histories. Histories group by canonical activity question ID, text, and feedback type. Session results and chart points open existing session feedback. There is no separate Indsigt tab.

The backend trend compares the latest two sessions with zero-to-ten ratings, normalized to 0–5. The comparison label counts the numeric question responses in those sessions; the overview separately labels total session and participant-response counts. No client-side trend calculation or cross-activity score is introduced.

## Data and rollout

Deploy the backend change before distributing the updated iOS client. Event question snapshots now include `activityQuestionId`, anonymous `feedback` responses with stable IDs and timestamps, and a session-specific `summary`. Response DTOs exclude participant identifiers. These are additive API fields; regenerate all clients with `./scripts/generate-api-artifacts.sh`.

Each activity now exposes a stable four-digit `activityEmail` address. iOS displays and copies that address; the old shared address no longer routes calendar imports. Before rollout, ensure Zoho delivers `1000@letsgrow.dk` through `9999@letsgrow.dk` to the polled mailbox using aliases or a catch-all rule. Invites must name exactly one activity address and the organizer must own that activity. Migration 0023 backfills existing activities before enforcing non-null and uniqueness constraints and halts if more than 9,000 activities need addresses.

The iOS adapter maps session snapshots directly, without substituting account-wide question analytics. The home screen derives its content from shared `Bootstrap`; refresh errors preserve that content and offer retry. Initial bootstrap failures remain handled by the existing root loading/error flow. Empty states guide owners to the existing activity creation flow. Suggestions and action tracking are deferred.

## Verification

- Backend: `./gradlew :api:test --tests dk.example.feedback.tests.E2ETest` from `backend/`.
- iOS: run the `InsightsTests` scheme on a booted simulator. Tests cover data scoping, question versions, ordering, comparison counts, response mapping, refresh/retry, role changes, creation navigation, and session drill-down.
- The focused test target links `IssueReportingTestSupport`, using the existing resolved dependency version, to support Swift Testing integration in TCA's dependency system.
- Run `swiftlint lint --reporter xcode` from `ios-app/`.

## Local review checks

The review removed unused introduction and preview configuration code, redundant navigation containers, and the old calendar update path. Calendar invite changes and session creation now share one repository transaction, and invite updates preserve submitted-feedback status. Notification links resolve a session within its owning activity.

Calendar parser and migration tests were run directly with JUnit (8 passing); changed Kotlin sources compiled without warnings. SwiftLint and Swift syntax checks passed. Web lint, TypeScript, and regenerated TypeScript contract comparison passed. Full Gradle, iOS build/simulator, and Next.js production build still require an environment with working local sockets and network access. Existing AppTests also contain legacy API references, including `TabbarTests.signOutButtonTapped` and old `FeedbackFlowDto` fixtures, and need migration before the full iOS test target can pass.
