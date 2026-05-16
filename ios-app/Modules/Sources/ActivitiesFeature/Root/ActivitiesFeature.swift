import ComposableArchitecture
import Foundation
import DesignSystem
import SwiftUI
import Domain
import Logger
import Utility

@Reducer
public struct ActivitiesFeature: Sendable {
    
    @Reducer
    public enum Destination {
        case eventDetail(EventDetailFeature)
        case createEvent(CreateEvent)
        case createActivity(CreateActivity)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        
        @Presents public var destination: Destination.State?
        @Presents public var alert: AlertState<Never>?
        @Shared var session: Bootstrap
        public var segmentedControl: SegmentedControlMenu
        public var participantEvents: ParticipantEvents.State
        var searchTextfield: String
        var filterCollection: FilterCollection
        public var startFeedbackPincodeInFlight: String?
        public init(
            destination: Destination.State? = nil,
            session: Shared<Bootstrap>,
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
        case alert(PresentationAction<Never>)
        case activityManagerEventButtonTap(NotificationHistoryItem)
        case managerEventTap(Event)
        case activityCreateSessionTap(Activity)
        case deleteActivityTap(UUID)
        case deleteActivityResponse
        case presentError(Error)
        case createActivityButtonTap
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
            
            case .createActivityButtonTap:
                state.destination = .createActivity(.init())
                return .none
            
            case .activityManagerEventButtonTap(let activityItem):
                state.destination = .eventDetail(
                    EventDetailFeature.State(
                        eventId: activityItem.eventId,
                        detail: state.session.unwrappedManagerSession.managerData.activities[id: activityItem.eventId]?.event,
                        session: state.$session
                    )
                )
                return .run { _ in
                    do {
                        try await apiClient.markEventAsSeen(activityItem.id)
                    } catch {
                        Logger.debug("Reset new feedback failed with error: \(error.localizedDescription)")
                    }
                }

            case .alert:
                return .none

            case .destination(.presented(.createEvent(.delegate(.dismissAndNavigateToDetail(let event))))):
                state.destination = .eventDetail(
                    EventDetailFeature.State(
                        eventId: event.id,
                        detail: event.event,
                        session: state.$session
                    )
                )
                return .none
                
            case .destination(.dismiss):
                if case .eventDetail(let eventDetailState) = state.destination,
                   let overallFeedbackSummary = eventDetailState.detail?.overallFeedbackSummary,
                   overallFeedbackSummary.unseenResponses > 0 {
                    return .run { _ in
                        do {
                            try await self.apiClient.markEventAsSeen(eventDetailState.eventId)
                        } catch {
                            Logger.debug("Mark session as seen failed: \(error.localizedDescription)")
                        }
                    }
                    
                }
                return .none
                
            case .binding:
                return .none

            case .deleteActivityTap(let activityId):
                return .run { send in
                    do {
                        try await apiClient.deleteActivity(activityId)
                        await send(.deleteActivityResponse)
                    } catch {
                        await send(.presentError(error))
                    }
                }

            case .deleteActivityResponse:
                return .none

            case .presentError(let error):
                state.alert = .init(error: error)
                return .none

            case .activityCreateSessionTap(let activity):
                let recentlyUsedQuestions = state.session.managerData?.recentlyUsedQuestions ?? []
                var eventInput = EventInput(activity)
                eventInput.date = Date().roundedUpcoming5Min()
                state.destination = .createEvent(
                    CreateEvent.State(
                        activityId: activity.id,
                        eventForm: EventForm.State(
                            eventInput: eventInput,
                            shouldOpenKeyboardOnAppear: false,
                            recentlyUsedQuestions: recentlyUsedQuestions,
                            successOverlayMessage: "Session created"
                        )
                    )
                )
                return .none
                
            case .managerEventTap(let event):
                state.destination = .eventDetail(
                    EventDetailFeature.State(
                        eventId: event.id,
                        detail: event,
                        session: state.$session
                    )
                )
                return .none
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }
}

extension ActivitiesFeature.Destination.State: Equatable, Sendable {}
