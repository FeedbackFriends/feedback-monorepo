import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct OpinionFeedback: Sendable {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Sendable, Identifiable {
        public var id: UUID { questionId }
        var questionId: UUID
        var questionText: String
        var selectedOpinion: Opinion?
        var commentTextField: String
        var feedbackCompleted: Bool {
            selectedOpinion != nil
        }
        public init(
            questionId: UUID,
            questionText: String,
            selectedOpinion: Opinion? = nil,
            commentTextField: String = ""
        ) {
            self.questionId = questionId
            self.questionText = questionText
            self.selectedOpinion = selectedOpinion
            self.commentTextField = commentTextField
        }
    }
    
    public enum Action: BindableAction {
        case onOpinionTapped(Opinion)
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
                
            case .onOpinionTapped(let opinion):
                if state.selectedOpinion != nil {
                    state.selectedOpinion = nil
                    return .send(.delegate(.setCommentTextfieldFocus(false)))
                }
                state.selectedOpinion = opinion
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
