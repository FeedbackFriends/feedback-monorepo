import ComposableArchitecture
import Domain

@Reducer
public struct EditQuestions: Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        public var event: ManagerEvent
        public var questionsInputs: [EventInput.QuestionInput]
        public var recentlyUsedQuestions: Set<RecentlyUsedQuestions>
        public var saveRequestInFlight = false
        public var showSuccessOverlay = false
        @Presents var alert: AlertState<Never>?

        var saveButtonDisabled: Bool {
            questionsInputs.isEmpty || saveRequestInFlight || showSuccessOverlay
        }

        public init(
            event: ManagerEvent,
            recentlyUsedQuestions: Set<RecentlyUsedQuestions>
        ) {
            self.event = event
            self.questionsInputs = event.questions.map {
                EventInput.QuestionInput(
                    id: $0.id,
                    questionText: $0.questionText,
                    feedbackType: $0.feedbackType
                )
            }
            self.recentlyUsedQuestions = recentlyUsedQuestions
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case closeButtonTap
        case saveButtonTap
        case saveResponse(ManagerEvent)
        case presentError(Error)
        case alert(PresentationAction<Never>)
    }

    public init() {}

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.dismiss) var dismiss

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .closeButtonTap:
                return .run { _ in
                    await dismiss()
                }

            case .saveButtonTap:
                state.saveRequestInFlight = true
                return .run { [state = state] send in
                    do {
                        var input = EventInput(state.event)
                        input.questions = state.questionsInputs
                        let updated = try await apiClient.updateEvent(input, state.event.id)
                        await send(.saveResponse(updated))
                    } catch {
                        await send(.presentError(error))
                    }
                }

            case .saveResponse(let event):
                state.saveRequestInFlight = false
                state.event = event
                state.questionsInputs = event.questions.map {
                    EventInput.QuestionInput(
                        id: $0.id,
                        questionText: $0.questionText,
                        feedbackType: $0.feedbackType
                    )
                }
                state.showSuccessOverlay = true
                return .none

            case .presentError(let error):
                state.saveRequestInFlight = false
                state.alert = .init(error: error)
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
