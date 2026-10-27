#if DEBUG
import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

@MainActor
private enum CatalogActivity {
    static func detail(_ activity: Activity) -> some View {
        NavigationStack {
            ActivityDetailView(store: Store(initialState: ActivityDetail.State(
                activityId: activity.id, bootstrap: PreviewCatalogFixtures.bootstrap(activity: activity)
            )) { EmptyReducer() })
        }
    }

    static func session(_ event: Event?) -> some View {
        var activity = PreviewCatalogFixtures.activity
        activity.events = event.map { [$0] } ?? []
        let state = EventDetailFeature.State(
            activityId: activity.id, eventId: event?.id ?? PreviewCatalogFixtures.id(999),
            bootstrap: PreviewCatalogFixtures.bootstrap(activity: activity),
            webBaseUrl: URL(string: "https://letsgrow.dk")
        )
        return NavigationStack {
            EventDetailFeatureView(store: Store(initialState: state) { EmptyReducer() })
        }
    }

    static func eventForm() -> ManageEvent.State {
        var input = EventInput(PreviewCatalogFixtures.activity)
        input.date = PreviewCatalogFixtures.now.addingTimeInterval(86_400)
        return ManageEvent.State(
            mode: .create, activityId: PreviewCatalogFixtures.id(1), eventId: nil,
            eventInput: input, successOverlayMessage: "Session oprettet"
        )
    }

    static func createActivity(step: ManageActivity.Step? = nil, custom: Bool = false) -> ManageActivity.State {
        var state = ManageActivity.State.create()
        state.title = PreviewCatalogFixtures.activity.title
        state.description = PreviewCatalogFixtures.activity.agenda ?? ""
        if let step {
            if step == .questions {
                state.selectTemplate(custom ? .customQuestions : .standardMeeting)
                // Template defaults allocate UUIDs; replace them with stable catalog IDs.
                for index in state.questions.indices {
                    state.questions[index].id = PreviewCatalogFixtures.id(200 + index)
                }
                state.path = [.template, .questions]
            } else {
                state.path = [.template]
            }
        }
        return state
    }

    static var questionInputs: [EventInput.QuestionInput] {
        [.init(id: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, feedbackType: .zeroToTen)]
    }

    static var expired: Event {
        Event(
            id: PreviewCatalogFixtures.id(22), date: PreviewCatalogFixtures.now.addingTimeInterval(-604_800),
            pinCode: nil, durationInMinutes: 30, overallFeedbackSummary: nil,
            questionsSnapshot: [], calendarProvider: nil
        )
    }
}

@MainActor
private func catalogActivityDetailPopulated() -> some View {
    ScreenCatalogContainerView {
        CatalogActivity.detail(PreviewCatalogFixtures.activity)
    }
}

#Preview("activity-detail.populated") { catalogActivityDetailPopulated() }

@MainActor
private func catalogActivityDetailNoSessions() -> some View {
    ScreenCatalogContainerView {
        CatalogActivity.detail(PreviewCatalogFixtures.emptyActivity)
    }
}

#Preview("activity-detail.no-sessions") { catalogActivityDetailNoSessions() }

@MainActor
private func catalogActivityDetailNoFeedback() -> some View {
    ScreenCatalogContainerView {
        let activity = {
            var value = PreviewCatalogFixtures.activity
            value.events = [PreviewCatalogFixtures.upcomingEvent]
            value.overallFeedbackSummary = nil
            return value
        }()
        CatalogActivity.detail(activity)
    }
}

#Preview("activity-detail.no-feedback") { catalogActivityDetailNoFeedback() }

@MainActor
private func catalogSessionDetailFeedback() -> some View {
    ScreenCatalogContainerView {
        CatalogActivity.session(PreviewCatalogFixtures.previousEvent)
    }
}

#Preview("session-detail.feedback") { catalogSessionDetailFeedback() }

