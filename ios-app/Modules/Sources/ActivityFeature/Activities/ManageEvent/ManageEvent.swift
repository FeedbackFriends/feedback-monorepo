import ComposableArchitecture
import Domain
import Foundation
import Utility
import DesignSystem

@Reducer
public struct ManageEvent: Sendable {
    public enum Mode: Equatable, Sendable {
        case create
        case edit
    }

    @ObservableState
    public struct State: Equatable, Sendable {
        public enum DurationPicker: Equatable, Hashable, Sendable {
            init(durationInMinutes: Int) {
                switch durationInMinutes {
                case 15: self = .minutes15
                case 30: self = .minutes30
                case 45: self = .minutes45
                case 60: self = .minutes60
                case 90: self = .minutes90
                case 120: self = .minutes120
                default: self = .other
                }
            }

            case minutes15, minutes30, minutes45, minutes60, minutes90, minutes120, other

            var localization: String {
                switch self {
                case .minutes15:
                    "15 min"
                case .minutes30:
                    "30 min"
                case .minutes45:
                    "45 min"
                case .minutes60:
                    "1 time"
                case .minutes90:
                    "1,5 time"
                case .minutes120:
                    "2 timer"
                case .other:
                    "Anden"
                }
            }
        }

        let mode: Mode
        let activityId: UUID
        let eventId: UUID?
        var manageEventInFlight = false
        var eventInput: EventInput
        var startNowEnabled = false
        var durationPicker: DurationPicker
        var allDay: Bool
        var minutePicker: Int
        var hourPicker: Int
        let successOverlayMessage: String
        @Presents var alert: AlertState<Never>?
        var showSuccessOverlay = false

        var manageEventButtonDisabled: Bool {
            manageEventInFlight
                || showSuccessOverlay
        }

        public static func create(
            activity: Activity
        ) -> Self {
            var eventInput = EventInput(activity)
            eventInput.date = Date().roundedUpcoming5Min()

            return Self(
                mode: .create,
                activityId: activity.id,
                eventId: nil,
                eventInput: eventInput,
                successOverlayMessage: "Session oprettet"
            )
        }

        public static func edit(
            activity: Activity,
            event: Event
        ) -> Self {
            var eventInput = EventInput(activity)
            eventInput.date = event.date
            eventInput.durationInMinutes = event.durationInMinutes
            eventInput.location = event.location

            return Self(
                mode: .edit,
                activityId: activity.id,
                eventId: event.id,
                eventInput: eventInput,
                successOverlayMessage: "Session gemt"
            )
        }

        init(
            mode: Mode,
            activityId: UUID,
            eventId: UUID?,
            eventInput: EventInput,
            successOverlayMessage: String,
            startNowEnabled: Bool = false
        ) {
            self.mode = mode
            self.activityId = activityId
            self.eventId = eventId
            self.eventInput = eventInput
            self.startNowEnabled = startNowEnabled
            self.durationPicker = DurationPicker(durationInMinutes: eventInput.durationInMinutes)
            self.allDay = eventInput.durationInMinutes == .minutesOneDay
            self.minutePicker = eventInput.durationInMinutes % 60
            self.hourPicker = eventInput.durationInMinutes / 60
            self.successOverlayMessage = successOverlayMessage
        }

        var date: Date {
            @Dependency(\.date) var date
            return date.now
        }

        var navigationTitle: String {
            switch mode {
            case .create:
                "Ny session"
            case .edit:
                "Rediger session"
            }
        }

        var actionButtonTitle: String {
            "Gem"
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case minutePickerChanged
        case hourPickerChanged
        case allDayChanged
        case closeButtonTap
        case durationPickerChanged(State.DurationPicker)
        case editActivityButtonTap
        case actionButtonTap
        case manageEventResponse(Event)
        case presentError(Error)
        case alert(PresentationAction<Never>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case dismissAndNavigateToEvent(Event)
            case dismissAndUpdateEvent(Event)
            case editActivity
            case dismiss
        }
    }

    public init() {}

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.continuousClock) var clock

    private func calculateMinutes(hours: Int, minutes: Int) -> Int {
        (hours * 60) + minutes
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {

            case .binding:
                return .none

            case .minutePickerChanged:
                state.eventInput.durationInMinutes = calculateMinutes(
                    hours: state.hourPicker,
                    minutes: state.minutePicker
                )
                return .none

            case .hourPickerChanged:
                state.eventInput.durationInMinutes = calculateMinutes(
                    hours: state.hourPicker,
                    minutes: state.minutePicker
                )
                return .none

            case .allDayChanged:
                state.eventInput.durationInMinutes = .minutesOneDay
                return .none

            case .closeButtonTap:
                return .run { _ in
                    await self.dismiss()
                }

            case .durationPickerChanged(let newValue):
                state.eventInput.durationInMinutes = switch newValue {
                case .minutes15: 15
                case .minutes30: 30
                case .minutes45: 45
                case .minutes60: 60
                case .minutes90: 90
                case .minutes120: 120
                case .other: calculateMinutes(
                    hours: state.hourPicker,
                    minutes: state.minutePicker
                )
                }
                return .none

            case .editActivityButtonTap:
                return .send(.delegate(.editActivity))

            case .actionButtonTap:
                state.manageEventInFlight = true
                let eventInput = state.eventInput
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
                        state.alert = .init(error: MissingEventIdentifierError())
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
                        await send(.delegate(.dismissAndUpdateEvent(event)))
                    }
                }

            case .presentError(let error):
                state.manageEventInFlight = false
                state.alert = .init(error: error)
                return .none

            case .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

private struct MissingEventIdentifierError: LocalizedError {
    var errorDescription: String? {
        "Missing event identifier."
    }
}
