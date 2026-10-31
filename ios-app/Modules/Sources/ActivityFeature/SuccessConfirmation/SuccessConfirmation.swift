import ComposableArchitecture
import DesignSystem

/// The destination queues feedback; only a completed UI transition starts its lifetime.
@Reducer
public struct SuccessConfirmation: Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        var message = ""
        var isPresented = false
        var isPending = false

        mutating func queue(_ message: String) {
            self.message = message
            isPending = true
            isPresented = false
        }
    }

    public enum Action {
        case transitionCompleted
        case dismiss
    }

    @Dependency(\.continuousClock) var clock
    private enum CancelID { case lifetime }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .transitionCompleted:
                guard state.isPending else { return .none }
                state.isPending = false
                state.isPresented = true
                return .run { send in
                    try await clock.sleep(for: Constants.successMessageDuration)
                    await send(.dismiss)
                }
                .cancellable(id: CancelID.lifetime, cancelInFlight: true)
            case .dismiss:
                state.isPresented = false
                return .none
            }
        }
    }
}