@MainActor
private func catalogSessionDetailNoFeedback() -> some View {
    ScreenCatalogContainerView {
        CatalogActivity.session(PreviewCatalogFixtures.upcomingEvent)
    }
}

#Preview("session-detail.no-feedback") { catalogSessionDetailNoFeedback() }

@MainActor
private func catalogSessionDetailExpired() -> some View {
    ScreenCatalogContainerView {
        CatalogActivity.session(CatalogActivity.expired)
    }
}

#Preview("session-detail.expired") { catalogSessionDetailExpired() }

@MainActor
private func catalogSessionDetailUnavailable() -> some View {
    ScreenCatalogContainerView {
        CatalogActivity.session(nil)
    }
}

#Preview("session-detail.unavailable") { catalogSessionDetailUnavailable() }

@MainActor
private func catalogCreateActivityEmpty() -> some View {
    ScreenCatalogContainerView {
        ManageActivityView(store: Store(initialState: ManageActivity.State.create()) { EmptyReducer() })
    }
}

#Preview("create-activity.empty") { catalogCreateActivityEmpty() }

@MainActor
private func catalogCreateActivityDetails() -> some View {
    ScreenCatalogContainerView {
        ManageActivityView(store: Store(initialState: CatalogActivity.createActivity()) { EmptyReducer() })
    }
}

#Preview("create-activity.details") { catalogCreateActivityDetails() }

@MainActor
private func catalogCreateActivityTemplates() -> some View {
    ScreenCatalogContainerView {
        ManageActivityView(store: Store(initialState: CatalogActivity.createActivity(step: .template)) { EmptyReducer() })
    }
}

#Preview("create-activity.templates") { catalogCreateActivityTemplates() }

@MainActor
private func catalogCreateActivityQuestions() -> some View {
    ScreenCatalogContainerView {
        ManageActivityView(store: Store(initialState: CatalogActivity.createActivity(step: .questions)) { EmptyReducer() })
    }
}

#Preview("create-activity.questions") { catalogCreateActivityQuestions() }

@MainActor
private func catalogCreateActivityCustomEmpty() -> some View {
    ScreenCatalogContainerView {
        ManageActivityView(store: Store(initialState: CatalogActivity.createActivity(step: .questions, custom: true)) { EmptyReducer() })
    }
}

#Preview("create-activity.custom-empty") { catalogCreateActivityCustomEmpty() }

@MainActor
private func catalogCreateActivitySaving() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = CatalogActivity.createActivity(step: .questions)
            state.createActivityRequestInFlight = true
            return state
        }()
        ManageActivityView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("create-activity.saving") { catalogCreateActivitySaving() }

@MainActor
private func catalogCreateActivityTemplateSelected() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = CatalogActivity.createActivity(step: .template)
            state.selectTemplate(.standardMeeting)
            return state
        }()
        ManageActivityView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("create-activity.template-selected") { catalogCreateActivityTemplateSelected() }

@MainActor
private func catalogEditActivityPopulated() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ManageActivity.State.edit(activity: PreviewCatalogFixtures.activity)

            return state
        }()
        ManageActivityView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("edit-activity.populated") { catalogEditActivityPopulated() }

@MainActor
private func catalogEditActivityTemplates() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ManageActivity.State.edit(activity: PreviewCatalogFixtures.activity)
            state.isChoosingTemplate = true
            return state
        }()
        ManageActivityView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("edit-activity.templates") { catalogEditActivityTemplates() }

@MainActor
private func catalogEditActivitySaving() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ManageActivity.State.edit(activity: PreviewCatalogFixtures.activity)
            state.createActivityRequestInFlight = true
            return state
        }()
        ManageActivityView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("edit-activity.saving") { catalogEditActivitySaving() }

@MainActor
private func catalogCreateSessionScheduled() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = CatalogActivity.eventForm()

            return state
        }()
        NavigationStack {
            ManageEventView(store: Store(initialState: state) { EmptyReducer() })
        }
    }
}

