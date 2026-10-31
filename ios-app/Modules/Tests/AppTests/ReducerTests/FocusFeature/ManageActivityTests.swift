@testable import ActivityFeature
import Testing
import ComposableArchitecture
import Domain
import FeedbackFlowFeature

@MainActor
struct ManageActivityTests {
    @Test
    func `Create state requires an explicit template choice`() async {
        let state = ManageActivity.State.create()

        #expect(state.selectedTemplate == nil)
        #expect(state.questions.isEmpty)
        #expect(state.isChoosingTemplate)
    }

    @Test
    func `Selecting custom questions keeps the user on the template step`() async {
        let store = TestStore(initialState: ManageActivity.State.create()) {
            ManageActivity()
        }

        await store.send(.templateSelected(.customQuestions)) {
            $0.selectedTemplate = .customQuestions
            $0.questions = []
            $0.isChoosingTemplate = false
        }
    }

    @Test
    func `Create recurring meeting sends automatic run mode and delegates to detail`() async {
        let createdActivity = Activity.mock()
        let capturedInput = LockIsolated<ActivityInput?>(nil)
        var initialState = ManageActivity.State.create()
        initialState.title = "Weekly team sync"
        initialState.selectTemplate(.standardMeeting)
        initialState.path = [.template]

        let store = TestStore(initialState: initialState) {
            ManageActivity()
        } withDependencies: {
            $0.apiClient.createActivity = { input in
                capturedInput.setValue(input)
                return createdActivity
            }
        }

        await store.send(.actionButtonTap) {
            $0.createActivityRequestInFlight = true
        }

        await store.receive(\.createResponse, createdActivity) {
            $0.createActivityRequestInFlight = false
        }

        await store.receive(\.delegate, .dismissAndNavigateToDetail(createdActivity))
        #expect(capturedInput.value?.runMode == .automatic)
        #expect(capturedInput.value?.title == "Weekly team sync")
        #expect(capturedInput.value?.questions == initialState.questions)
    }

    @Test
    func updateDelegatesResultToNavigationOwner() async {
        let activity = Activity.mock()
        let store = TestStore(initialState: ManageActivity.State.edit(activity: activity)) { ManageActivity() }
        await store.send(.updateResponse(activity))
        await store.receive(\.delegate, .activityUpdated(activity))
    }

    @Test
    func `Create recurring meeting failure shows error alert`() async {
        struct Failure: Error, Equatable {}
        var initialState = ManageActivity.State.create()
        initialState.title = "Weekly team sync"
        initialState.selectTemplate(.standardMeeting)
        initialState.path = [.template]

        let store = TestStore(initialState: initialState) {
            ManageActivity()
        } withDependencies: {
            $0.apiClient.createActivity = { _ in throw Failure() }
        }

        await store.send(.actionButtonTap) {
            $0.createActivityRequestInFlight = true
        }

        await store.receive(\.presentError) {
            $0.createActivityRequestInFlight = false
            $0.alert = .init(error: Failure())
        }
    }
    @Test
    func `Invalid submission stays disabled without sending a request`() async {
        var state = ManageActivity.State.create()
        state.path = [.template, .questions]
        let store = TestStore(initialState: state) { ManageActivity() }
        await store.send(.actionButtonTap)
        #expect(store.state.isTitleMissing)
        #expect(store.state.activityInput == nil)
    }

    @Test
    func `Next requires a name before opening the template step`() async {
        let store = TestStore(initialState: ManageActivity.State.create()) { ManageActivity() }
        await store.send(.nextButtonTap)
        #expect(store.state.path.isEmpty)
        #expect(store.state.isNextDisabled)
        await store.send(.binding(.set(\.title, "Teammøde"))) { $0.title = "Teammøde" }
        await store.send(.nextButtonTap) {
            $0.path = [.template]
        }
        await store.send(.nextButtonTap)
        #expect(store.state.path == [.template])
        #expect(store.state.isNextDisabled)
    }

    @Test
    func `Creation cannot submit from the name screen or question editor`() async {
        var state = ManageActivity.State.create()
        state.title = "Teammøde"
        state.selectTemplate(.standardMeeting)
        let store = TestStore(initialState: state) { ManageActivity() }
        await store.send(.actionButtonTap)
        await store.send(.nextButtonTap) { $0.path = [.template] }
        #expect(!store.state.isSubmitDisabled)
        await store.send(.binding(.set(\.path, [.template, .questions]))) {
            $0.path = [.template, .questions]
        }
        await store.send(.actionButtonTap)
        #expect(!store.state.createActivityRequestInFlight)
    }

