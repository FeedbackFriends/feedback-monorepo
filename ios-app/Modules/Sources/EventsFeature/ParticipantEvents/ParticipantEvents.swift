import ComposableArchitecture
import Domain
import SwiftUI

@Reducer
public struct ParticipantEvents: Sendable {

    public enum Segment: String, CaseIterable, Hashable, Sendable {
        case invited
        case history
    }
    
    @Reducer
    public enum Destination {
        @ReducerCaseIgnored
        case info(ParticipantEvent)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents public var destination: Destination.State?
        @Shared var session: Session
        public var selectedSegment: Segment = .invited
        public var historyBadgeCount = 0
        var seenHistoryEventIDs: Set<UUID> = []
        var hasInitializedHistoryTracking = false
        public var startFeedbackPincodeInFlight: PinCode?
        public init(session: Shared<Session>) {
            self._session = session
        }
    }
    
    public enum Action: BindableAction {
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case participantEventsChanged([ParticipantEvent])
        case infoButtonTap(ParticipantEvent)
        case startFeedbackButtonTap(pinCode: PinCode)
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case startFeedback(pinCode: PinCode)
            case navigateToSignUp
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {

            case .binding(\.selectedSegment):
                if state.selectedSegment == .history {
                    let historyEventIDs = historyEventIDs(in: state.session.participantEvents.map { $0 })
                    state.seenHistoryEventIDs.formUnion(historyEventIDs)
                    state.hasInitializedHistoryTracking = true
                    state.historyBadgeCount = 0
                }
                return .none
                
            case .binding:
                return .none

            case .participantEventsChanged(let participantEvents):
                let historyEventIDs = historyEventIDs(in: participantEvents)

                if !state.hasInitializedHistoryTracking {
                    state.seenHistoryEventIDs = historyEventIDs
                    state.hasInitializedHistoryTracking = true
                    state.historyBadgeCount = 0
                    return .none
                }

                if state.selectedSegment == .history {
                    state.seenHistoryEventIDs.formUnion(historyEventIDs)
                    state.historyBadgeCount = 0
                    return .none
                }

                state.historyBadgeCount = historyEventIDs.subtracting(state.seenHistoryEventIDs).count
                return .none
                
            case .destination:
                return .none
                
            case .startFeedbackButtonTap(pinCode: let pinCode):
                state.startFeedbackPincodeInFlight = pinCode
                return .send(.delegate(.startFeedback(pinCode: pinCode)))
                
            case .delegate:
                return .none
                
            case .infoButtonTap(let event):
                state.destination = .info(event)
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    private func historyEventIDs(in participantEvents: [ParticipantEvent]) -> Set<UUID> {
        Set(
            participantEvents
                .filter { $0.feedbackSubmitted || $0.date.isBeforeToday }
                .map(\.id)
        )
    }
}

extension ParticipantEvents.Destination.State: Equatable, Sendable {}