#Preview("create-session.scheduled") { catalogCreateSessionScheduled() }

@MainActor
private func catalogCreateSessionStartNow() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = CatalogActivity.eventForm()
            state.startNowEnabled = true
            return state
        }()
        NavigationStack {
            ManageEventView(store: Store(initialState: state) { EmptyReducer() })
        }
    }
}

#Preview("create-session.start-now") { catalogCreateSessionStartNow() }

@MainActor
private func catalogCreateSessionAllDay() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = CatalogActivity.eventForm()
            state.allDay = true
            return state
        }()
        NavigationStack {
            ManageEventView(store: Store(initialState: state) { EmptyReducer() })
        }
    }
}

#Preview("create-session.all-day") { catalogCreateSessionAllDay() }

@MainActor
private func catalogCreateSessionCustomDuration() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = CatalogActivity.eventForm()
            state.durationPicker = .other
            state.hourPicker = 2
            state.minutePicker = 15
            return state
        }()
        NavigationStack {
            ManageEventView(store: Store(initialState: state) { EmptyReducer() })
        }
    }
}

#Preview("create-session.custom-duration") { catalogCreateSessionCustomDuration() }

@MainActor
private func catalogCreateSessionSaving() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = CatalogActivity.eventForm()
            state.manageEventInFlight = true
            return state
        }()
        NavigationStack {
            ManageEventView(store: Store(initialState: state) { EmptyReducer() })
        }
    }
}

#Preview("create-session.saving") { catalogCreateSessionSaving() }

@MainActor
private func catalogCreateSessionSuccess() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = CatalogActivity.eventForm()
            state.showSuccessOverlay = true
            return state
        }()
        NavigationStack {
            ManageEventView(store: Store(initialState: state) { EmptyReducer() })
        }
    }
}

#Preview("create-session.success") { catalogCreateSessionSuccess() }

@MainActor
private func catalogEditSessionPopulated() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            ManageEventView(store: Store(initialState: ManageEvent.State.edit(
                activity: PreviewCatalogFixtures.activity, event: PreviewCatalogFixtures.upcomingEvent
            )) { EmptyReducer() })
        }
    }
}

#Preview("edit-session.populated") { catalogEditSessionPopulated() }

@MainActor
private func catalogQuestionsPopulated() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            QuestionsListView(questionsInputs: .constant(CatalogActivity.questionInputs), onPreview: { _ in })
        }
    }
}

#Preview("questions.populated") { catalogQuestionsPopulated() }

@MainActor
private func catalogQuestionsEmpty() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            QuestionsListView(questionsInputs: .constant([]), onPreview: { _ in })
        }
    }
}

#Preview("questions.empty") { catalogQuestionsEmpty() }

@MainActor
private func catalogQuestionEditorEmpty() -> some View {
    ScreenCatalogContainerView {
        QuestionPickerView(
            existingQuestionID: nil, feedbackTypeSelected: .emoji,
            questionTextField: "", questionSelected: { _ in }
        )
    }
}

#Preview("question-editor.empty") { catalogQuestionEditorEmpty() }

@MainActor
private func catalogQuestionEditorEdit() -> some View {
    ScreenCatalogContainerView {
        QuestionPickerView(
            existingQuestionID: PreviewCatalogFixtures.id(10), feedbackTypeSelected: .zeroToTen,
            questionTextField: "Hvor nyttigt var mødet for dig?", questionSelected: { _ in }
        )
    }
}

#Preview("question-editor.edit") { catalogQuestionEditorEdit() }

@MainActor
private func catalogQuestionEditorLongText() -> some View {
    ScreenCatalogContainerView {
        QuestionPickerView(
            existingQuestionID: nil, feedbackTypeSelected: .opinion,
            questionTextField: "Jeg har fået den viden og de konkrete aftaler, jeg skal bruge for at kunne gå videre med mine opgaver efter dette møde.", questionSelected: { _ in }
        )
    }
}

