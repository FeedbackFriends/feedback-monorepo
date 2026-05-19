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
        case createActivity(CreateActivity)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        
        @Presents public var destination: Destination.State?
        @Shared var session: Bootstrap
        var activities: [Activity] {
            guard let managerData = session.managerData else { return [] }
            return managerData.activities.elements
        }
        public init(
            destination: Destination.State? = nil,
            session: Shared<Bootstrap>,
        ) {
            self.destination = destination
            self._session = session
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case activityTap(Event)
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
                state.destination = .createActivity(.init())
                return .none

            case .destination(.presented(.createActivity(.delegate(.dismissAndNavigateToDetail(let activity))))):
                state.destination = nil
                return .run { send in
                    try await clock.sleep(for: .seconds(0.5))
                    await send(.navigateToCreatedActivity(activity))
                }

            case .navigateToCreatedActivity(let activity):
                state.destination = .activityDetail(
                    ActivityDetail.State(
                        eventId: activity.id,
                        detail: activity.event,
                        session: state.$session
                    )
                )
                return .none
                
            case .destination(.dismiss):
                if case .activityDetail(let activityDetailState) = state.destination,
                   let overallFeedbackSummary = activityDetailState.detail?.overallFeedbackSummary,
                   overallFeedbackSummary.unseenResponses > 0 {
                    return .run { _ in
                        do {
                            try await self.apiClient.markEventAsSeen(activityDetailState.eventId)
                        } catch {
                            Logger.debug("Mark session as seen failed: \(error.localizedDescription)")
                        }
                    }
                    
                }
                return .none
                
            case .binding:
                return .none
                
            case .activityTap(let event):
                state.destination = .activityDetail(
                    ActivityDetail.State(
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
    }
}

extension ActivityList.Destination.State: Equatable, Sendable {}
