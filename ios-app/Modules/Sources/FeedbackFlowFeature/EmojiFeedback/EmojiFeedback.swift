import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct EmojiFeedback: Sendable {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Sendable, Identifiable {
        public var id: UUID { questionId }
        var questionId: UUID
        var questionText: String
        var selectedEmoji: Emoji?
        var commentTextField: String
        var feedbackCompleted: Bool {
            selectedEmoji != nil
        }
        public init(
            questionId: UUID,
            questionText: String,
            selectedEmoji: Emoji? = nil,
            commentTextField: String = ""
        ) {
            self.questionId = questionId
            self.questionText = questionText
            self.selectedEmoji = selectedEmoji
            self.commentTextField = commentTextField
        }
    }
    
    public enum Action: BindableAction {
        case onSmileyTapped(Emoji)
        case binding(BindingAction<State>)
        case onTapOutsideTextfield
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case setCommentTextfieldFocus(Bool)
        }
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .onTapOutsideTextfield:
                return .send(.delegate(.setCommentTextfieldFocus(false)))
                
            case .binding:
                return .none
                
            case .onSmileyTapped(let rating):
                state.selectedEmoji = rating
                return .send(.delegate(.setCommentTextfieldFocus(true)))
                
            case .delegate:
                return .none
            }
        }
    }
}