#Preview("question-editor.long-text") { catalogQuestionEditorLongText() }

@MainActor
private func catalogQuestionEditorThumbs() -> some View {
    ScreenCatalogContainerView {
        QuestionPickerView(
            existingQuestionID: nil, feedbackTypeSelected: .thumpsUpThumpsDown,
            questionTextField: "Vil du anbefale dette format?", questionSelected: { _ in }
        )
    }
}

#Preview("question-editor.thumbs") { catalogQuestionEditorThumbs() }

@MainActor
private func catalogQuestionEditorComment() -> some View {
    ScreenCatalogContainerView {
        QuestionPickerView(
            existingQuestionID: nil, feedbackTypeSelected: .comment,
            questionTextField: "Hvad kan vi gøre bedre næste gang?", questionSelected: { _ in }
        )
    }
}

#Preview("question-editor.comment") { catalogQuestionEditorComment() }

@MainActor
private func catalogQuestionsAnswerTypeHelp() -> some View {
    ScreenCatalogContainerView {
        FeedbackTypeInfoSheetView()
    }
}

#Preview("questions.answer-type-help") { catalogQuestionsAnswerTypeHelp() }

@MainActor
private func catalogActivityHowItWorks() -> some View {
    ScreenCatalogContainerView {
        ActivityDetailHowItWorksSheetView(activityEmail: PreviewCatalogFixtures.activity.activityEmail) {}
    }
}

#Preview("activity.how-it-works") { catalogActivityHowItWorks() }

@MainActor
private func catalogSessionInvite() -> some View {
    ScreenCatalogContainerView {
        InviteView(inviteLink: "https://letsgrow.dk/invite/1234", shareText: "Svar på feedback med PIN-kode 1234")
    }
}

#Preview("session.invite") { catalogSessionInvite() }

@MainActor
private func catalogSessionInviteUnavailable() -> some View {
    ScreenCatalogContainerView {
        EmptyStateView(
            title: "Invitation ikke tilgængelig",
            message: "Invitationer er ikke tilgængelige for denne session lige nu."
        ).padding(Theme.padding)
    }
}

#Preview("session.invite-unavailable") { catalogSessionInviteUnavailable() }

@MainActor
private func catalogParticipantStartFeedbackConfirmation() -> some View {
    ScreenCatalogContainerView {
        StartFeedbackConfirmationView(startFeedback: {})
    }
}

#Preview("participant.start-feedback-confirmation") { catalogParticipantStartFeedbackConfirmation() }

@MainActor
private func catalogNotificationsEmpty() -> some View {
    ScreenCatalogContainerView {
        NotificationHistoryView(notificationHistoryItems: [], activityManagerEventButtonTap: { _ in })
    }
}

#Preview("notifications.empty") { catalogNotificationsEmpty() }

@MainActor
private func catalogNotificationsUnread() -> some View {
    ScreenCatalogContainerView {
        NotificationHistoryView(notificationHistoryItems: [PreviewCatalogFixtures.notification], activityManagerEventButtonTap: { _ in })
    }
}

#Preview("notifications.unread") { catalogNotificationsUnread() }

@MainActor
private func catalogNotificationsRead() -> some View {
    ScreenCatalogContainerView {
        NotificationHistoryView(notificationHistoryItems: [NotificationHistoryItem(
            id: PreviewCatalogFixtures.id(31), date: PreviewCatalogFixtures.now,
            eventTitle: "Ugentligt teammøde", eventId: PreviewCatalogFixtures.id(20),
            newFeedbackCount: 2, seenByManager: true
        )], activityManagerEventButtonTap: { _ in })
    }
}

#Preview("notifications.read") { catalogNotificationsRead() }

@MainActor
private func catalogJoinSessionEmpty() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = JoinEvent.State(pinCodeInput: .init(value: ""))

            return state
        }()
        JoinEventView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("join-session.empty") { catalogJoinSessionEmpty() }

