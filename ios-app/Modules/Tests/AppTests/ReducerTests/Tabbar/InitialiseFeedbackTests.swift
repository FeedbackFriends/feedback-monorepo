@testable import TabbarFeature
@testable import FeedbackFlowFeature
import ComposableArchitecture
import Testing
import Foundation
import Domain

@MainActor
struct InitialiseFeedbackTests {
    
    let session = FeedbackSession.init(
        title: "Hello",
        agenda: nil,
        questions: [
            .init(
                id: UUID(),
                questionText: "Hello",
                feedbackType: .emoji
            )
        ],
        ownerInfo: .init(
            name: nil,
            email: nil,
            phoneNumber: nil
        ),
        pinCode: .init(value: "1234"),
        date: Date()
    )
    
    @Test
    func `Start feedback success navigates to feedback flow correctly`() async {
        let store = TestStore(initialState: InitialiseFeedback.State()) {
            InitialiseFeedback()
        } withDependencies: {
            $0.apiClient.startFeedbackSession = { _ in session }
        }
        await store.send(.startFeedback(pinCode: session.pinCode))
        await store.withExhaustivity(.off) {
            await store.receive(\.startFeedbackSessionResponse) {
                guard case let .feedbackFlowCoordinator(flowState) = $0.destination else {
                    XCTFail("Expected .feedbackFlowCoordinator")
                    return
                }
                
                #expect(flowState.feedbackSession == session)
                #expect(flowState.submitFeedbackInFlight == false)
                #expect(flowState.presentSuccessOverlay == false)
                #expect(flowState.commentTextfieldFocused == false)
                #expect(flowState.questions.count == session.questions.count)
                #expect(flowState.path.count == 1)
            }

        }
        await store.receive(\.delegate, .stopLoading)
    }

    @Test
    func `Start feedback failure shows alert and stops loading`() async {
        let error = URLError(.cannotFindHost)
        let store = TestStore(initialState: InitialiseFeedback.State()) {
            InitialiseFeedback()
        } withDependencies: {
            $0.apiClient.startFeedbackSession = { _ in throw error }
        }

        await store.send(.startFeedback(pinCode: PinCode(value: "1234")))
        await store.receive(\.presentError) {
            $0.destination = .alert(.init(error: error))
        }
        await store.receive(\.delegate, .stopLoading)
    }
}
