import Domain
import DesignSystem
import Foundation
import ComposableArchitecture
import Utility

@Reducer
public struct ActivityDetail: Sendable {
    
    @Reducer
    public enum Destination {
        case manageEvent(ManageEvent)
        case editActivity(ManageActivity)
        case eventDetail(EventDetailFeature)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        let activityId: UUID
        @Presents var alert: AlertState<Never>?
        public var activity: Activity? {
            guard let activity = self.bootstrap.managerData?.activities.first(where: { $0.id == self.activityId }) else {
                return nil
            }
            return activity
        }
        @Presents var destination: Destination.State?
        var showDeleteConfirmation = false
        var deleteActivityInFlight = false
        @Shared var bootstrap: Bootstrap
        
        var navigationTitle: String {
            activity?.title ?? "Unknown Activity"
        }
        var navigationSubTitle: String {
            "\(activity?.events.count ?? 0) sessions"
        }

        public init(
            activityId: UUID,
            destination: Destination.State? = nil,
            bootstrap: Shared<Bootstrap>
        ) {
            self.activityId = activityId
            self.destination = destination
            self._bootstrap = bootstrap
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<Never>)
        case createEventButtonTapped
        case eventTapped(Event)
        case editActivityButtonTapped
        case deleteActivityButtonTap
        case deleteActivityCancelButtonTap
        case deleteActivityConfirmButtonTap
        case navigateToEvent(Event, presentInvite: Bool)
        case refresh
        case deleteActivitySuccess
        case presentError(Error)
    }
    
    public init() {}
    
    @Dependency(\.calendar) var calendar
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.continuousClock) var clock
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.systemClient) var systemClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .destination(.presented(.manageEvent(.delegate(let delegate)))):
                switch delegate {
                
                case .dismissAndNavigateToEvent(let event):
                    state.destination = nil
                    return .run { send in
                        try await clock.sleep(for: .seconds(0.2))
                        await send(.navigateToEvent(event, presentInvite: true))
                    }
                case .dismissAndUpdateEvent(let event):
                    state.destination = nil
                    return .send(.navigateToEvent(event, presentInvite: false))
                case .dismiss:
                    state.destination = nil
                    return .none
                }
                
            case .binding:
                return .none
                
            case .destination:
                return .none

            case .alert:
                return .none

            case .editActivityButtonTapped:
                guard let activity = state.activity else { return .none }
                state.destination = .editActivity(ManageActivity.State.edit(activity: activity))
                return .none

            case .deleteActivityButtonTap:
                state.showDeleteConfirmation = true
                return .none

            case .deleteActivityCancelButtonTap:
                state.showDeleteConfirmation = false
                return .none

            case .deleteActivityConfirmButtonTap:
                state.deleteActivityInFlight = true
                let activityId = state.activityId
                return .run { send in
                    do {
                        try await self.apiClient.deleteActivity(activityId)
                        await send(.deleteActivitySuccess)
                    } catch {
                        await send(.presentError(error))
                    }
                }

            case .createEventButtonTapped:
                guard let activity = state.activity else { return .none }
                state.destination = .manageEvent(
                    ManageEvent.State.create(activity: activity)
                )
                return .none

            case .eventTapped(let selectedEvent):
                guard
                    let activity = state.activity,
                    let event = activity.events.first(where: { $0.id == selectedEvent.id })
                else {
                    return .none
                }

                state.destination = .eventDetail(
                    EventDetailFeature.State(
                        activityId: state.activityId,
                        eventId: event.id,
                        bootstrap: state.$bootstrap
                    )
                )
                return .none

            case .navigateToEvent(let event, let presentInvite):
                let destination: EventDetailFeature.Destination.State? = presentInvite ? .invite(event) : nil
                state.destination = .eventDetail(
                    EventDetailFeature.State(
                        activityId: state.activityId,
                        eventId: event.id,
                        destination: destination,
                        bootstrap: state.$bootstrap
                    )
                )
                return .none
            
            case .refresh:
                return .none
                
            case .deleteActivitySuccess:
                state.deleteActivityInFlight = false
                state.showDeleteConfirmation = false
                return .run { _ in
                    try await clock.sleep(for: Constants.successOverlayDuration)
                    await self.dismiss()
                }

            case .presentError(let error):
                state.deleteActivityInFlight = false
                state.alert = .init(error: error)
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }
}

extension ActivityDetail.Destination.State: Equatable, Sendable {}