@MainActor
private func catalogJoinSessionPartial() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = JoinEvent.State(pinCodeInput: .init(value: "12"))

            return state
        }()
        JoinEventView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("join-session.partial") { catalogJoinSessionPartial() }

@MainActor
private func catalogJoinSessionReady() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = JoinEvent.State(pinCodeInput: .init(value: "1234"))

            return state
        }()
        JoinEventView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("join-session.ready") { catalogJoinSessionReady() }

@MainActor
private func catalogJoinSessionLoading() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = JoinEvent.State(pinCodeInput: .init(value: "1234"))
            state.joinRequestInFlight = true
            return state
        }()
        JoinEventView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("join-session.loading") { catalogJoinSessionLoading() }

@MainActor
private func catalogJoinSessionSuccess() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = JoinEvent.State(pinCodeInput: .init(value: "1234"))
            state.showSuccessOverlay = true
            return state
        }()
        JoinEventView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("join-session.success") { catalogJoinSessionSuccess() }

@MainActor
private func catalogParticipantSessionsEmpty() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ParticipantEvents.State(bootstrap: {
                let value = PreviewCatalogFixtures.bootstrap(role: .participant)
                value.withLock { $0.participantEvents = [] }
                return value
            }())
            state.startFeedbackPincodeInFlight = nil
            return state
        }()
        NavigationStack {
            ParticipantEventsView(store: Store(initialState: state) { EmptyReducer() })
                .navigationTitle("Dine sessioner")
        }
    }
}

#Preview("participant-sessions.empty") { catalogParticipantSessionsEmpty() }

@MainActor
private func catalogParticipantSessionsAvailable() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ParticipantEvents.State(bootstrap: {
                let value = PreviewCatalogFixtures.bootstrap(role: .participant)
                value.withLock { $0.participantEvents = [PreviewCatalogFixtures.participantEvent(index: 0, recentlyJoined: true)] }
                return value
            }())
            state.startFeedbackPincodeInFlight = nil
            return state
        }()
        NavigationStack {
            ParticipantEventsView(store: Store(initialState: state) { EmptyReducer() })
                .navigationTitle("Dine sessioner")
        }
    }
}

#Preview("participant-sessions.available") { catalogParticipantSessionsAvailable() }

@MainActor
private func catalogParticipantSessionsSubmitted() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ParticipantEvents.State(bootstrap: {
                let value = PreviewCatalogFixtures.bootstrap(role: .participant)
                value.withLock { $0.participantEvents = [PreviewCatalogFixtures.participantEvent(index: -1, submitted: true)] }
                return value
            }())
            state.startFeedbackPincodeInFlight = nil
            return state
        }()
        NavigationStack {
            ParticipantEventsView(store: Store(initialState: state) { EmptyReducer() })
                .navigationTitle("Dine sessioner")
        }
    }
}

#Preview("participant-sessions.submitted") { catalogParticipantSessionsSubmitted() }

@MainActor
private func catalogParticipantSessionsExpired() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ParticipantEvents.State(bootstrap: {
                let value = PreviewCatalogFixtures.bootstrap(role: .participant)
                value.withLock { $0.participantEvents = [PreviewCatalogFixtures.participantEvent(index: -2, expired: true)] }
                return value
            }())
            state.startFeedbackPincodeInFlight = nil
            return state
        }()
        NavigationStack {
            ParticipantEventsView(store: Store(initialState: state) { EmptyReducer() })
                .navigationTitle("Dine sessioner")
        }
    }
}

#Preview("participant-sessions.expired") { catalogParticipantSessionsExpired() }

@MainActor
private func catalogParticipantSessionsLoading() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ParticipantEvents.State(bootstrap: {
                let value = PreviewCatalogFixtures.bootstrap(role: .participant)
                value.withLock { $0.participantEvents = [PreviewCatalogFixtures.participantEvent(index: 0)] }
                return value
            }())
            state.startFeedbackPincodeInFlight = .init(value: "1234")
            return state
        }()
        NavigationStack {
            ParticipantEventsView(store: Store(initialState: state) { EmptyReducer() })
                .navigationTitle("Dine sessioner")
        }
    }
}

