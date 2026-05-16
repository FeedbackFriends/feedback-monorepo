import ComposableArchitecture
import Domain
import Utility
import FeedbackFlowFeature
import Foundation

@Reducer
public struct EventForm: Sendable {
    
    public enum FocusedField: Sendable, Equatable {
        case title
        case description
    }
    
    public enum DurationPicker: Equatable, Hashable, Sendable {
        
        public init(durationInMinutes: Int) {
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
        
        public var localization: String {
            switch self {
            case .minutes15:
                "15 minutter"
            case .minutes30:
                "30 minutter"
            case .minutes45:
                "45 minutter"
            case .minutes60:
                "1 time"
            case .minutes90:
                "1,5 timer"
            case .minutes120:
                "2 timer"
            case .other:
                "Andet"
            }
        }
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        var eventInput: EventInput
        var startNowEnabled: Bool
        var durationPicker: EventForm.DurationPicker
        var allDay: Bool
        var minutePicker: Int
        var hourPicker: Int
        var focus: FocusedField?
        
        let shouldOpenKeyboardOnAppear: Bool
        let recentlyUsedQuestions: Set<RecentlyUsedQuestions>
        let successOverlayMessage: String
        
        let initialFocus: FocusedField?
        
        @Presents var feedbackFlowCoordinator: FeedbackFlowCoordinator.State?
        
        var date: Date {
            @Dependency(\.date) var date
            return date.now
        }
        
        public init(
            initialFocus: FocusedField? = nil,
            eventInput: EventInput,
            startNowEnabled: Bool = false,
            focus: FocusedField? = nil,
            shouldOpenKeyboardOnAppear: Bool,
            recentlyUsedQuestions: Set<RecentlyUsedQuestions>,
            successOverlayMessage: String,
        ) {
            self.initialFocus = initialFocus
            self.eventInput = eventInput
            self.startNowEnabled = startNowEnabled
            self.durationPicker = DurationPicker(durationInMinutes: eventInput.durationInMinutes)
            self.allDay = eventInput.durationInMinutes == .minutesOneDay ? true : false
            self.minutePicker = eventInput.durationInMinutes % 60
            self.hourPicker = eventInput.durationInMinutes / 60
            self.focus = focus
            self.shouldOpenKeyboardOnAppear = shouldOpenKeyboardOnAppear
            self.recentlyUsedQuestions = recentlyUsedQuestions
            self.successOverlayMessage = successOverlayMessage
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onSubmitTitleTextField
        case minutePickerChanged
        case hourPickerChanged
        case allDayChanged
        case closeButtonTap
        case durationPickerChanged(DurationPicker)
        case presentFeedbackFlowSession(FeedbackFlowCoordinator.State)
        case feedbackFlowCoordinator(PresentationAction<FeedbackFlowCoordinator.Action>)
        case onAppear
    }
    
    @Dependency(\.dismiss) var dismiss
    
    private func calculateMinutes(hours: Int, minutes: Int) -> Int {
        return (hours * 60) + minutes
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                if let initialFocus = state.initialFocus {
                    state.focus = initialFocus
                }
                return .none
            case .presentFeedbackFlowSession(let feedbackFlowSession):
                state.feedbackFlowCoordinator = feedbackFlowSession
                return .none
            case .binding:
                return .none
            case .onSubmitTitleTextField:
                state.focus = .description
                return .none
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
            case .feedbackFlowCoordinator:
                return .none
            }
        }
        .ifLet(\.$feedbackFlowCoordinator, action: \.feedbackFlowCoordinator) {
            FeedbackFlowCoordinator()
                .transformDependency(\.apiClient) { apiClient in
                    apiClient.submitFeedback = { _, _ in false }
                    return ()
                }
        }
    }
}
