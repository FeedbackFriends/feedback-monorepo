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
        @Shared var bootstrap: Bootstrap
        var webBaseUrl: URL?
        var hasMarkedAsSeen: Bool
        var showDeleteConfirmation = false
        var deleteEventInFlight = false
        var wasDeleted = false
        var confirmation = SuccessConfirmation.State()
        var inviteAfterConfirmation = false

        var activity: Activity? {
            bootstrap.managerData?.activities.first { $0.id == activityId }
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
            let responses = event?.overallFeedbackSummary?.responses ?? 0
            return responses == 1 ? "1 svar" : "\(responses) svar"
        }

        var shareText: String? {
            guard let event, let pinCode = event.pinCode?.value, let inviteUrl else {
                return nil
            }

            return """
            Du er inviteret til at give feedback på \(navigationTitle).
            Brug PIN-kode \(pinCode) for at svare.

            Åbn linket for at svare:
            \(inviteUrl)
            """
        }

        public init(
            activityId: UUID,
            eventId: UUID,
            destination: Destination.State? = nil,
            bootstrap: Shared<Bootstrap>,
            webBaseUrl: URL? = nil,
            hasMarkedAsSeen: Bool = false
        ) {
            self.activityId = activityId
            self.eventId = eventId
            self.destination = destination
            self._bootstrap = bootstrap
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
        case deleteConfirmationDismissed
        case confirmation(SuccessConfirmation.Action)
        case presentError(Error)
        case delegate(Delegate)

        public enum Delegate: Equatable, Sendable {
            case editActivity
            case eventDeleted
        }
    }

    public init() {}

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.systemClient) var systemClient

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.confirmation, action: \.confirmation) { SuccessConfirmation() }
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .destination(.presented(.manageEvent(.delegate(let delegate)))):
                switch delegate {
                case .dismissAndUpdateEvent, .dismissAndNavigateToEvent:
                    state.destination = nil
                    state.confirmation.queue("Session gemt")
                    return .none

                case .editActivity:
                    state.destination = nil
                    return .send(.delegate(.editActivity))

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
                guard state.event != nil, !state.deleteEventInFlight, !state.wasDeleted else { return .none }
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
                let hadConfirmation = state.showDeleteConfirmation
                state.showDeleteConfirmation = false
                state.wasDeleted = true
                return hadConfirmation ? .none : .send(.delegate(.eventDeleted))

            case .deleteConfirmationDismissed:
                guard state.wasDeleted else { return .none }
                return .send(.delegate(.eventDeleted))

            case .confirmation(.dismiss):
                if state.inviteAfterConfirmation, let event = state.event {
                    state.inviteAfterConfirmation = false
                    state.destination = .invite(event)
                }
                return .none

            case .confirmation:
                return .none

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

            case .delegate:
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
