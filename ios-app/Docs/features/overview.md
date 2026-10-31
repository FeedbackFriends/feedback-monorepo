# iOS app: features and requirements

Reviewed against the repository on 2026-10-31.

This document describes the current iOS app and its functional requirements. It covers participant and format-owner experiences; web features and backend operations are outside scope. Requirements below reflect the current implementation unless explicitly marked as a gap. This is a source-code review, not confirmation that every flow has passed device testing or shipped to the App Store.

LetsGrow collects short, honest feedback after meetings, workshops, talks, and similar repeatable formats. The owner uses the feedback to improve future sessions. Participants can respond without creating a personal account.

## 1. Roles, app entry, and navigation

**Purpose:** Give participants immediate access to feedback and owners access to their formats.

- First-time users enter through an anonymous authentication session without a signup form. This is an internal technical identity, not a participant-facing account requirement.
- Restore the authenticated user's account and shared app data on startup.
- Provide two tabs: **Giv feedback** and **Aktiviteter**.
- Show the activity list to owners (`manager` in code). Show the owner signup experience in the Activities tab for participants.
- Provide a **Profil** toolbar entry that opens a profile sheet.
- Show the owner's unseen-response count as a badge on the Activities tab.
- Clear owner-only activity navigation when the user's role changes away from owner.
- Show loading and recoverable error states while establishing authentication or loading account data.

Source: [RootFeature](../../Modules/Sources/RootFeature/RootFeature.swift), [TabbarView](../../Modules/Sources/TabbarFeature/TabbarView.swift).

## 2. Owner signup, login, and logout

**Purpose:** Let a format owner access their saved activities and feedback.

- Support **Sign in with Apple** and **Google sign-in**.
- Display progress while authentication is in flight and reset progress after completion, cancellation, or failure.
- Treat cancelled authentication as a normal exit; present other authentication errors to the user.
- Load or create the corresponding backend account after authentication.
- Allow an authenticated owner to log out from profile settings.
- Return an explicitly logged-out user to the sign-in experience.

Source: [SignUp](../../Modules/Sources/SignUpFeature/SignUp.swift), [Logout](../../Modules/Sources/RootFeature/Logout.swift).

## 3. Start feedback using a PIN or invitation

**Purpose:** Let a participant reach the correct session with minimal effort.

- Accept a four-digit numeric PIN in **Giv feedback**.
- Enable starting feedback only for a valid PIN and prevent repeated starts while loading.
- Retrieve the session's feedback questions before presenting the response flow.
- Clear the PIN and loading state after the start request completes; show an error if the session cannot be opened.
- Support invitation URLs using `letsgrow://invite?pin_code=<PIN>`.
- Use an invitation to open the join-session sheet with the supplied PIN. Joining sends a request, shows confirmation, and dismisses the sheet.

Source: [EnterCode](../../Modules/Sources/EnterCodeFeature/EnterCode.swift), [InitialiseFeedback](../../Modules/Sources/TabbarFeature/InitialiseFeedback.swift), [JoinEvent](../../Modules/Sources/ActivityFeature/Events/JoinEvent/JoinEvent.swift), [Deeplink](../../Modules/Sources/Domain/Deeplink/Deeplink.swift).

## 4. Answer and submit feedback

**Purpose:** Collect a short response to the session's configured questions.

- Present questions one at a time in a full-screen flow.
- Support five answer types: emoji, 0–10 rating, thumbs up/down, agreement scale, and free-text comment.
- Allow optional elaboration on structured answers.
- Enable progression/submission according to the current question's completion rules.
- Allow backward navigation and retain answers when moving between questions.
- Provide session information from the feedback flow.
- Submit the answers against the session PIN and question identifiers.
- Prevent duplicate submission while a request is running or success is being displayed.
- Preserve the flow after submission errors so the participant can retry.
- Show successful submission before closing. Display an app-rating prompt when requested by the submission response.
- Allow the participant to close the flow.

Source: [FeedbackFlowCoordinator](../../Modules/Sources/FeedbackFlowFeature/FeedbackFlowCoordinator.swift), [FeedbackFlowCoordinatorView](../../Modules/Sources/FeedbackFlowFeature/FeedbackFlowCoordinatorView.swift).

## 5. Browse owned activities

**Purpose:** Give owners an overview of the repeatable formats they manage.

- List the owner's activities in the Activities tab.
- Each card shows its title, session count, nearest future session or a no-upcoming-session message, and feedback status.
- Show trend information and total response count when feedback exists; otherwise show that the first feedback is awaited.
- Provide a first-activity empty state and a toolbar creation action.
- Open the selected activity's detail screen.
- Support pull to refresh. Keep existing data if refresh fails and offer retry.

Source: [ActivityList](../../Modules/Sources/ActivityFeature/Activities/ActivityList/ActivityList.swift), [ActivityRowView](../../Modules/Sources/ActivityFeature/Activities/ActivityList/Views/ActivityRowView.swift).

