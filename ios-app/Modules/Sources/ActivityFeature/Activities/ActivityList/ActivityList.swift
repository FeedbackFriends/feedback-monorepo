import ComposableArchitecture
import Foundation
import Domain

@Reducer
public struct ActivityList: Sendable {
    @Reducer
    public enum Destination {
        case alert(AlertState<AlertAction>)
        case manageActivity(ManageActivity)

        public enum AlertAction: Equatable, Sendable {
            case retryRefresh
        }
    }

    @Reducer
    public enum Path {
        case activityDetail(ActivityDetail)
        case eventDetail(EventDetailFeature)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        
        @Presents public var destination: Destination.State?
        public var path = StackState<Path.State>()
        @Shared var bootstrap: Bootstrap
        /// Fixed time for deterministic previews; live screens follow the current time.
        public var referenceDate: Date?
        var isRefreshing = false
        var activities: [Activity] {
            guard bootstrap.role == .manager else { return [] }
            return ActivityInsightData.sorted(bootstrap.unwrappedManagerSession.managerData.activities.elements)
        }
        public init(
            destination: Destination.State? = nil,
            bootstrap: Shared<Bootstrap>,
            referenceDate: Date? = nil
        ) {
            self.destination = destination
            self._bootstrap = bootstrap
            self.referenceDate = referenceDate
        }

        mutating func openActivity(_ activity: Activity, eventId: UUID? = nil) {
            let eventDetail = eventId.map {
                EventDetailFeature.State(activityId: activity.id, eventId: $0, bootstrap: $bootstrap)
            }
            if let eventDetail {
                path.append(.eventDetail(eventDetail))
            } else {
                path.append(.activityDetail(.init(activityId: activity.id, bootstrap: $bootstrap)))
            }
        }

    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case activityTap(Activity)
        case eventTap(activityId: UUID, eventId: UUID)
        case path(StackActionOf<Path>)
        case createActivityButtonTap
        case navigateToCreatedActivity(Activity)
        case refresh
        case refreshed(Bootstrap)
        case refreshFailed
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.continuousClock) var clock
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .createActivityButtonTap:
                guard state.bootstrap.role == .manager else { return .none }
                state.destination = .manageActivity(.create())
                return .none

            case .destination(.presented(.manageActivity(.delegate(.dismissAndNavigateToDetail(let activity))))):
                state.destination = nil
                return .run { send in
                    try await clock.sleep(for: .seconds(0.5))
                    await send(.navigateToCreatedActivity(activity))
                }

            case .navigateToCreatedActivity(let activity):
                guard state.bootstrap.role == .manager else { return .none }
                state.$bootstrap.withLock {
                    $0.managerData!.activities.updateOrAppend(activity)
                }
                state.openActivity(activity)
                return .none

            case .binding:
                return .none

            case .destination(.presented(.alert(.retryRefresh))):
                return .send(.refresh)

            case .eventTap(let activityId, let eventId):
                guard state.bootstrap.role == .manager,
                      let activity = state.bootstrap.managerData?.activities[id: activityId],
                      activity.events.contains(where: { $0.id == eventId }) else { return .none }
                state.openActivity(activity, eventId: eventId)
                return .none

            case .path(.element(let id, action: .eventDetail(.delegate(.editActivity)))):
                guard let eventDetail = state.path[id: id]?.eventDetail,
                      let activity = state.bootstrap.managerData?.activities[id: eventDetail.activityId] else { return .none }
                state.destination = .manageActivity(.edit(activity: activity))
                return .none

            case .activityTap(let activity):
                guard state.bootstrap.role == .manager else { return .none }
                guard let activity = state.bootstrap.managerData?.activities[id: activity.id] else { return .none }
                state.openActivity(activity)
                return .none
                
            case .refresh:
                guard state.bootstrap.role == .manager, !state.isRefreshing else { return .none }
                state.isRefreshing = true
                return .run { send in
                    do {
                        await send(.refreshed(try await apiClient.getBootstrap()))
                    } catch {
                        await send(.refreshFailed)
                    }
                }

            case .refreshed(let bootstrap):
                state.isRefreshing = false
                guard state.bootstrap.role == .manager else { return .none }
                state.$bootstrap.withLock { $0 = bootstrap }
                return .none

            case .refreshFailed:
                state.isRefreshing = false
                guard state.bootstrap.role == .manager else { return .none }
                state.destination = .alert(.refreshFailure)
                return .none

            case .destination, .path:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .forEach(\.path, action: \.path)
    }
}

extension ActivityList.Destination.State: Equatable, Sendable {}

extension ActivityList.Path.State: Equatable, Sendable {}

extension AlertState where Action == ActivityList.Destination.AlertAction {
    static var refreshFailure: Self {
        Self {
            TextState("Kunne ikke opdatere")
        } actions: {
            ButtonState(role: .cancel) { TextState("Annuller") }
            ButtonState(action: .retryRefresh) { TextState("Prøv igen") }
        } message: {
            TextState("Dine aktiviteter kunne ikke opdateres. Prøv igen.")
        }
    }
}
