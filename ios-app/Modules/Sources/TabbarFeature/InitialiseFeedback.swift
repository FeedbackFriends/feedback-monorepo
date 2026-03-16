import Foundation
import Domain
import DesignSystem
import FeedbackFlowFeature
import ComposableArchitecture
import SwiftUI

@Reducer
public struct InitialiseFeedback: Sendable {
    
    @Reducer
    public enum Destination {
        case feedbackFlowCoordinator(FeedbackFlowCoordinator)
        case alert(AlertState<Never>)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents public var destination: Destination.State?
        public init() {}
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case startFeedback(pinCode: PinCode)
        case startFeedbackSessionResponse(FeedbackSession)
        case presentError(Error)
        case delegate(Delegate)
        public enum Delegate {
            case stopLoading
        }
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.continuousClock) var clock
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .binding:
                return .none
                
            case .startFeedback(let pinCode):
                return .run { send in
                    do {
                        let feedbackSession = try await apiClient.startFeedbackSession(pinCode)
                        await send(.startFeedbackSessionResponse(feedbackSession))
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .destination:
                return .none
                
            case .startFeedbackSessionResponse(let feedbackSession):
                state.destination = .feedbackFlowCoordinator(
                    FeedbackFlowCoordinator.State.initialState(feedbackSession: feedbackSession)
                )
                return .send(.delegate(.stopLoading))
                
            case .presentError(let error):
                state.destination = .alert(
                    .init(error: error)
                )
                return .send(.delegate(.stopLoading))
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension InitialiseFeedback.Destination.State: Sendable, Equatable {}
