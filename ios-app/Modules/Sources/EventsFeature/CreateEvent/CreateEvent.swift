import ComposableArchitecture
import Domain
import DesignSystem
import Foundation
import Utility

@Reducer
public struct CreateEvent: Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        var createEventRequestInFlight = false
        var eventForm: EventForm.State
        @Presents var alert: AlertState<Never>?
        var showSuccessOverlay: Bool = false
        
        var createEventButtonDisabled: Bool {
            eventForm.eventInput.title.isEmpty || eventForm.eventInput.questions.isEmpty || createEventRequestInFlight || showSuccessOverlay
        }
		public init(eventForm: EventForm.State) {
            self.eventForm = eventForm
		}
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case createEventButtonTap
        case alert(PresentationAction<Never>)
        case createEventResponse(ManagerEvent)
        case presentError(Error)
        case delegate(Delegate)
        case eventForm(EventForm.Action)
        public enum Delegate: Equatable {
            case dismissAndNavigateToDetail(ManagerEvent)
        }
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.calendar) var calendar
    @Dependency(\.date) var date
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.continuousClock) var clock
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.eventForm, action: \.eventForm) {
            EventForm()
        }
        Reduce { state, action in
            switch action {
                
            case .eventForm:
                return .none
                
            case .createEventButtonTap:
                state.createEventRequestInFlight = true
                return .run { [state = state] send in
                    do {
                        let event = try await apiClient.createEvent(state.eventForm.eventInput)
                        await send(.createEventResponse(event))
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .alert:
                return .none
                
            case .binding:
                return .none
                
            case .createEventResponse(let event):
                state.createEventRequestInFlight = false
                state.showSuccessOverlay = true
                return .run { send in
                    try await clock.sleep(for: Constants.successOverlayDuration)
                    await send(.delegate(.dismissAndNavigateToDetail(event)))
                }
                
            case .presentError(let error):
                state.createEventRequestInFlight = false
                state.alert = .init(error: error)
                return .none
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