#Preview("participant-sessions.loading") { catalogParticipantSessionsLoading() }

@MainActor
private func catalogActivityDeleteConfirmation() -> some View {
    ScreenCatalogContainerView {
        DeleteConfirmationViewSheet(
            title: "Slet aktivitet", message: "Slet denne aktivitet og al feedback?"
        ) {
            Button("Slet") {}
                .buttonStyle(LargeBoxButtonStyle(color: Color.themeVerySad))
                .isLoading(false)
        }
    }
}

#Preview("activity.delete-confirmation") { catalogActivityDeleteConfirmation() }

@MainActor
private func catalogActivityDeleteConfirmationLoading() -> some View {
    ScreenCatalogContainerView {
        DeleteConfirmationViewSheet(
            title: "Slet aktivitet", message: "Slet denne aktivitet og al feedback?"
        ) {
            Button("Slet") {}
                .buttonStyle(LargeBoxButtonStyle(color: Color.themeVerySad))
                .isLoading(true)
        }
    }
}

#Preview("activity.delete-confirmation-loading") { catalogActivityDeleteConfirmationLoading() }

@MainActor
private func catalogSessionDeleteConfirmation() -> some View {
    ScreenCatalogContainerView {
        DeleteConfirmationViewSheet(
            title: "Slet session", message: "Slet denne session og al feedback?"
        ) {
            Button("Slet") {}
                .buttonStyle(LargeBoxButtonStyle(color: Color.themeVerySad))
                .isLoading(false)
        }
    }
}

#Preview("session.delete-confirmation") { catalogSessionDeleteConfirmation() }

@MainActor
private func catalogSessionDeleteConfirmationLoading() -> some View {
    ScreenCatalogContainerView {
        DeleteConfirmationViewSheet(
            title: "Slet session", message: "Slet denne session og al feedback?"
        ) {
            Button("Slet") {}
                .buttonStyle(LargeBoxButtonStyle(color: Color.themeVerySad))
                .isLoading(true)
        }
    }
}

#Preview("session.delete-confirmation-loading") { catalogSessionDeleteConfirmationLoading() }

@MainActor
private func catalogUnreadFeedbackPopulated() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ActivityList.State(
                bootstrap: PreviewCatalogFixtures.bootstrap(empty: false),
                presentation: .overview, referenceDate: PreviewCatalogFixtures.now
            )
            state.path.append(.unreadFeedback)
            return state
        }()
        NavigationStack {
            ActivityListView(store: Store(initialState: state) { EmptyReducer() })
        }
    }
}

#Preview("unread-feedback.populated") { catalogUnreadFeedbackPopulated() }

@MainActor
private func catalogUnreadFeedbackEmpty() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ActivityList.State(
                bootstrap: PreviewCatalogFixtures.bootstrap(empty: true),
                presentation: .overview, referenceDate: PreviewCatalogFixtures.now
            )
            state.path.append(.unreadFeedback)
            return state
        }()
        NavigationStack {
            ActivityListView(store: Store(initialState: state) { EmptyReducer() })
        }
    }
}

#Preview("unread-feedback.empty") { catalogUnreadFeedbackEmpty() }

@MainActor
private func catalogActivityAllSessions() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            ActivityDetailSessionListView(store: Store(initialState: ActivityDetailSessionList.State(
                title: "Alle sessioner", eventTitle: "Ugentligt teammøde",
                sections: ActivityDetailSessionGrouping(
                    events: [PreviewCatalogFixtures.previousEvent, PreviewCatalogFixtures.upcomingEvent],
                    now: PreviewCatalogFixtures.now
                ).sections
            )) { EmptyReducer() })
        }
    }
}

#Preview("activity.all-sessions") { catalogActivityAllSessions() }

