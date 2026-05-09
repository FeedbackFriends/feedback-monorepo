import Domain
import DesignSystem
import Foundation
import ComposableArchitecture
import Utility

@Reducer
public struct EventDetailFeature: Sendable {
    
    @Reducer
    public enum Destination {
        case deleteConfirmation(DeleteConfirmation)
        case editEvent(EditEvent)
        @ReducerCaseEphemeral
        case confirmationDialog(ConfirmationDialogState<ConfirmationDialog>)
        @ReducerCaseIgnored
        case invite(Activity)
        public enum ConfirmationDialog: Equatable, Sendable {
            case edit
            case delete
            case invite
        }
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        public let eventId: UUID
        public var detail: Activity?
        @Presents var destination: Destination.State?
        var fetchEventDetailInFlight = true
        var webBaseUrl: URL?
        var inviteUrl: String {
            guard let webBaseUrl = webBaseUrl else { return "WEB_BASE_URL_NOT_FOUND" }
            return detail?.inviteUrl(webBaseUrl: webBaseUrl) ?? "PINCODE_NOT_FOUND"
        }
        var navigationTitle: String {
            detail?.title ?? "Session"
        }
        var navigationSubTitle: String {
            "\(detail?.overallFeedbackSummary?.responses ?? 0) responses"
        }
        var shareText: String {
            guard let webBaseUrl, let detail else {
                return """
                You’re invited to \(detail?.title ?? "this session")!
                Use pin code \(detail?.pinCode?.value ?? "PINCODE_NOT_FOUND") to join.

                👇🏼 Tap the link to join:
                \(inviteUrl)
                """
            }
            return detail.shareText(webBaseUrl: webBaseUrl)
        }
        @Shared var session: Bootstrap
        
        public init(
            eventId: UUID,
            detail: Activity? = nil,
            destination: Destination.State? = nil,
            fetchEventDetailInFlight: Bool = true,
            session: Shared<Bootstrap>
        ) {
            self.eventId = eventId
            self.detail = detail ?? session.wrappedValue.managerData?.activities[id: eventId]
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
        case sessionUpdated(Bootstrap)
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
                    
                case .edit:
                    guard let detail = state.detail else { return .none }
                    let recentlyUsedQuestions = if let managerData = state.session.managerData {
                        Set<RecentlyUsedQuestions>(managerData.recentlyUsedQuestions)
                    } else {
                        Set<RecentlyUsedQuestions>()
                    }
                    state.destination = .editEvent(
                        EditEvent.State(
                            eventForm: EventForm.State.init(
                                eventInput: EventInput(detail),
                                shouldOpenKeyboardOnAppear: false,
                                recentlyUsedQuestions: recentlyUsedQuestions,
                                successOverlayMessage: "Session edited"
                            ),
                            eventId: state.eventId,
                            recentlyUsedQuestions: recentlyUsedQuestions
                        )
                    )
                case .delete:
                    state.destination = .deleteConfirmation(.init(eventId: state.eventId))
                case .invite:
                    guard let detail = state.detail else { return .none }
                    state.destination = .invite(detail)
                }
                return .none
                
            case .destination:
                return .none
                
            case .moreButtonTapped:
                guard let detail = state.detail else { return .none }
                state.destination = .confirmationDialog(
                    ConfirmationDialogState<Destination.ConfirmationDialog>.init(
                        titleVisibility: .hidden,
                        title: { TextState("") },
                        actions: {
                            if detail.overallFeedbackSummary == nil && detail.pinCode != nil {
                                ButtonState(action: .send(.edit)) {
                                    TextState("Edit ✏️")
                                }
                            }
                            if detail.pinCode != nil {
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
                state.detail = updatedSession.managerData?.activities[id: state.eventId]
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
