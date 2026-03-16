import Domain
import DesignSystem
import SwiftUI
import ComposableArchitecture
import Utility

@Reducer
public struct FeedbackFlowCoordinator: Sendable {
    
    public init() {}
    
    @Reducer
    public enum Path {
        case emoji(EmojiFeedback)
        case zeroToTen(ZeroToTenFeedback)
        case thumpsUpThumpsDown(ThumpsFeedback)
        case comment(CommentFeedback)
        case opinion(OpinionFeedback)
    }
    
    @Reducer
    public enum Destination {
        case alert(AlertState<Never>)
        @ReducerCaseIgnored
        case showEventInfo
        @ReducerCaseIgnored
        case ratingPrompt
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        
        @Presents var destination: Destination.State?
        var path: StackState<Path.State>
        var submitFeedbackInFlight: Bool
        var presentSuccessOverlay: Bool
        var feedbackItemCompleted: Bool {
            switch path[questionIndex] {
                
            case .emoji(let emojiFeedback):
                emojiFeedback.feedbackCompleted
                
            case .zeroToTen(let zeroToTenFeedback):
                zeroToTenFeedback.feedbackCompleted
                
            case .thumpsUpThumpsDown(let thumpsFeedback):
                thumpsFeedback.feedbackCompleted
                
            case .comment(let commentFeedback):
                commentFeedback.feedbackCompleted
                
            case .opinion(let opinionFeedback):
                opinionFeedback.feedbackCompleted
            }
        }
        var questions: IdentifiedArrayOf<Path.State>
        var date: Date {
            feedbackSession.date
        }
        let feedbackSession: FeedbackSession
        var commentTextfieldFocused: Bool
        public var title: String {
            feedbackSession.title
        }
        var agenda: String? {
            feedbackSession.agenda
        }
        var ownerInfo: OwnerInfo {
            feedbackSession.ownerInfo
        }
        var questionText: String {
            questions[questionIndex].questionText
        }
        var questionIndex: Int {
            path.count - 1
        }
        var pinCode: PinCode {
            feedbackSession.pinCode
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case path(StackActionOf<Path>)
        case infoButtonTap
        case presentError(Error)
        case submitFeedbackResponse(shouldPresentRatingPrompt: Bool)
        case previousQuestionButtonTap
        case nextQuestionButtonTap
        case submitButtonTap
        case destination(PresentationAction<Destination.Action>)
        case presentRatingPrompt
        case ratingPromptDismissed
        case navigateToNextQuestion
        case navigateToPreviousQuestion
        case dismissButtonTap
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.continuousClock) var clock
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .dismissButtonTap:
                return .run { [dismiss] _ in await dismiss() }
                
            case .ratingPromptDismissed:
                return .run { _ in
                    try await clock.sleep(for: .seconds(1))
                    await dismiss()
                }
                
            case .destination:
                return .none
                
            case .path(let pathAction):
                switch pathAction {
                case .element(id: _, action: .emoji(.delegate(.setCommentTextfieldFocus(let commentTextfieldFocused)))),
                        .element(id: _, action: .zeroToTen(.delegate(.setCommentTextfieldFocus(let commentTextfieldFocused)))),
                        .element(id: _, action: .comment(.delegate(.setCommentTextfieldFocus(let commentTextfieldFocused)))),
                        .element(id: _, action: .opinion(.delegate(.setCommentTextfieldFocus(let commentTextfieldFocused)))),
                        .element(id: _, action: .thumpsUpThumpsDown(.delegate(.setCommentTextfieldFocus(let commentTextfieldFocused)))):
                    state.commentTextfieldFocused = commentTextfieldFocused
                    return .none
                default:
                    return .none
                }
                
            case .infoButtonTap:
                state.destination = .showEventInfo
                return .none
             
            case .presentError(let error):
                state.submitFeedbackInFlight = false
                state.destination = .alert(.init(error: error))
                return .none
                
            case .submitFeedbackResponse(let shouldPrompt):
                state.presentSuccessOverlay = true
                state.submitFeedbackInFlight = false
                return .run { send in
                    try await clock.sleep(for: Constants.successOverlayDuration)
                    if shouldPrompt {
                        await send(.presentRatingPrompt)
                    } else {
                        await dismiss()
                    }
                }
                
            case .previousQuestionButtonTap:
                guard !state.path.isEmpty else { return .none }
                guard !state.commentTextfieldFocused else {
                    state.commentTextfieldFocused = false
                    return .run { send in
                        try await clock.sleep(for: .seconds(0.3))
                        await send(.navigateToPreviousQuestion)
                    }
                }
                return .send(.navigateToPreviousQuestion)
                
            case .nextQuestionButtonTap:
                guard state.path.count < state.questions.count else { return .none }
                guard !state.commentTextfieldFocused else {
                    state.commentTextfieldFocused = false
                    return .run { send in
                        try await clock.sleep(for: .seconds(0.3))
                        await send(.navigateToNextQuestion)
                    }
                }
                return .send(.navigateToNextQuestion)
                
