#if DEBUG
import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

extension JoinEvent.State {
    public static var screenCatalogSuccess: Self {
        var state = Self(pinCodeInput: .init(value: "1234"))
        state.showSuccessOverlay = true
        return state
    }
}

extension ActivityList.State {
    public static var screenCatalogRefreshError: Self {
        var state = Self(
            bootstrap: PreviewCatalogFixtures.bootstrap(),
            referenceDate: PreviewCatalogFixtures.now
        )
        state.destination = .alert(.refreshFailure)
        return state
    }
}

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

#Preview("activity-detail.populated.content-only") { catalogActivityDetailPopulated() }

@MainActor
private func catalogActivityDetailNoSessions() -> some View {
    ScreenCatalogContainerView {
        CatalogActivity.detail(PreviewCatalogFixtures.emptyActivity)
    }
}

#Preview("activity-detail.no-sessions.content-only") { catalogActivityDetailNoSessions() }

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

// Screenshot: Activity with sessions but no feedback hides the trend section.
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

#Preview("session-detail.no-feedback.content-only") { catalogSessionDetailNoFeedback() }

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

// Screenshot: Main screen.
#Preview("create-activity.details") { catalogCreateActivityDetails() }

@MainActor
private func catalogCreateActivityTemplates() -> some View {
    ScreenCatalogContainerView {
        ManageActivityView(store: Store(initialState: CatalogActivity.createActivity(step: .template)) { EmptyReducer() })
    }
}

// Screenshot: Combined feedback step before choosing a template.
#Preview("create-activity.templates") { catalogCreateActivityTemplates() }

@MainActor
private func catalogCreateActivityQuestions() -> some View {
    ScreenCatalogContainerView {
        ManageActivityView(store: Store(initialState: CatalogActivity.createActivity(step: .questions)) { EmptyReducer() })
    }
}

// Screenshot: Main screen.
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
            var state = CatalogActivity.createActivity(step: .template)
            state.selectTemplate(.standardMeeting)
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

// Screenshot: Combined feedback step with questions and create action.
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

// Screenshot: Main screen.
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

// Screenshot: Distinct role or content layout.
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

// Screenshot: Distinct role or content layout.
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

// Screenshot: Distinct screen or presentation.
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

// Screenshot: Main screen.
#Preview("edit-session.populated") { catalogEditSessionPopulated() }

@MainActor
private func catalogQuestionsPopulated() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            QuestionsListView(questionsInputs: .constant(CatalogActivity.questionInputs), onPreview: { _ in })
        }
    }
}

// Screenshot: Main screen.
#Preview("questions.populated") { catalogQuestionsPopulated() }

@MainActor
private func catalogQuestionsEmpty() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            QuestionsListView(questionsInputs: .constant([]), onPreview: { _ in })
        }
    }
}

// Screenshot: Distinct empty layout.
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

// Screenshot: Main screen.
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

// Screenshot: Distinct role or content layout.
#Preview("question-editor.long-text") { catalogQuestionEditorLongText() }

@MainActor
func catalogQuestionEditorThumbs() -> some View {
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
        catalogQuestionEditorEdit()
            .sheet(isPresented: .constant(true)) {
                FeedbackTypeInfoSheetView()
            }
    }
}

// Screenshot: Sheet presentation over the question editor.
#Preview("questions.answer-type-help") { catalogQuestionsAnswerTypeHelp() }

@MainActor
private func catalogActivityHowItWorks() -> some View {
    ScreenCatalogContainerView {
        var state = ActivityDetail.State(
            activityId: PreviewCatalogFixtures.activity.id,
            bootstrap: PreviewCatalogFixtures.bootstrap(activity: PreviewCatalogFixtures.activity)
        )
        state.destination = .showHowItWorks
        return NavigationStack {
            ActivityDetailView(store: Store(initialState: state) {
                Reduce<ActivityDetail.State, ActivityDetail.Action> { state, action in
                    if case .destination(.dismiss) = action {
                        state.destination = nil
                    }
                    return .none
                }
            })
        }
    }
}

