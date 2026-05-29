import ComposableArchitecture
import Foundation
import DesignSystem
import SwiftUI
import Domain
import Logger
import Utility

@Reducer
public struct ActivityList: Sendable {
    
    @Reducer
    public enum Destination {
        case activityDetail(ActivityDetail)
        case manageActivity(ManageActivity)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        
        @Presents public var destination: Destination.State?
        @Shared var bootstrap: Bootstrap
        var activities: [Activity] {
            guard let managerData = bootstrap.managerData else { return [] }
            return managerData.activities.elements
        }
        public init(
            destination: Destination.State? = nil,
            bootstrap: Shared<Bootstrap>,
        ) {
            self.destination = destination
            self._bootstrap = bootstrap
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case activityTap(Activity)
        case createActivityButtonTap
        case navigateToCreatedActivity(Activity)
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.continuousClock) var clock
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .createActivityButtonTap:
                state.destination = .manageActivity(.create())
                return .none

            case .destination(.presented(.manageActivity(.delegate(.dismissAndNavigateToDetail(let activity))))):
                state.destination = nil
                return .run { send in
                    try await clock.sleep(for: .seconds(0.5))
                    await send(.navigateToCreatedActivity(activity))
                }

            case .navigateToCreatedActivity(let activity):
                state.destination = .activityDetail(
                    ActivityDetail.State(
                        activityId: activity.id,
                        bootstrap: state.$bootstrap,
                        showCalendarSetup: true
                    )
                )
                return .none

            case .binding:
                return .none

            case .activityTap(let activity):
                guard let activity = state.bootstrap.managerData?.activities[id: activity.id] else { return .none }
                state.destination = .activityDetail(
                    ActivityDetail.State(
                        activityId: activity.id,
                        bootstrap: state.$bootstrap
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

extension ActivityList.Destination.State: Equatable, Sendable {}
