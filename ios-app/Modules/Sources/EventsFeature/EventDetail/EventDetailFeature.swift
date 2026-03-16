import Domain
import DesignSystem
import Foundation
import ComposableArchitecture
import UIKit
import Utility

@Reducer
public struct EventDetailFeature: Sendable {
    
    @Reducer
    public enum Destination {
        case deleteConfirmation(DeleteConfirmation)
        case editQuestions(EditQuestions)
        @ReducerCaseEphemeral
        case confirmationDialog(ConfirmationDialogState<ConfirmationDialog>)
        @ReducerCaseIgnored
        case invite(ManagerEvent)
        public enum ConfirmationDialog: Equatable, Sendable {
            case editQuestions
            case delete
            case invite
        }
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        public var event: ManagerEvent
        @Presents var destination: Destination.State?
        var fetchEventDetailInFlight = true
        var webBaseUrl: URL?
        var inviteUrl: String {
            guard let pinCode = event.pinCode?.value else { return "PINCODE_NOT_FOUND" }
            guard let webBaseUrl = webBaseUrl else { return "WEB_BASE_URL_NOT_FOUND" }
            return AppWebURLProvider.invite(forPinCode: pinCode, baseUrl: webBaseUrl)?.absoluteString ?? "COULD_NOT_GENERATE_INVITE_LINK"
        }
        var navigationTitle: String {
            event.title
        }
        var navigationSubTitle: String {
            "\(event.overallFeedbackSummary?.responses ?? 0) responses"
        }
        var shareText: String {
        """
        You’re invited to \(event.title)!   
        Use pin code \(event.pinCode?.value ?? "PINCODE_NOT_FOUND") to join.
        
        👇🏼 Tap the link to join:  
        \(inviteUrl)
        """
        }
        @Shared var session: Session
        
        public init(
            event: ManagerEvent,
            destination: Destination.State? = nil,
            fetchEventDetailInFlight: Bool = true,
            session: Shared<Session>
        ) {
            self.event = event
            self.destination = destination
            self.fetchEventDetailInFlight = fetchEventDetailInFlight
            self._session = session
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case moreButtonTapped
        case onTask
        case retryButtonTap
        case refresh
        case sessionUpdated(Session)
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
                
            case .destination(.presented(.deleteConfirmation(.delegate(.dismissEventDetail)))):
                return .run { _ in
                    try await clock.sleep(for: .seconds(2.5))
                    await dismiss()
                }
                
            case .binding:
                return .none
                
            case .destination(.presented(.confirmationDialog(let confirmationDialogAction))):
                switch confirmationDialogAction {
                    
                case .editQuestions:
                    let recentlyUsedQuestions = if let managerData = state.session.managerData {
                        Set<RecentlyUsedQuestions>(managerData.recentlyUsedQuestions)
                    } else {
                        Set<RecentlyUsedQuestions>()
                    }
                    state.destination = .editQuestions(
                        EditQuestions.State(
                            event: state.event,
                            recentlyUsedQuestions: recentlyUsedQuestions
                        )
                    )
                case .delete:
                    state.destination = .deleteConfirmation(.init(eventId: state.event.id))
                case .invite:
                    state.destination = .invite(state.event)
                }
                return .none
                
            case .destination:
                return .none
                
            case .moreButtonTapped:
                state.destination = .confirmationDialog(
                    ConfirmationDialogState<Destination.ConfirmationDialog>.init(
                        titleVisibility: .hidden,
                        title: { TextState("") },
                        actions: {
                            if state.event.overallFeedbackSummary == nil {
                                ButtonState(action: .send(.editQuestions)) {
                                    TextState("Edit questions ✏️")
                                }
                            }
                            if state.event.pinCode != nil {
                                ButtonState(action: .send(.invite)) {
                                    TextState("Invite 👥")
                                }
                            }
                            ButtonState(role: .destructive, action: .send(.delete)) {
                                TextState("Delete 🗑️")
                            }
                            ButtonState(role: .cancel) {
                                TextState("Cancel")
                            }
                        }
                    )
                )
                return .none
                
            case .onTask:
                state.webBaseUrl = self.systemClient.webBaseUrl()
                return .publisher {
                    state.$session.publisher
                        .map(Action.sessionUpdated)
                }
                
            case .sessionUpdated(let updatedSession):
                guard
                    let managerData = updatedSession.managerData,
                    let event = managerData.managerEvents[id: state.event.id]
                else {
                    return .none
                }
                state.event = event
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

extension EventDetailFeature.Destination.State: Equatable, Sendable {}
