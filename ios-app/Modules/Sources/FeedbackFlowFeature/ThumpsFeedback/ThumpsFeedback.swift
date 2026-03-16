import ComposableArchitecture
import Foundation
import Domain

@Reducer
public struct ThumpsFeedback: Sendable {
    
    public init () {}
    @ObservableState
    public struct State: Equatable, Sendable, Identifiable {
        public var id: UUID { questionId }
        var questionId: UUID
        let questionText: String
        var selectedThump: ThumbsUpThumpsDown?
        var commentTextField: String
        var feedbackCompleted: Bool {
            selectedThump != nil
        }
        
        public init(
            questionId: UUID,
            questionText: String,
            commentTextField: String = "",
            selectedThump: ThumbsUpThumpsDown? = nil
        ) {
            self.questionId = questionId
            self.questionText = questionText
            self.commentTextField = commentTextField
            self.selectedThump = selectedThump
        }
    }
    
    static func isThumpSelected(_ thump: ThumbsUpThumpsDown?, matches: ThumbsUpThumpsDown) -> Bool {
        guard let thump else { return false }
        return thump == matches
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case thumpTap(ThumbsUpThumpsDown)
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case setCommentTextfieldFocus(Bool)
        }
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            
            switch action {
                
            case .binding:
                return .none
                
            case .thumpTap(let thump):
                state.selectedThump = thump
                return .send(.delegate(.setCommentTextfieldFocus(true)))
                
            case .delegate:
                return .none
            }
        }
    }
}