@MainActor
private func catalogSessionFeedbackComments() -> some View {
    ScreenCatalogContainerView {
        ScrollView {
            QuestionView(question: PreviewCatalogFixtures.question, index: 0).padding()
        }.background(Color.themeBackground)
    }
}

#Preview("session.feedback-comments") { catalogSessionFeedbackComments() }

@MainActor
private func catalogExtraSessionResultsEmojiAnswered() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            ScrollView {
                QuestionView(question: PreviewCatalogFixtures.resultQuestion(type: .emoji, answered: true), index: 0)
                    .padding()
            }
            .background(Color.themeBackground)
            .navigationTitle("Feedback på spørgsmål")
        }
    }
}

#Preview("session-results.emoji.answered") { catalogExtraSessionResultsEmojiAnswered() }

@MainActor
private func catalogExtraSessionResultsEmojiEmpty() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            ScrollView {
                QuestionView(question: PreviewCatalogFixtures.resultQuestion(type: .emoji, answered: false), index: 0)
                    .padding()
            }
            .background(Color.themeBackground)
            .navigationTitle("Feedback på spørgsmål")
        }
    }
}

#Preview("session-results.emoji.empty") { catalogExtraSessionResultsEmojiEmpty() }

@MainActor
private func catalogExtraSessionResultsRatingAnswered() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            ScrollView {
                QuestionView(question: PreviewCatalogFixtures.resultQuestion(type: .zeroToTen, answered: true), index: 0)
                    .padding()
            }
            .background(Color.themeBackground)
            .navigationTitle("Feedback på spørgsmål")
        }
    }
}

#Preview("session-results.rating.answered") { catalogExtraSessionResultsRatingAnswered() }

@MainActor
private func catalogExtraSessionResultsRatingEmpty() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            ScrollView {
                QuestionView(question: PreviewCatalogFixtures.resultQuestion(type: .zeroToTen, answered: false), index: 0)
                    .padding()
            }
            .background(Color.themeBackground)
            .navigationTitle("Feedback på spørgsmål")
        }
    }
}

#Preview("session-results.rating.empty") { catalogExtraSessionResultsRatingEmpty() }

@MainActor
private func catalogExtraSessionResultsThumbsAnswered() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            ScrollView {
                QuestionView(question: PreviewCatalogFixtures.resultQuestion(type: .thumpsUpThumpsDown, answered: true), index: 0)
                    .padding()
            }
            .background(Color.themeBackground)
            .navigationTitle("Feedback på spørgsmål")
        }
    }
}

#Preview("session-results.thumbs.answered") { catalogExtraSessionResultsThumbsAnswered() }

@MainActor
private func catalogExtraSessionResultsThumbsEmpty() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            ScrollView {
                QuestionView(question: PreviewCatalogFixtures.resultQuestion(type: .thumpsUpThumpsDown, answered: false), index: 0)
                    .padding()
            }
            .background(Color.themeBackground)
            .navigationTitle("Feedback på spørgsmål")
        }
    }
}

#Preview("session-results.thumbs.empty") { catalogExtraSessionResultsThumbsEmpty() }

@MainActor
private func catalogExtraSessionResultsOpinionAnswered() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            ScrollView {
                QuestionView(question: PreviewCatalogFixtures.resultQuestion(type: .opinion, answered: true), index: 0)
                    .padding()
            }
            .background(Color.themeBackground)
            .navigationTitle("Feedback på spørgsmål")
        }
    }
}

#Preview("session-results.opinion.answered") { catalogExtraSessionResultsOpinionAnswered() }

@MainActor
private func catalogExtraSessionResultsOpinionEmpty() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            ScrollView {
                QuestionView(question: PreviewCatalogFixtures.resultQuestion(type: .opinion, answered: false), index: 0)
                    .padding()
            }
            .background(Color.themeBackground)
            .navigationTitle("Feedback på spørgsmål")
        }
    }
}