## 6. Create and edit an activity

**Purpose:** Configure a reusable format and its feedback questions.

- Create an activity in two steps: **name**, then **template and questions**.
- Require a nonblank name before advancing.
- Require an explicit template choice: standard meeting feedback, team meeting, retrospective, workshop, or custom questions.
- Start custom questions with an empty question list.
- Enable creation only when the name is filled in, at least one question exists, and every question has text.
- Keep the creation action on the combined template/questions step.
- Preserve the draft during backward navigation and after request failure.
- Preserve questions when reselecting the same template. Confirm template replacement when it would overwrite customized questions.
- Prevent duplicate requests while saving.
- After creation, show confirmation and open the new activity.
- Edit existing activities through the combined form with a separate question editor.

Source: [Creation requirements](create-activity.md), [ManageActivity](../../Modules/Sources/ActivityFeature/Activities/ManageActivity/ManageActivity.swift), [FeedbackTemplate](../../Modules/Sources/ActivityFeature/Activities/ManageActivity/FeedbackTemplate.swift).

## 7. Edit questions and illustrate the participant experience

**Purpose:** Let an owner tailor a short feedback set before using it.

- Add, edit, delete, and reorder questions in the shared question editor.
- Configure question text and one of the supported feedback types.
- Require an explicit answer type when adding a new question.
- Show the selected answer type as a tappable card that opens the available types.
- Illustrate the selected question with the participant answer controls directly in the editor.
- Keep the illustration read-only; illustration answers must never be submitted to the API.
- Provide a save action to return from the question list, and consistent inline add/edit actions.
- Session forms use the activity's feedback setup and direct owners to edit the activity to change questions for future sessions.

Source: [ManageActivity](../../Modules/Sources/ActivityFeature/Activities/ManageActivity/ManageActivity.swift), [QuestionsListView](../../Modules/Sources/ActivityFeature/Activities/ManageEvent/QuestionsListView.swift), [FeedbackQuestionIllustrationView](../../Modules/Sources/FeedbackFlowFeature/FeedbackQuestionIllustrationView.swift).

## 8. Calendar-based session setup

**Purpose:** Let owners continue scheduling in their existing calendar.

- Display the generated LetsGrow email address for the selected activity in the **Fra kalender til feedback** guide.
- Allow copying the address and confirm that it was copied.
- Explain that inviting this address creates a session automatically in the app.
- Explain that the invitation must be sent from the email address on the owner's LetsGrow account.
- Point owners to Profile to change their account email and to manual session creation as an alternative.
- Calendar import and email routing are backend dependencies; the iOS app presents the address and instructions rather than reading the device calendar itself.

Source: [ActivityDetailHowItWorksView](../../Modules/Sources/ActivityFeature/Activities/ActivityDetail/Views/ActivityDetailHowItWorksView.swift).

## 9. Browse, create, edit, and delete sessions

**Purpose:** Manage individual occurrences of an activity.

- Show sessions within their owning activity, with an **Alle sessioner** route for the full grouped list.
- Open a session's detail screen from the list.
- Allow manual creation with a scheduled date/time or **Start nu**, an optional location, and a duration.
- Offer preset durations, custom hours/minutes, and an all-day option.
- Display the inherited activity title and question count in the session form.
- Allow editing an existing session's scheduling details.
- Show progress and validation state on save; preserve inputs and present errors when saving fails.
- After creation, open the session, show confirmation, and then present its invitation.
- Require confirmation before deleting a session, show progress, and navigate away after successful deletion.

Source: [ActivityDetail](../../Modules/Sources/ActivityFeature/Activities/ActivityDetail/ActivityDetail.swift), [ManageEvent](../../Modules/Sources/ActivityFeature/Activities/ManageEvent/ManageEvent.swift), [EventDetailFeature](../../Modules/Sources/ActivityFeature/Activities/EventDetail/EventDetailFeature.swift).

## 10. Invite participants

**Purpose:** Share access to a session's feedback.

- Open an invitation sheet from session detail.
- Generate the invitation URL from the configured web base URL and session PIN.
- Display and copy the invitation link.
- Share invitation text through the native share sheet, including the activity title, PIN, and link.
- Present an error if an invitation link cannot be generated.

Source: [InviteView](../../Modules/Sources/ActivityFeature/Events/EventDetail/InviteView.swift), [EventDetailFeature](../../Modules/Sources/ActivityFeature/Activities/EventDetail/EventDetailFeature.swift).

## 11. Read session feedback

**Purpose:** Help an owner understand responses to one specific session.

- Show the session's response count, details, question summaries, and available comments.
- Render summaries appropriate to each answer type, including distributions and numeric results.
- Keep results scoped to that session's question snapshots rather than substituting account-wide analytics.
- Show feedback without participant identities in the owner-facing response model.
- Mark the session as seen when opening its detail screen and update unseen-response state through shared app data.

