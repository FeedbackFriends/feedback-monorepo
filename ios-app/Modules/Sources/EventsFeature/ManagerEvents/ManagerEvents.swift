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
        case editQuestions(EditQuestions)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        
        @Presents public var destination: Destination.State?
        @Shared var session: Session
        @Shared var syncStatus: SyncStatus
        public init(
            destination: Destination.State? = nil,
            session: Shared<Session>,
            syncStatus: Shared<SyncStatus> = Shared(value: SyncStatus())
        ) {
            self.destination = destination
            self._session = session
            self._syncStatus = syncStatus
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case managerEventTap(ManagerEvent)
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
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
                let hasResponses = (event.overallFeedbackSummary?.responses ?? 0) > 0
                if !hasResponses, event.questions.isEmpty {
                    let recentlyUsedQuestions = if let managerData = state.session.managerData {
                        Set<RecentlyUsedQuestions>(managerData.recentlyUsedQuestions)
                    } else {
                        Set<RecentlyUsedQuestions>()
                    }
                    state.destination = .editQuestions(
                        EditQuestions.State(
                            event: event,
                            recentlyUsedQuestions: recentlyUsedQuestions
                        )
                    )
                } else {
                    state.destination = .eventDetail(
                        EventDetailFeature.State(
                            event: event,
                            session: state.$session
                        )
                    )
                }
                return .none
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ManagerEvents.Destination.State: Equatable, Sendable {}
