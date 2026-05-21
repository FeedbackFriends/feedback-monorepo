import Domain
import DesignSystem
import Foundation
import ComposableArchitecture
import Utility

@Reducer
public struct ActivityDetail: Sendable {
    
    @Reducer
    public enum Destination {
        case createEvent(CreateEvent)
        case editActivity(ManageActivity)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        let activityId: UUID
        @Presents var alert: AlertState<Never>?
        public var activity: Activity? {
            guard let activity = self.session.managerData?.activities.first(where: { $0.id == self.activityId }) else {
                return nil
            }
            return activity
        }
        public var detail: Event? {
            guard let activity else { return nil }
            return activity.event
        }
        @Presents var destination: Destination.State?
        var showDeleteConfirmation = false
        var deleteActivityInFlight = false
        @Shared var session: Bootstrap
        
        var navigationTitle: String {
            activity?.title ?? "Unknown Activity"
        }
        var navigationSubTitle: String {
            "\(detail?.overallFeedbackSummary?.responses ?? 0) responses"
        }

        public init(
            activityId: UUID,
            destination: Destination.State? = nil,
            session: Shared<Bootstrap>
        ) {
            self.activityId = activityId
            self.destination = destination
            self._session = session
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<Never>)
        case createEventButtonTapped
        case editActivityButtonTapped
        case deleteActivityButtonTap
        case deleteActivityCancelButtonTap
        case deleteActivityConfirmButtonTap
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
                
            case .binding:
                return .none
                
            case .destination:
                return .none

            case .alert:
                return .none

            case .editActivityButtonTapped:
                guard let activity = state.activity else { return .none }
                state.destination = .editActivity(ManageActivity.State(activity: activity))
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
                var eventInput = EventInput(activity)
                eventInput.date = Date().roundedUpcoming5Min()
                let recentlyUsedQuestions = state.session.managerData?.recentlyUsedQuestions ?? []
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
