import ComposableArchitecture
import Domain
import Foundation
import Utility
import DesignSystem

@Reducer
public struct ManageEvent: Sendable {

    @Reducer
    public enum Destination {
        case alert(AlertState<Never>)
        @ReducerCaseIgnored
        case eventDetail(Event)
    }

    public enum Mode: Equatable, Sendable {
        case create
        case edit
    }

    @ObservableState
    public struct State: Equatable, Sendable {
        let mode: Mode
        let activityId: UUID
        let eventId: UUID?
        var manageEventInFlight = false
        var eventForm: EventForm.State
        @Presents var destination: Destination.State?
        var showSuccessOverlay = false

        var manageEventButtonDisabled: Bool {
            eventForm.eventInput.title.isEmpty
                || eventForm.eventInput.questions.isEmpty
                || manageEventInFlight
                || showSuccessOverlay
        }

        var navigationTitle: String {
            switch mode {
            case .create:
                "New session"
            case .edit:
                "Edit session"
            }
        }

        var actionButtonTitle: String {
            "Save"
        }

        public init(
            activity: Activity,
            recentlyUsedQuestions: Set<RecentlyUsedQuestions> = []
        ) {
            self.mode = .create
            self.activityId = activity.id
            self.eventId = nil

            var eventInput = EventInput(activity)
            eventInput.date = Date().roundedUpcoming5Min()

            self.eventForm = .init(
                eventInput: eventInput,
                shouldOpenKeyboardOnAppear: false,
                recentlyUsedQuestions: recentlyUsedQuestions,
                successOverlayMessage: "Session created"
            )
        }

        public init(
            activity: Activity,
            event: Event,
            recentlyUsedQuestions: Set<RecentlyUsedQuestions> = []
        ) {
            self.mode = .edit
            self.activityId = activity.id
            self.eventId = event.id

            var eventInput = EventInput(activity)
            eventInput.date = event.date
            eventInput.durationInMinutes = event.durationInMinutes
            eventInput.location = event.location

            self.eventForm = .init(
                eventInput: eventInput,
                shouldOpenKeyboardOnAppear: false,
                recentlyUsedQuestions: recentlyUsedQuestions,
                successOverlayMessage: "Session saved"
            )
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case actionButtonTap
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<Never>)
        case manageEventResponse(Event)
        case presentError(Error)
        case delegate(Delegate)
        case eventForm(EventForm.Action)

        public enum Delegate: Equatable {
            case dismissAndNavigateToEvent(Event)
            case dismiss
        }
    }

    public init() {}

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.continuousClock) var clock

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.eventForm, action: \.eventForm) {
            EventForm()
        }
        Reduce { state, action in
            switch action {
            case .binding, .eventForm, .destination, .alert, .delegate:
                return .none

            case .actionButtonTap:
                state.manageEventInFlight = true
                let eventInput = state.eventForm.eventInput
                let sessionInput = SessionInput(
                    activityId: state.activityId,
                    date: eventInput.date,
                    durationInMinutes: eventInput.durationInMinutes,
                    location: eventInput.location
                )

                switch state.mode {
                case .create:
                    return .run { send in
                        do {
                            let event = try await apiClient.createEvent(sessionInput)
                            await send(.manageEventResponse(event))
                        } catch {
                            await send(.presentError(error))
                        }
                    }

                case .edit:
                    guard let eventId = state.eventId else {
                        state.manageEventInFlight = false
                        state.destination = .alert(.init(error: MissingEventIdentifierError()))
                        return .none
                    }

                    return .run { send in
                        do {
                            let event = try await apiClient.updateEvent(sessionInput, eventId)
                            await send(.manageEventResponse(event))
                        } catch {
                            await send(.presentError(error))
                        }
                    }
                }

            case .manageEventResponse(let event):
                state.manageEventInFlight = false
                state.showSuccessOverlay = true
                return .run { [mode = state.mode] send in
                    try await clock.sleep(for: Constants.successOverlayDuration)
                    switch mode {
                    case .create:
                        await send(.delegate(.dismissAndNavigateToEvent(event)))
                    case .edit:
                        await send(.delegate(.dismiss))
                    }
                }

            case .presentError(let error):
                state.manageEventInFlight = false
                state.destination = .alert(.init(error: error))
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

private struct MissingEventIdentifierError: LocalizedError {
    var errorDescription: String? {
        "Missing event identifier."
    }
}

extension ManageEvent.Destination.State: Equatable, Sendable {}
