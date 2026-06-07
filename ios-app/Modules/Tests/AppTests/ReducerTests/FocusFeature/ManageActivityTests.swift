@testable import ActivityFeature
import Testing
import ComposableArchitecture
import Domain

@MainActor
struct ManageActivityTests {
    @Test
    func `Create state defaults to standard meeting preset`() async {
        let state = ManageActivity.State.create()

        #expect(state.selectedTemplate == .standardMeeting)
        #expect(state.questions == FeedbackTemplate.standardMeeting.defaultQuestions)
    }

    @Test
    func `Selecting custom questions clears default questions and opens editor`() async {
        let store = TestStore(initialState: ManageActivity.State.create()) {
            ManageActivity()
        }

        await store.send(.templateSelected(.customQuestions)) {
            $0.selectedTemplate = .customQuestions
            $0.questions = []
            $0.showQuestionsList = true
        }
    }

    @Test
    func `Create recurring meeting sends automatic run mode and delegates to detail`() async {
        let createdActivity = Activity.mock()
        let capturedInput = LockIsolated<ActivityInput?>(nil)
        var initialState = ManageActivity.State.create()
        initialState.title = "Weekly team sync"

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
        #expect(capturedInput.value?.questions == FeedbackTemplate.standardMeeting.defaultQuestions)
    }

    @Test
    func `Create recurring meeting failure shows error alert`() async {
        struct Failure: Error, Equatable {}
        var initialState = ManageActivity.State.create()
        initialState.title = "Weekly team sync"

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
}
