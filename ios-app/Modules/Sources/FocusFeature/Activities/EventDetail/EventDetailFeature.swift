import ComposableArchitecture
import DesignSystem
import Domain
import Foundation
import Utility

@Reducer
public struct EventDetailFeature: Sendable {
    @Reducer
    public enum Destination {
        @ReducerCaseIgnored
        case invite(Event)
        case manageEvent(ManageEvent)
    }

    @ObservableState
    public struct State: Equatable, Sendable {
        public let activityId: UUID
        public let eventId: UUID
        @Presents var alert: AlertState<Never>?
        @Presents var destination: Destination.State?
        @Shared var session: Bootstrap
        var webBaseUrl: URL?
        var hasMarkedAsSeen: Bool
        var showDeleteConfirmation = false
        var deleteEventInFlight = false

        var activity: Activity? {
            session.managerData?.activities.first { $0.id == activityId }
        }

        var event: Event? {
            activity?.events.first { $0.id == eventId }
        }

        var inviteUrl: String? {
            guard
                let webBaseUrl,
                let pinCode = event?.pinCode?.value,
                let url = AppWebURLProvider.invite(forPinCode: pinCode, baseUrl: webBaseUrl)
            else {
                return nil
            }

            return url.absoluteString
        }

        var navigationTitle: String {
            activity?.title ?? "Session"
        }

        var navigationSubTitle: String {
            "\(event?.overallFeedbackSummary?.responses ?? 0) responses"
        }

        var shareText: String? {
            guard let event, let pinCode = event.pinCode?.value, let inviteUrl else {
                return nil
            }

            return """
            You are invited to \(navigationTitle)!
            Use pin code \(pinCode) to join.

            Tap the link to join:
            \(inviteUrl)
            """
        }

        public init(
            activityId: UUID,
            eventId: UUID,
            destination: Destination.State? = nil,
            session: Shared<Bootstrap>,
            webBaseUrl: URL? = nil,
            hasMarkedAsSeen: Bool = false
        ) {
            self.activityId = activityId
            self.eventId = eventId
            self.destination = destination
            self._session = session
            self.webBaseUrl = webBaseUrl
            self.hasMarkedAsSeen = hasMarkedAsSeen
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<Never>)
        case deleteEventButtonTapped
        case deleteEventCancelButtonTapped
        case deleteEventConfirmButtonTapped
        case deleteEventSuccess
        case editButtonTapped
        case inviteButtonTapped
        case onTask
        case presentError(Error)
    }

    public init() {}

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.systemClient) var systemClient

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .destination(.presented(.manageEvent(.delegate(let delegate)))):
                switch delegate {
                case .dismissAndUpdateEvent(let event), .dismissAndNavigateToEvent(let event):
                    state.destination = nil
                    return .none

                case .dismiss:
                    state.destination = nil
                    return .none
                }

            case .destination:
                return .none

            case .alert:
                return .none

            case .deleteEventButtonTapped:
                state.showDeleteConfirmation = true
                return .none

            case .deleteEventCancelButtonTapped:
                state.showDeleteConfirmation = false
                return .none

            case .deleteEventConfirmButtonTapped:
                guard state.event != nil else { return .none }
                state.deleteEventInFlight = true
                let eventId = state.eventId
                return .run { send in
                    do {
                        try await apiClient.deleteEvent(eventId)
                        await send(.deleteEventSuccess)
                    } catch {
                        await send(.presentError(error))
                    }
                }

            case .deleteEventSuccess:
                state.deleteEventInFlight = false
                state.showDeleteConfirmation = false
                return .run { _ in
                    await dismiss()
                }

            case .editButtonTapped:
                guard let activity = state.activity, let event = state.event else { return .none }
                state.destination = .manageEvent(.edit(activity: activity, event: event))
                return .none

            case .inviteButtonTapped:
                guard let event = state.event else { return .none }
                guard state.inviteUrl != nil, state.shareText != nil else {
                    state.alert = .init(error: MissingInviteLinkError())
                    return .none
                }
                state.destination = .invite(event)
                return .none

            case .onTask:
                state.webBaseUrl = systemClient.webBaseUrl()
                guard !state.hasMarkedAsSeen, state.event != nil else {
                    return .none
                }
                state.hasMarkedAsSeen = true
                let eventId = state.eventId
                return .run { send in
                    do {
                        try await apiClient.markEventAsSeen(eventId)
                    } catch {
                        await send(.presentError(error))
                    }
                }

            case .presentError(let error):
                state.deleteEventInFlight = false
                state.alert = .init(error: error)
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }
}

extension EventDetailFeature.Destination.State: Equatable, Sendable {}

private struct MissingInviteLinkError: LocalizedError {
    var errorDescription: String? {
        "Could not create invite link."
    }
}
