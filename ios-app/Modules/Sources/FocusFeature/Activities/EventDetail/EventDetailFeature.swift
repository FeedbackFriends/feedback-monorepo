//import Domain
//import DesignSystem
//import Foundation
//import ComposableArchitecture
//import Utility
//
//@Reducer
//public struct EventDetailFeature: Sendable {
//    
//    @Reducer
//    public enum Destination {
////        case deleteConfirmation(DeleteConfirmation)
////        case editEvent(EditEvent)
//        @ReducerCaseEphemeral
//        case confirmationDialog(ConfirmationDialogState<ConfirmationDialog>)
//        @ReducerCaseIgnored
//        case invite(Event)
//        public enum ConfirmationDialog: Equatable, Sendable {
//            case edit
//            case delete
//            case invite
//        }
//    }
//    
//    @ObservableState
//    public struct State: Equatable, Sendable {
//        public let eventId: UUID
//        public var detail: Event?
//        @Presents var destination: Destination.State?
//        var fetchEventDetailInFlight = true
//        @Shared var session: Bootstrap
//        var webBaseUrl: URL?
//        var event: Event? {
//            let activity = session.managerData?.activities.first(where: { $0.id == eventId })
////            return activity.?.eve
//            fatalError()
//        }
//        var inviteUrl: String {
//            guard let webBaseUrl = webBaseUrl else { return "WEB_BASE_URL_NOT_FOUND" }
//            guard let pinCode = detail?.pinCode?.value else { return "PINCODE_NOT_FOUND" }
//            return AppWebURLProvider.invite(forPinCode: pinCode, baseUrl: webBaseUrl)?.absoluteString ?? "COULD_NOT_GENERATE_INVITE_LINK"
//        }
//        var navigationTitle: String {
////            activityDetail?.title ?? "Session"
//            fatalError()
//        }
//        var navigationSubTitle: String {
//            "\(detail?.overallFeedbackSummary?.responses ?? 0) responses"
//        }
//        var shareText: String {
//            fatalError()
////            guard let detail else {
////                return "Error"
////            }
////            return """
////            You’re invited to \(activityDetail?.title ?? "this session")!
////            Use pin code \(detail.pinCode?.value ?? "PINCODE_NOT_FOUND") to join.
////
////            👇🏼 Tap the link to join:
////            \(inviteUrl)
////            """
//        }
//        
//        public init(
//            eventId: UUID,
//            detail: Event? = nil,
//            destination: Destination.State? = nil,
//            fetchEventDetailInFlight: Bool = true,
//            session: Shared<Bootstrap>
//        ) {
//            self.eventId = eventId
//            self.detail = detail ?? session.wrappedValue.managerData?.activities[id: eventId]?.event
//            self.destination = destination
//            self.fetchEventDetailInFlight = fetchEventDetailInFlight
//            self._session = session
//        }
//    }
//    
//    public enum Action: BindableAction {
//        case binding(BindingAction<State>)
//        case destination(PresentationAction<Destination.Action>)
//        case moreButtonTapped
//        case onTask
//        case sessionUpdated(Bootstrap)
//    }
//    
//    public init() {}
//    
//    @Dependency(\.calendar) var calendar
//    @Dependency(\.dismiss) var dismiss
//    @Dependency(\.continuousClock) var clock
//    @Dependency(\.apiClient) var apiClient
//    @Dependency(\.systemClient) var systemClient
//    
//    public var body: some ReducerOf<Self> {
//        BindingReducer()
//        Reduce { state, action in
//            switch action {
//                
////            case .destination(.presented(.deleteConfirmation(.delegate(.dismissEventDetail)))):
////                return .run { _ in
////                    try await clock.sleep(for: .seconds(2.5))
////                    await dismiss()
////                }
//                
//            case .binding:
//                return .none
//                
//            case .destination(.presented(.confirmationDialog(let confirmationDialogAction))):
////                switch confirmationDialogAction {
////                    
////                case .edit:
////                    guard let activity = state.activityDetail else { return .none }
////                    let recentlyUsedQuestions = if let managerData = state.session.managerData {
////                        Set<RecentlyUsedQuestions>(managerData.recentlyUsedQuestions)
////                    } else {
////                        Set<RecentlyUsedQuestions>()
////                    }
////                    state.destination = .editEvent(
////                        EditEvent.State(
////                            eventForm: EventForm.State.init(
////                                eventInput: EventInput(activity),
////                                shouldOpenKeyboardOnAppear: false,
////                                recentlyUsedQuestions: recentlyUsedQuestions,
////                                successOverlayMessage: "Session edited"
////                            ),
////                            eventId: state.eventId,
////                            recentlyUsedQuestions: recentlyUsedQuestions
////                        )
////                    )
////                case .delete:
////                    state.destination = .deleteConfirmation(.init(eventId: state.eventId))
////                case .invite:
////                    guard let detail = state.detail else { return .none }
////                    state.destination = .invite(detail)
////                }
//                return .none
//                
//            case .destination:
//                return .none
//                
//            case .moreButtonTapped:
//                guard let detail = state.detail else { return .none }
////                state.destination = .confirmationDialog(
////                    ConfirmationDialogState<Destination.ConfirmationDialog>.init(
////                        titleVisibility: .hidden,
////                        title: { TextState("") },
////                        actions: {
////                            if detail.overallFeedbackSummary == nil && detail.pinCode != nil {
////                                ButtonState(action: .send(.edit)) {
////                                    TextState("Edit ✏️")
////                                }
////                            }
////                            if detail.pinCode != nil {
////                                ButtonState(action: .send(.invite)) {
////                                    TextState("Invite 👥")
////                                }
////                            }
////                            ButtonState(role: .destructive, action: .send(.delete)) {
////                                TextState("Delete 🗑️")
////                            }
////                            ButtonState(role: .cancel) {
////                                TextState("Cancel")
////                            }
////                        }
////                    )
////                )
//                return .none
//                
//            case .onTask:
//                state.webBaseUrl = self.systemClient.webBaseUrl()
//                return .publisher {
//                    state.$session.publisher
//                        .map(Action.sessionUpdated)
//                }
//                
//            case .sessionUpdated(let updatedSession):
////                if let updatedDetail = updatedSession.managerData?.activities[id: state.eventId]?.event {
////                    state.detail = updatedDetail
////                }
//                return .none
//            }
//        }
//        .ifLet(\.$destination, action: \.destination)
//    }
//}
//
//extension EventDetailFeature.Destination.State: Equatable, Sendable {}
