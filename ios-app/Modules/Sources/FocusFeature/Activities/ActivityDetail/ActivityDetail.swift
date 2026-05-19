import Domain
import DesignSystem
import Foundation
import ComposableArchitecture
import Utility

@Reducer
public struct ActivityDetail: Sendable {
    
    @Reducer
    public enum Destination {
        case deleteConfirmation(DeleteConfirmation)
        case createEvent(CreateEvent)
        case editActivity(ManageActivity)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        public var activity: Activity
        public var detail: Event?
        @Presents var destination: Destination.State?
        var pendingAutoInvite = false
        var fetchEventDetailInFlight = true
        @Shared var session: Bootstrap
        
        var navigationTitle: String {
            activity.title
        }
        var navigationSubTitle: String {
            "\(detail?.overallFeedbackSummary?.responses ?? 0) responses"
        }

        public init(
            activity: Activity,
            detail: Event? = nil,
            destination: Destination.State? = nil,
            pendingAutoInvite: Bool = false,
            fetchEventDetailInFlight: Bool = true,
            session: Shared<Bootstrap>
        ) {
            self.activity = activity
            self.detail = detail ?? activity.event
            self.destination = destination
            self.pendingAutoInvite = pendingAutoInvite
            self.fetchEventDetailInFlight = fetchEventDetailInFlight
            self._session = session
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case createEventButtonTapped
        case editActivityButtonTapped
        case retryButtonTap
        case refresh
        case sessionUpdated(Bootstrap)
        case deleteActivityButtonTap
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
                
            case .deleteActivityButtonTap:
                state.destination = .deleteConfirmation(.init(eventId: state.activity.id))
                return .none
                
            case .destination(.presented(.deleteConfirmation(.delegate(.dismissEventDetail)))):
                return .run { _ in
                    try await clock.sleep(for: .seconds(2.5))
                    await dismiss()
                }
                
            case .binding:
                return .none
                
            case .destination:
                return .none

            case .editActivityButtonTapped:
                state.destination = .editActivity(ManageActivity.State(activity: state.activity))
                return .none

            case .createEventButtonTapped:
                var eventInput = EventInput(state.activity)
                eventInput.date = Date().roundedUpcoming5Min()
                let recentlyUsedQuestions = state.session.managerData?.recentlyUsedQuestions ?? []
                state.destination = .createEvent(
                    CreateEvent.State(
                        activityId: state.activity.id,
                        eventForm: EventForm.State(
                            eventInput: eventInput,
                            shouldOpenKeyboardOnAppear: false,
                            recentlyUsedQuestions: recentlyUsedQuestions,
                            successOverlayMessage: "Session created"
                        )
                    )
                )
                return .none
                
            case .sessionUpdated(let updatedSession):
                if let updatedActivity = updatedSession.managerData?.activities[id: state.activity.id] {
                    state.activity = updatedActivity
                    state.detail = updatedActivity.event
                }
                return .none
                
            case .retryButtonTap:
                return .none
                
            case .refresh:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ActivityDetail.Destination.State: Equatable, Sendable {}