            case .submitButtonTap:
                state.commentTextfieldFocused = false
                state.submitFeedbackInFlight = true
                return .run { [state = state] send in
                    do {
                        let shouldPresentRatingPrompt = try await self.apiClient.submitFeedback(
                            feedback: state.path.map { FeedbackInput($0) },
                            pinCode: state.pinCode
                        )
                        await send(.submitFeedbackResponse(shouldPresentRatingPrompt: shouldPresentRatingPrompt))
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .binding:
                return .none
                
            case .presentRatingPrompt:
                state.destination = .ratingPrompt
                return .none
                
            case .navigateToNextQuestion:
                if let next = state.questions[safe: state.questionIndex + 1] {
                    state.path.append(next)
                }
                return .none
                
            case .navigateToPreviousQuestion:
                if state.path.count > 1 {
                    let poppedElement = state.path.popLast()
                    if let poppedElement {
                        state.questions.updateOrAppend(poppedElement)
                    }
                }
                return .none
                
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .forEach(\.path, action: \.path)
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension FeedbackFlowCoordinator.State {
    public static func initialState(feedbackSession: FeedbackSession) -> Self {
        let questionStates = IdentifiedArrayOf(uniqueElements: feedbackSession.questions.map { FeedbackFlowCoordinator.Path.State($0) })
        guard let first = questionStates.first else {
            fatalError("There should be at least one question in a feedback session")
        }
        
        return .init(
            path: .init([first]),
            submitFeedbackInFlight: false,
            presentSuccessOverlay: false,
            questions: questionStates,
            feedbackSession: feedbackSession,
            commentTextfieldFocused: false
        )
    }
}

extension FeedbackFlowCoordinator.Path.State: Equatable, Sendable {}

extension FeedbackFlowCoordinator.Path.State: Identifiable {
    
    init(_ question: ParticipantQuestion) {
        switch question.feedbackType {
            
        case .emoji:
            self = .emoji(
                .init(
                    questionId: question.id,
                    questionText: question.questionText
                )
            )
        case .comment:
            self = .comment(
                .init(
                    questionId: question.id,
                    questionText: question.questionText
                )
            )
            
        case .thumpsUpThumpsDown:
            self = .thumpsUpThumpsDown(
                .init(
                    questionId: question.id,
                    questionText: question.questionText
                )
            )
        case .opinion:
            self = .opinion(
                .init(
                    questionId: question.id,
                    questionText: question.questionText
                )
            )
            
        case .zeroToTen:
            self = .zeroToTen(
                .init(
                    questionId: question.id,
                    questionText: question.questionText
                )
            )
        }
    }
    
    public var id: UUID {
        questionId
    }
    var questionId: UUID {
        switch self {
        case .emoji(let state):
            state.questionId
        case .zeroToTen(let state):
            state.questionId
        case .thumpsUpThumpsDown(let state):
            state.questionId
        case .comment(let state):
            state.questionId
        case .opinion(let state):
            state.questionId
        }
    }
    var questionText: String {
        switch self {
        case .emoji(let state):
            state.questionText
        case .zeroToTen(let state):
            state.questionText
        case .thumpsUpThumpsDown(let state):
            state.questionText
        case .comment(let state):
            state.questionText
        case .opinion(let state):
            state.questionText
        }
    }
}

extension FeedbackInput {
    init(_ input: FeedbackFlowCoordinator.Path.State) {
        switch input {
            
        case .emoji(let emojiFeedback):
            self = .init(
                type: FeedbackTypeWithData.emoji(
                    emoji: emojiFeedback.selectedEmoji!,
                    comment: emojiFeedback.commentTextField.nilIfEmpty
                ),
                    questionId: input.questionId
                )
        case .zeroToTen(let zeroToTenFeedback):
            self = .init(
                type: FeedbackTypeWithData.zeroToTen(
                    zeroToTen: zeroToTenFeedback.ratingAsInt,
                    comment: zeroToTenFeedback.commentTextField.nilIfEmpty
                ),
                questionId: input.questionId
            )
            
        case .thumpsUpThumpsDown(let thumpsFeedback):
            self = .init(
                type: FeedbackTypeWithData.thumpsUpThumpsDown(
                    thumbsUpThumpsDown: thumpsFeedback.selectedThump!,
                    comment: thumpsFeedback.commentTextField.nilIfEmpty
                ),
                questionId: input.questionId
            )
            
        case .comment(let commentFeedback):
            self = .init(
                type: FeedbackTypeWithData.comment(comment: commentFeedback.commentTextField),
                questionId: input.questionId
            )
            
        case .opinion(let opinionFeedback):
            self = .init(
                type: FeedbackTypeWithData.opinion(
                    opinion: opinionFeedback.selectedOpinion!,
                    comment: opinionFeedback.commentTextField.nilIfEmpty
                ),
                questionId: input.questionId
            )
        }
    }
}

extension FeedbackFlowCoordinator.Destination.State: Equatable, Sendable {}
