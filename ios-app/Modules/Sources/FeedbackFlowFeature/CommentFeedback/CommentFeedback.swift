import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct CommentFeedback: Sendable {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Sendable, Identifiable {
        public var id: UUID { questionId }
        var questionId: UUID
        var questionText: String
        var commentTextField: String
        var feedbackCompleted: Bool {
            !commentTextField.isEmpty
        }
        public init(
            questionId: UUID,
            questionText: String,
            commentTextField: String = ""
        ) {
            self.questionId = questionId
            self.questionText = questionText
            self.commentTextField = commentTextField
        }
    }
    
    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case onTapOutsideTextfield
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case setCommentTextfieldFocus(Bool)
        }
    }
    
    @Dependency(\.continuousClock) var clock
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .onTapOutsideTextfield:
                return .send(.delegate(.setCommentTextfieldFocus(false)))
                
            case .binding:
                return .none
                
            case .onAppear:
                guard state.commentTextField.isEmpty else { return .none }
                return .run { send in
                    try await clock.sleep(for: .seconds(0.5))
                    await send(.delegate(.setCommentTextfieldFocus(true)))
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