// Screenshot: Distinct screen or presentation.
#Preview("activity.how-it-works") { catalogActivityHowItWorks() }

@MainActor
private func catalogSessionInvite() -> some View {
    ScreenCatalogContainerView {
        let event = PreviewCatalogFixtures.upcomingEvent
        var activity = PreviewCatalogFixtures.activity
        activity.events = [event]
        var state = EventDetailFeature.State(
            activityId: activity.id, eventId: event.id,
            bootstrap: PreviewCatalogFixtures.bootstrap(activity: activity),
            webBaseUrl: URL(string: "https://letsgrow.dk")
        )
        state.destination = .invite(event)
        return NavigationStack {
            EventDetailFeatureView(store: Store(initialState: state) {
                Reduce<EventDetailFeature.State, EventDetailFeature.Action> { state, action in
                    if case .destination(.dismiss) = action {
                        state.destination = nil
                    }
                    return .none
                }
            })
        }
    }
}

// Screenshot: Distinct screen or presentation.
#Preview("session.invite") { catalogSessionInvite() }

@MainActor
private func catalogSessionInviteUnavailable() -> some View {
    ScreenCatalogContainerView {
        let event = PreviewCatalogFixtures.upcomingEvent
        var activity = PreviewCatalogFixtures.activity
        activity.events = [event]
        var state = EventDetailFeature.State(
            activityId: activity.id, eventId: event.id,
            bootstrap: PreviewCatalogFixtures.bootstrap(activity: activity),
            webBaseUrl: nil
        )
        state.destination = .invite(event)
        return NavigationStack {
            EventDetailFeatureView(store: Store(initialState: state) {
                Reduce<EventDetailFeature.State, EventDetailFeature.Action> { state, action in
                    if case .destination(.dismiss) = action {
                        state.destination = nil
                    }
                    return .none
                }
            })
        }
    }
}

#Preview("session.invite-unavailable") { catalogSessionInviteUnavailable() }

@MainActor
private func catalogNotificationsEmpty() -> some View {
    ScreenCatalogContainerView {
        NotificationHistoryView(notificationHistoryItems: [], activityManagerEventButtonTap: { _ in })
    }
}

// Screenshot: Distinct empty layout.
#Preview("notifications.empty") { catalogNotificationsEmpty() }

@MainActor
private func catalogNotificationsUnread() -> some View {
    ScreenCatalogContainerView {
        NotificationHistoryView(notificationHistoryItems: [PreviewCatalogFixtures.notification], activityManagerEventButtonTap: { _ in })
    }
}