    @Test
    func `Going back preserves the name and customized questions`() async {
        var state = ManageActivity.State.create()
        state.title = "Teammøde"
        state.selectTemplate(.standardMeeting)
        state.questions[0].questionText = "Mit spørgsmål"
        state.path = [.template, .questions]
        let originalQuestions = state.questions
        let store = TestStore(initialState: state) { ManageActivity() }
        await store.send(.binding(.set(\.path, [.template]))) { $0.path = [.template] }
        #expect(!store.state.isSubmitDisabled)
        await store.send(.binding(.set(\.path, []))) { $0.path = [] }
        await store.send(.nextButtonTap) { $0.path = [.template] }
        #expect(store.state.title == "Teammøde")
        #expect(store.state.questions == originalQuestions)
    }

    @Test
    func `Name alone and an empty custom template cannot be submitted`() {
        var state = ManageActivity.State.create()
        state.title = "Teammøde"
        #expect(state.activityInput == nil)
        state.selectTemplate(.customQuestions)
        #expect(state.activityInput == nil)
        state.questions = [.init(questionText: "Hvordan gik det?", feedbackType: .comment)]
        #expect(state.activityInput != nil)
        state.title = "  \n "
        #expect(state.activityInput == nil)
    }

    @Test
    func `Submit is disabled when required question text is blank`() {
        var state = ManageActivity.State.create()
        state.title = "Teammøde"
        state.selectTemplate(.customQuestions)
        state.path = [.template]
        #expect(state.isSubmitDisabled)
        state.questions = [.init(questionText: "   ", feedbackType: .comment)]
        #expect(state.isSubmitDisabled)
        state.questions[0].questionText = "Hvordan gik det?"
        #expect(!state.isSubmitDisabled)
        state.createActivityRequestInFlight = true
        #expect(state.isSubmitDisabled)
    }

    @Test
    func `Opening template choices and reselecting preserves customizations`() async {
        var state = ManageActivity.State.create()
        state.selectTemplate(.standardMeeting)
        state.questions[0].questionText = "Mit spørgsmål"
        let originalQuestions = state.questions
        let store = TestStore(initialState: state) { ManageActivity() }
        await store.send(.changeTemplateTapped) { $0.isChoosingTemplate = true }
        await store.send(.templateSelected(.standardMeeting)) { $0.isChoosingTemplate = false }
        #expect(store.state.questions == originalQuestions)
    }

    @Test
    func `Replacing customized questions requires confirmation and can be cancelled`() async {
        var state = ManageActivity.State.create()
        state.selectTemplate(.standardMeeting)
        state.questions.removeLast()
        let originalQuestions = state.questions
        let store = TestStore(initialState: state) { ManageActivity() }
        await store.send(.changeTemplateTapped) { $0.isChoosingTemplate = true }
        await store.withExhaustivity(.off) {
            await store.send(.templateSelected(.workshop))
        }
        #expect(store.state.alert != nil)
        #expect(store.state.questions == originalQuestions)
        await store.send(.alert(.dismiss)) { $0.alert = nil }
        #expect(store.state.questions == originalQuestions)
        await store.withExhaustivity(.off) {
            await store.send(.templateSelected(.workshop))
            await store.send(.alert(.presented(.replaceTemplate(.workshop))))
        }
        #expect(store.state.selectedTemplate == .workshop)
        #expect(!store.state.hasCustomizedQuestions)
        #expect(!store.state.isChoosingTemplate)
    }

    @Test
    func `Unmodified template switches without confirmation`() async {
        var state = ManageActivity.State.create()
        state.selectTemplate(.standardMeeting)
        let store = TestStore(initialState: state) { ManageActivity() }
        await store.withExhaustivity(.off) {
            await store.send(.templateSelected(.workshop))
        }
        #expect(store.state.selectedTemplate == .workshop)
        #expect(store.state.alert == nil)
    }

    @Test(arguments: [false, true])
    func `Preview close and completion dismiss only preview preserving questions`(complete: Bool) async {
        var state = ManageActivity.State.create()
        state.selectTemplate(.standardMeeting)
        state.path = [.template, .questions]
        let originalQuestions = state.questions
        var preview = FeedbackFlowCoordinator.State.initialState(feedbackSession: .init(
            questions: originalQuestions.map {
                ParticipantQuestion(id: $0.id, questionText: $0.questionText, feedbackType: $0.feedbackType)
            },
            ownerInfo: .init(name: nil, email: nil, phoneNumber: nil),
            pinCode: .init(value: "Preview"), date: .now
        ))
        preview.isPreview = true
        state.previewSession = preview
        let store = TestStore(initialState: state) { ManageActivity() }
        await store.send(.previewSession(.presented(complete ? .submitButtonTap : .dismissButtonTap)))
        await store.receive(\.previewSession.dismiss) { $0.previewSession = nil }
        #expect(store.state.questions == originalQuestions)
        #expect(store.state.path == [.template, .questions])
    }

}