#Preview("session-results.opinion.empty") { catalogExtraSessionResultsOpinionEmpty() }

@MainActor
private func catalogExtraSessionResultsCommentAnswered() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            ScrollView {
                QuestionView(question: PreviewCatalogFixtures.resultQuestion(type: .comment, answered: true), index: 0)
                    .padding()
            }
            .background(Color.themeBackground)
            .navigationTitle("Feedback på spørgsmål")
        }
    }
}

#Preview("session-results.comment.answered") { catalogExtraSessionResultsCommentAnswered() }

@MainActor
private func catalogExtraSessionResultsCommentEmpty() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            ScrollView {
                QuestionView(question: PreviewCatalogFixtures.resultQuestion(type: .comment, answered: false), index: 0)
                    .padding()
            }
            .background(Color.themeBackground)
            .navigationTitle("Feedback på spørgsmål")
        }
    }
}

#Preview("session-results.comment.empty") { catalogExtraSessionResultsCommentEmpty() }

@MainActor
private func catalogExtraHomeRefreshError() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var activity = PreviewCatalogFixtures.activity
            var state = ActivityList.State(
                bootstrap: PreviewCatalogFixtures.bootstrap(activity: activity),
                presentation: .overview, referenceDate: PreviewCatalogFixtures.now
            )
            state.refreshError = "Kunne ikke opdatere. Prøv igen."
            return state
        }()
        ActivityListView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("home.refresh-error") { catalogExtraHomeRefreshError() }

@MainActor
private func catalogExtraHomeUpToDate() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var activity = PreviewCatalogFixtures.activity
            activity.events = []
            activity.overallFeedbackSummary = nil
            var state = ActivityList.State(
                bootstrap: PreviewCatalogFixtures.bootstrap(activity: activity),
                presentation: .overview, referenceDate: PreviewCatalogFixtures.now
            )

            return state
        }()
        ActivityListView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("home.up-to-date") { catalogExtraHomeUpToDate() }

@MainActor
private func catalogExtraHomeNextSessionReady() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var activity = PreviewCatalogFixtures.activity
            var event = PreviewCatalogFixtures.upcomingEvent
            event.questionsSnapshot = [PreviewCatalogFixtures.question]
            activity.events = [event]
            var state = ActivityList.State(
                bootstrap: PreviewCatalogFixtures.bootstrap(activity: activity),
                presentation: .overview, referenceDate: PreviewCatalogFixtures.now
            )

            return state
        }()
        ActivityListView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("home.next-session-ready") { catalogExtraHomeNextSessionReady() }

@MainActor
private func catalogExtraLegacyOnboardingIntro() -> some View {
    ScreenCatalogContainerView {
        OnboardingView(onFinish: {})
    }
}

#Preview("legacy.onboarding.intro") { catalogExtraLegacyOnboardingIntro() }

@MainActor
private func catalogExtraLegacyOnboardingFirstActivity() -> some View {
    ScreenCatalogContainerView {
        FirstRecurringMeetingOnboardingView(onComplete: {})
    }
}

#Preview("legacy.onboarding.first-activity") { catalogExtraLegacyOnboardingFirstActivity() }

    catalogActivityDetailPopulated()
}

#Preview("session-detail.full-content", traits: .fixedLayout(width: 402, height: 1600)) {
    catalogSessionDetailFeedback()
}

#Preview("create-activity.templates.full-content", traits: .fixedLayout(width: 402, height: 1100)) {
    catalogCreateActivityTemplates()
}

#Preview("edit-activity.full-content", traits: .fixedLayout(width: 402, height: 1400)) {
    catalogEditActivityPopulated()
}

#Preview("create-session.custom-duration.full-content", traits: .fixedLayout(width: 402, height: 1400)) {
    catalogCreateSessionCustomDuration()
}

#Preview("questions.answer-type-help.full-content", traits: .fixedLayout(width: 402, height: 1400)) {
    catalogQuestionsAnswerTypeHelp()
}

#endif