Source: [EventDetailFeature](../../Modules/Sources/ActivityFeature/Activities/EventDetail/EventDetailFeature.swift), [QuestionSummaryViews](../../Modules/Sources/ActivityFeature/Events/EventDetail/QuestionSummaryViews.swift), [Session mapping](../../Modules/Sources/Adapters/APIClient/Mappers/Responses/SessionDto+Mapping.swift).

## 12. Follow development across sessions

**Purpose:** Reveal patterns within a repeatable format over time.

- Show development within activity detail, alongside session management.
- Display backend-provided trend states and comparison information, including insufficient-data states.
- Display a feedback-score chart when numeric session ratings are available; explain that 0–10 answers are represented on a 0–5 scale.
- Allow chart/session results to open the relevant session feedback.
- Provide expandable question histories, grouped by canonical question identity, text, and feedback type.
- Show each question's session results on its own answer scale and link to the corresponding session.
- Keep trends scoped to the activity; do not derive a cross-activity score.

Source: [ActivityInsightSectionsView](../../Modules/Sources/ActivityFeature/Insights/ActivityInsightSectionsView.swift), [ActivityInsightData](../../Modules/Sources/ActivityFeature/Insights/ActivityInsightData.swift).

## 13. Delete an activity

**Purpose:** Remove a format the owner no longer needs.

- Offer deletion from activity detail and require explicit confirmation.
- Show an in-flight state and report API errors.
- On success, leave the deleted activity's navigation and show a confirmation in the activity list.

Source: [ActivityDetail](../../Modules/Sources/ActivityFeature/Activities/ActivityDetail/ActivityDetail.swift).

## 14. Notifications and data updates

**Purpose:** Keep app data current and route owners to newly received feedback.

- Observe authentication, messaging-token, and shared-session changes.
- Poll for bootstrap updates every ten seconds while the lifecycle effect runs.
- Handle `FEEDBACK_RECEIVED` notification payloads containing an event ID.
- Refresh account data and resolve the notified session inside its owning activity before navigating to session detail.
- Expose an entry to the app's system notification settings from Profile.

**Gap:** The lifecycle includes a role-dependent notification-permission prompt action, but that alone does not establish a complete permission UI flow. The Profile communication toggles currently change local reducer state only; they do not save preferences or control actual delivery.

Source: [TabbarLifecycle](../../Modules/Sources/TabbarFeature/TabbarLifecycle.swift), [RootFeature](../../Modules/Sources/RootFeature/RootFeature.swift), [ProfileSettings](../../Modules/Sources/MoreFeature/AccountSection/ProfileSettings.swift).

## 15. Profile, account editing, and account deletion

**Purpose:** Let owners maintain account details and control their account.

- Offer owner settings from the Profile sheet.
- Display and edit name, email, and phone number.
- Save changes through the API, prevent duplicate saves, dismiss on success, and present errors on failure.
- Require explicit confirmation for account deletion and explain that associated account data cannot be restored.
- Show deletion progress and success; log out when the user closes the success confirmation.
- Offer logout retry if ending the authentication session fails.

Source: [ProfileSettingsView](../../Modules/Sources/MoreFeature/AccountSection/ProfileSettingsView.swift), [ModifyAccount](../../Modules/Sources/MoreFeature/AccountSection/ProfileSettings/ModifyAccount.swift), [DeleteAccount](../../Modules/Sources/TabbarFeature/DeleteAccount.swift).

## 16. Help, privacy, and app reviews

**Purpose:** Make support and privacy information reachable from the app.

- Link to the configured privacy policy.
- Open a support email for product feedback or bug reports, prefilled with a subject and device information.
- Link to the App Store review page.
- Keep these actions in the Profile experience.

Source: [MoreSection](../../Modules/Sources/MoreFeature/MoreSection/MoreSection.swift), [MoreSectionView](../../Modules/Sources/MoreFeature/MoreSection/MoreSectionView.swift).

## 17. Shared experience and platform requirements

- Target iOS 26+ using the native SwiftUI app.
- Use Danish-first, practical product language; existing screens still contain some English strings.
- Keep participant feedback accessible without Apple/Google sign-in.
- Keep loading, success, empty, and error states understandable, with retry where implemented.
- Use the shared design system and native sheets, navigation, and sharing integrations.
- Require network access for authentication, session retrieval, and feedback submission; this overview makes no claim of offline submission support.

## 18. Scope boundaries and documentation gaps

- Current navigation has two tabs. The three-tab **Overblik / Aktiviteter / Giv feedback** description in [insights.md](insights.md) does not match the current `TabbarView`; a separate overview dashboard is not included as a current feature here.
- Communication preferences are UI state only, as noted above.
- Workspace administration, owner invitations, billing, and subscription checkout are not exposed as iOS features in the reviewed navigation.
- Improvement suggestions and action tracking are deferred in the existing feature documentation.
- Files for a feature or a preview do not by themselves establish that it is reachable in the app. This overview follows the current root/tab navigation and presented feature flows.