// Screenshot: Main screen.
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
func catalogJoinSessionEmpty() -> some View {
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
func catalogJoinSessionPartial() -> some View {
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
func catalogJoinSessionReady() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = JoinEvent.State(pinCodeInput: .init(value: "1234"))

            return state
        }()
        JoinEventView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("join-session.content-ready") { catalogJoinSessionReady() }

@MainActor
func catalogJoinSessionLoading() -> some View {
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
func catalogJoinSessionSuccess() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = JoinEvent.State(pinCodeInput: .init(value: "1234"))
            state.showSuccessOverlay = true
            return state
        }()
        JoinEventView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("join-session.content-success") { catalogJoinSessionSuccess() }

@MainActor
private func catalogActivityDeleteConfirmation() -> some View {
    ScreenCatalogContainerView {
        var state = ActivityDetail.State(
            activityId: PreviewCatalogFixtures.activity.id,
            bootstrap: PreviewCatalogFixtures.bootstrap(activity: PreviewCatalogFixtures.activity)
        )
        state.destination = .showDeleteConfirmation
        state.deleteActivityInFlight = false
        return NavigationStack {
            ActivityDetailView(store: Store(initialState: state) {
                Reduce<ActivityDetail.State, ActivityDetail.Action> { state, action in
                    if case .destination(.dismiss) = action {
                        state.destination = nil
                    }
                    return .none
                }
            })
        }
    }
}

// Screenshot: Distinct screen or presentation.
#Preview("activity.delete-confirmation") { catalogActivityDeleteConfirmation() }

@MainActor
private func catalogActivityDeleteConfirmationLoading() -> some View {
    ScreenCatalogContainerView {
        var state = ActivityDetail.State(
            activityId: PreviewCatalogFixtures.activity.id,
            bootstrap: PreviewCatalogFixtures.bootstrap(activity: PreviewCatalogFixtures.activity)
        )
        state.destination = .showDeleteConfirmation
        state.deleteActivityInFlight = true
        return NavigationStack {
            ActivityDetailView(store: Store(initialState: state) {
                Reduce<ActivityDetail.State, ActivityDetail.Action> { state, action in
                    if case .destination(.dismiss) = action {
                        state.destination = nil
                    }
                    return .none
                }
            })
        }
    }
}

#Preview("activity.delete-confirmation-loading") { catalogActivityDeleteConfirmationLoading() }

@MainActor
private func catalogSessionDeleteConfirmation() -> some View {
    ScreenCatalogContainerView {
        var state = EventDetailFeature.State(
            activityId: PreviewCatalogFixtures.activity.id,
            eventId: PreviewCatalogFixtures.previousEvent.id,
            bootstrap: PreviewCatalogFixtures.bootstrap(activity: PreviewCatalogFixtures.activity),
            webBaseUrl: URL(string: "https://letsgrow.dk")
        )
        state.showDeleteConfirmation = true
        state.deleteEventInFlight = false
        return NavigationStack {
            EventDetailFeatureView(store: Store(initialState: state) {
                BindingReducer()
            })
        }
    }
}

// Screenshot: Distinct screen or presentation.
#Preview("session.delete-confirmation") { catalogSessionDeleteConfirmation() }

@MainActor
private func catalogSessionDeleteConfirmationLoading() -> some View {
    ScreenCatalogContainerView {
        var state = EventDetailFeature.State(
            activityId: PreviewCatalogFixtures.activity.id,
            eventId: PreviewCatalogFixtures.previousEvent.id,
            bootstrap: PreviewCatalogFixtures.bootstrap(activity: PreviewCatalogFixtures.activity),
            webBaseUrl: URL(string: "https://letsgrow.dk")
        )
        state.showDeleteConfirmation = true
        state.deleteEventInFlight = true
        return NavigationStack {
            EventDetailFeatureView(store: Store(initialState: state) {
                BindingReducer()
            })
        }
    }
}

#Preview("session.delete-confirmation-loading") { catalogSessionDeleteConfirmationLoading() }

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

// Screenshot: Main screen.
#Preview("activity.all-sessions") { catalogActivityAllSessions() }

@MainActor
private func catalogSessionFeedbackComments() -> some View {
    ScreenCatalogContainerView {
        ScrollView {
            QuestionView(question: PreviewCatalogFixtures.question, index: 0).padding()
        }.background(Color.themeBackground)
    }
}

// Screenshot: Main screen.
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

// Screenshot: Distinct answer control.
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

// Screenshot: Distinct answer control.
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

// Screenshot: Distinct answer control.
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

// Screenshot: Distinct answer control.
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

// Screenshot: Distinct answer control.
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

// Screenshot: Distinct answer control.
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

// BEGIN GENERATED SNAPSHOT CATALOG
// Generated by scripts/screen-catalog.py --generate. Do not edit this section.
@MainActor
enum ActivityFeatureScreenSnapshotCatalog {
    static var samples: [ScreenSnapshotSample] {
        [
            .init(id: "activity-detail.no-feedback", size: CGSize(width: 402, height: 874)) {
                catalogActivityDetailNoFeedback()
            },
            .init(id: "create-activity.details", size: CGSize(width: 402, height: 874)) {
                catalogCreateActivityDetails()
            },
            .init(id: "create-activity.templates", size: CGSize(width: 402, height: 874)) {
                catalogCreateActivityTemplates()
            },
            .init(id: "create-activity.questions", size: CGSize(width: 402, height: 874)) {
                catalogCreateActivityQuestions()
            },
            .init(id: "create-activity.template-selected", size: CGSize(width: 402, height: 874)) {
                catalogCreateActivityTemplateSelected()
            },
            .init(id: "create-session.scheduled", size: CGSize(width: 402, height: 874)) {
                catalogCreateSessionScheduled()
            },
            .init(id: "create-session.start-now", size: CGSize(width: 402, height: 874)) {
                catalogCreateSessionStartNow()
            },
            .init(id: "create-session.all-day", size: CGSize(width: 402, height: 874)) {
                catalogCreateSessionAllDay()
            },
            .init(id: "create-session.success", size: CGSize(width: 402, height: 874)) {
                catalogCreateSessionSuccess()
            },
            .init(id: "edit-session.populated", size: CGSize(width: 402, height: 874)) {
                catalogEditSessionPopulated()
            },
            .init(id: "questions.populated", size: CGSize(width: 402, height: 874)) {
                catalogQuestionsPopulated()
            },
            .init(id: "questions.empty", size: CGSize(width: 402, height: 874)) {
                catalogQuestionsEmpty()
            },
            .init(id: "question-editor.edit", size: CGSize(width: 402, height: 874)) {
                catalogQuestionEditorEdit()
            },
            .init(id: "question-editor.long-text", size: CGSize(width: 402, height: 874)) {
                catalogQuestionEditorLongText()
            },
            .init(id: "questions.answer-type-help", size: CGSize(width: 402, height: 874)) {
                catalogQuestionsAnswerTypeHelp()
            },
            .init(id: "activity.how-it-works", size: CGSize(width: 402, height: 874)) {
                catalogActivityHowItWorks()
            },
            .init(id: "session.invite", size: CGSize(width: 402, height: 874)) {
                catalogSessionInvite()
            },
            .init(id: "notifications.empty", size: CGSize(width: 402, height: 874)) {
                catalogNotificationsEmpty()
            },
            .init(id: "notifications.unread", size: CGSize(width: 402, height: 874)) {
                catalogNotificationsUnread()
            },
            .init(id: "activity.delete-confirmation", size: CGSize(width: 402, height: 874)) {
                catalogActivityDeleteConfirmation()
            },
            .init(id: "session.delete-confirmation", size: CGSize(width: 402, height: 874)) {
                catalogSessionDeleteConfirmation()
            },
            .init(id: "activity.all-sessions", size: CGSize(width: 402, height: 874)) {
                catalogActivityAllSessions()
            },
            .init(id: "session.feedback-comments", size: CGSize(width: 402, height: 874)) {
                catalogSessionFeedbackComments()
            },
            .init(id: "session-results.emoji.answered", size: CGSize(width: 402, height: 874)) {
                catalogExtraSessionResultsEmojiAnswered()
            },
            .init(id: "session-results.emoji.empty", size: CGSize(width: 402, height: 874)) {
                catalogExtraSessionResultsEmojiEmpty()
            },
            .init(id: "session-results.rating.answered", size: CGSize(width: 402, height: 874)) {
                catalogExtraSessionResultsRatingAnswered()
            },
            .init(id: "session-results.thumbs.answered", size: CGSize(width: 402, height: 874)) {
                catalogExtraSessionResultsThumbsAnswered()
            },
            .init(id: "session-results.opinion.answered", size: CGSize(width: 402, height: 874)) {
                catalogExtraSessionResultsOpinionAnswered()
            },
            .init(id: "session-results.comment.answered", size: CGSize(width: 402, height: 874)) {
                catalogExtraSessionResultsCommentAnswered()
            }
        ]
    }
}
// END GENERATED SNAPSHOT CATALOG
#endif
