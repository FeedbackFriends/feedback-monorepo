import ComposableArchitecture
import Foundation
import DesignSystem
import SwiftUI
import Domain
import Logger

@Reducer
public struct ManagerEvents: Sendable {
    
    @Reducer
    public enum Destination {
        case eventDetail(EventDetailFeature)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        
        @Presents public var destination: Destination.State?
        @Shared var session: Session
        public var segmentedControl: SegmentedControlMenu
        public var participantEvents: ParticipantEvents.State
        var searchTextfield: String
        var filterCollection: FilterCollection
        public var startFeedbackPincodeInFlight: String?
        public init(
            destination: Destination.State? = nil,
            session: Shared<Session>,
            segmentedControl: SegmentedControlMenu = .yourEvents,
            searchTextfield: String = "",
            filterCollection: FilterCollection = .initial,
            startFeedbackPincodeInFlight: String? = nil
        ) {
            self.destination = destination
            self._session = session
            self.segmentedControl = segmentedControl
            self.participantEvents = .init(session: session)
            self.searchTextfield = searchTextfield
            self.filterCollection = filterCollection
            self.startFeedbackPincodeInFlight = startFeedbackPincodeInFlight
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case managerEventTap(ManagerEvent)
        case participantEvents(ParticipantEvents.Action)
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.participantEvents, action: \.participantEvents) {
            ParticipantEvents()
        }
        Reduce { state, action in
            switch action {
                
            case .participantEvents:
                return .none
                
            case .destination(.dismiss):
                if case .eventDetail(let eventDetailState) = state.destination,
                   let overallFeedbackSummary = eventDetailState.event.overallFeedbackSummary, overallFeedbackSummary.unseenResponses > 0 {
                    return .run { _ in
                        do {
                            try await self.apiClient.markEventAsSeen(eventDetailState.event.id)
                        } catch {
                            Logger.debug("Mark session as seen failed: \(error.localizedDescription)")
                        }
                    }
                    
                }
                return .none
                
            case .binding:
                return .none
                
            case .managerEventTap(let event):
                state.destination = .eventDetail(
                    EventDetailFeature.State(
                        event: event,
                        session: state.$session
                    )
                )
                return .none
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ManagerEvents.Destination.State: Equatable, Sendable {}
