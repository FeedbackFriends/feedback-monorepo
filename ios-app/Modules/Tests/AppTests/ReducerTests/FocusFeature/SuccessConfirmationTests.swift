@testable import ActivityFeature
import ComposableArchitecture
import Testing

@MainActor
struct SuccessConfirmationTests {
    @Test
    func waitsForCompletedTransitionAndIgnoresDuplicateCallbacks() async {
        var state = SuccessConfirmation.State()
        state.queue("Session slettet")
        let clock = TestClock()
        let store = TestStore(initialState: state) { SuccessConfirmation() } withDependencies: {
            $0.continuousClock = clock
        }
        await clock.advance(by: .seconds(10))
        #expect(!store.state.isPresented)
        await store.send(.transitionCompleted) {
            $0.isPending = false
            $0.isPresented = true
        }
        await store.send(.transitionCompleted)
        await clock.advance(by: .seconds(1))
        await store.receive(\.dismiss) { $0.isPresented = false }
        await store.send(.transitionCompleted)
    }
}
