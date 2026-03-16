import ComposableArchitecture
import Foundation

@Reducer
public struct ZeroToTenFeedback: Sendable {
    
    public init () {}
    @ObservableState
    public struct State: Equatable, Sendable, Identifiable {
        public var id: UUID { questionId }
        var questionId: UUID
        let questionText: String
        var rating: Double
        var commentTextField: String
        var feedbackCompleted: Bool {
            true
        }
        var ratingAsInt: Int {
            Int(rating.rounded())
        }
        
        public init(
            questionId: UUID,
            questionText: String,
            commentTextField: String = "",
            rating: Double = 5
        ) {
            self.questionId = questionId
            self.questionText = questionText
            self.commentTextField = commentTextField
            self.rating = rating
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onTapOutsideTextfield
        case delegate(Delegate)
        case onEditingSliderChanged(Bool)
        public enum Delegate: Equatable {
            case setCommentTextfieldFocus(Bool)
        }
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { _, action in
            
            switch action {
             
            case .binding:
                return .none
                
            case .delegate:
                return .none
                
            case .onTapOutsideTextfield:
                return .send(.delegate(.setCommentTextfieldFocus(false)))
                
            case .onEditingSliderChanged(let editing):
                if !editing {
                    return .send(.delegate(.setCommentTextfieldFocus(true)))
                }
                return .none
            }
        }
    }
}
