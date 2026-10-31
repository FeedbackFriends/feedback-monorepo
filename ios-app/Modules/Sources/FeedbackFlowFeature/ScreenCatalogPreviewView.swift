#if DEBUG
import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

@MainActor
private enum CatalogFeedback {
    static func state(_ answer: FeedbackFlowCoordinator.Path.State) -> FeedbackFlowCoordinator.State {
        var state = FeedbackFlowCoordinator.State.initialState(
            feedbackSession: PreviewCatalogFixtures.feedbackSession(type: answer.feedbackType)
        )
        state.questions = [answer]
        state.path = StackState([answer])
        return state
    }

    static func view(_ state: FeedbackFlowCoordinator.State) -> some View {
        FeedbackFlowCoordinatorView(store: Store(initialState: state) { EmptyReducer() }) {
            Text("Ugentligt teammøde")
        }
    }
}

private extension FeedbackFlowCoordinator.Path.State {
    var feedbackType: FeedbackType {
        switch self {
        case .emoji: .emoji
        case .zeroToTen: .zeroToTen
        case .thumpsUpThumpsDown: .thumpsUpThumpsDown
        case .comment: .comment
        case .opinion: .opinion
        }
    }
}

@MainActor
private func catalogFeedbackEmojiUnanswered() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.emoji(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText
        ))))
    }
}

#Preview("feedback.emoji.unanswered") {
    catalogFeedbackEmojiUnanswered()
}

@MainActor
func catalogFeedbackEmojiVerySad() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.emoji(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, selectedEmoji: .verySad
        ))))
    }
}

#Preview("feedback.emoji.very-sad") {
    catalogFeedbackEmojiVerySad()
}

@MainActor
private func catalogFeedbackEmojiSad() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.emoji(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, selectedEmoji: .sad
        ))))
    }
}

#Preview("feedback.emoji.sad") {
    catalogFeedbackEmojiSad()
}

@MainActor
private func catalogFeedbackEmojiHappy() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.emoji(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, selectedEmoji: .happy
        ))))
    }
}

// Screenshot: Distinct answer control.
#Preview("feedback.emoji.happy") {
    catalogFeedbackEmojiHappy()
}

@MainActor
func catalogFeedbackEmojiVeryHappy() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.emoji(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, selectedEmoji: .veryHappy
        ))))
    }
}

#Preview("feedback.emoji.very-happy") {
    catalogFeedbackEmojiVeryHappy()
}

@MainActor
private func catalogFeedbackEmojiComment() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.emoji(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, selectedEmoji: .happy, commentTextField: "God dialog og tydelige næste skridt."
        ))))
    }
}

// Screenshot: Distinct answer control.
#Preview("feedback.emoji.comment") {
    catalogFeedbackEmojiComment()
}

@MainActor
private func catalogFeedbackRatingDefault() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.zeroToTen(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText
        ))))
    }
}

#Preview("feedback.rating.default") {
    catalogFeedbackRatingDefault()
}

@MainActor
private func catalogFeedbackRatingLow() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.zeroToTen(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, rating: 0
        ))))
    }
}

#Preview("feedback.rating.low") {
    catalogFeedbackRatingLow()
}

@MainActor
private func catalogFeedbackRatingHigh() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.zeroToTen(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, rating: 10
        ))))
    }
}

// Screenshot: Distinct answer control.
#Preview("feedback.rating.high") {
    catalogFeedbackRatingHigh()
}

@MainActor
func catalogFeedbackRatingComment() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.zeroToTen(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, commentTextField: "God dialog og tydelige næste skridt.", rating: 8
        ))))
    }
}

#Preview("feedback.rating.comment") {
    catalogFeedbackRatingComment()
}

@MainActor
private func catalogFeedbackThumbsUnanswered() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.thumpsUpThumpsDown(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText
        ))))
    }
}

#Preview("feedback.thumbs.unanswered") {
    catalogFeedbackThumbsUnanswered()
}

@MainActor
private func catalogFeedbackThumbsUp() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.thumpsUpThumpsDown(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, selectedThump: .up
        ))))
    }
}

// Screenshot: Distinct answer control.
#Preview("feedback.thumbs.up") {
    catalogFeedbackThumbsUp()
}

@MainActor
private func catalogFeedbackThumbsDown() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.thumpsUpThumpsDown(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, selectedThump: .down
        ))))
    }
}

#Preview("feedback.thumbs.down") {
    catalogFeedbackThumbsDown()
}

@MainActor
private func catalogFeedbackThumbsComment() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.thumpsUpThumpsDown(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, commentTextField: "Mere tid til spørgsmål næste gang.", selectedThump: .down
        ))))
    }
}

#Preview("feedback.thumbs.comment") {
    catalogFeedbackThumbsComment()
}

@MainActor
private func catalogFeedbackOpinionUnanswered() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.opinion(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText
        ))))
    }
}

#Preview("feedback.opinion.unanswered") {
    catalogFeedbackOpinionUnanswered()
}

@MainActor
private func catalogFeedbackOpinionStronglyDisagree() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.opinion(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, selectedOpinion: .stronglyDisagree
        ))))
    }
}

#Preview("feedback.opinion.strongly-disagree") {
    catalogFeedbackOpinionStronglyDisagree()
}

@MainActor
private func catalogFeedbackOpinionDisagree() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.opinion(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, selectedOpinion: .disagree
        ))))
    }
}

#Preview("feedback.opinion.disagree") {
    catalogFeedbackOpinionDisagree()
}

@MainActor
func catalogFeedbackOpinionNeutral() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.opinion(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, selectedOpinion: .neutral
        ))))
    }
}

#Preview("feedback.opinion.neutral") {
    catalogFeedbackOpinionNeutral()
}

@MainActor
private func catalogFeedbackOpinionAgree() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.opinion(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, selectedOpinion: .agree
        ))))
    }
}

// Screenshot: Distinct answer control.
#Preview("feedback.opinion.agree") {
    catalogFeedbackOpinionAgree()
}

@MainActor
private func catalogFeedbackOpinionStronglyAgree() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.opinion(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, selectedOpinion: .stronglyAgree
        ))))
    }
}

#Preview("feedback.opinion.strongly-agree") {
    catalogFeedbackOpinionStronglyAgree()
}

@MainActor
func catalogFeedbackCommentEmpty() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.comment(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText
        ))))
    }
}

#Preview("feedback.comment.empty") {
    catalogFeedbackCommentEmpty()
}

@MainActor
func catalogFeedbackCommentPopulated() -> some View {
    ScreenCatalogContainerView {
        CatalogFeedback.view(CatalogFeedback.state(.comment(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, commentTextField: "Behold den åbne dialog. Afsæt mere tid til spørgsmål og afslut med tydelige aftaler."
        ))))
    }
}

// Screenshot: Distinct answer control.
#Preview("feedback.comment.populated") {
    catalogFeedbackCommentPopulated()
}

@MainActor
private func catalogFeedbackSubmitting() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = CatalogFeedback.state(.zeroToTen(.init(
                questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, rating: 8
            )))
            state.submitFeedbackInFlight = true
            return state
        }()
        CatalogFeedback.view(state)
    }
}

#Preview("feedback.submitting") {
    catalogFeedbackSubmitting()
}

@MainActor
private func catalogFeedbackSuccess() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = CatalogFeedback.state(.zeroToTen(.init(
                questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, rating: 8
            )))
            state.isSuccessMessagePresented = true
            return state
        }()
        CatalogFeedback.view(state)
    }
}

// Screenshot: Distinct screen or presentation.
#Preview("feedback.success") {
    catalogFeedbackSuccess()
}

@MainActor
func catalogFeedbackPreviewMode() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = CatalogFeedback.state(.zeroToTen(.init(
                questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, rating: 8
            )))
            state.isPreview = true
            return state
        }()
        CatalogFeedback.view(state)
    }
}

#Preview("feedback.preview-mode") {
    catalogFeedbackPreviewMode()
}

@MainActor
func catalogFeedbackRatingPrompt() -> some View {
    ScreenCatalogContainerView {
        var state = CatalogFeedback.state(.zeroToTen(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, rating: 8
        )))
        state.destination = .ratingPrompt
        return FeedbackFlowCoordinatorView(store: Store(initialState: state) {
            Reduce<FeedbackFlowCoordinator.State, FeedbackFlowCoordinator.Action> { state, action in
                if case .destination(.dismiss) = action {
                    state.destination = nil
                }
                return .none
            }
        }) {
            Text("Ugentligt teammøde")
        }
    }
}

// Screenshot: Distinct screen or presentation.
#Preview("feedback.rating-prompt") {
    catalogFeedbackRatingPrompt()
}

@MainActor
private func catalogFeedbackEventInfo() -> some View {
    ScreenCatalogContainerView {
        var state = CatalogFeedback.state(.zeroToTen(.init(
            questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, rating: 8
        )))
        state.destination = .showEventInfo
        return FeedbackFlowCoordinatorView(store: Store(initialState: state) {
            Reduce<FeedbackFlowCoordinator.State, FeedbackFlowCoordinator.Action> { state, action in
                if case .destination(.dismiss) = action {
                    state.destination = nil
                }
                return .none
            }
        }) {
            Text("Ugentligt teammøde")
        }
    }
}

// Screenshot: Distinct screen or presentation.
#Preview("feedback.event-info") {
    catalogFeedbackEventInfo()
}

@MainActor
private func catalogExtraFeedbackMiddleQuestion() -> some View {
    ScreenCatalogContainerView {
        let state = {
            let first = FeedbackFlowCoordinator.Path.State.emoji(.init(
                questionId: PreviewCatalogFixtures.id(9), questionText: "Hvordan var mødet?", selectedEmoji: .happy
            ))
            let current = FeedbackFlowCoordinator.Path.State.zeroToTen(.init(
                questionId: PreviewCatalogFixtures.id(10), questionText: PreviewCatalogFixtures.questionText, rating: 8
            ))
            let last = FeedbackFlowCoordinator.Path.State.comment(.init(
                questionId: PreviewCatalogFixtures.id(11), questionText: "Hvad kan vi gøre bedre næste gang?"
            ))
            var state = CatalogFeedback.state(current)
            state.questions = [first, current, last]
            state.path = StackState([first, current])
            return state
        }()
        CatalogFeedback.view(state)
    }
}

#Preview("feedback.middle-question") {
    catalogExtraFeedbackMiddleQuestion()
}

// BEGIN GENERATED SNAPSHOT CATALOG
// Generated by scripts/screen-catalog.py --generate. Do not edit this section.
@MainActor
enum FeedbackFlowFeatureScreenSnapshotCatalog {
    static var samples: [ScreenSnapshotSample] {
        [
            .init(id: "feedback.emoji.happy", size: CGSize(width: 402, height: 874)) {
                catalogFeedbackEmojiHappy()
            },
            .init(id: "feedback.emoji.comment", size: CGSize(width: 402, height: 874)) {
                catalogFeedbackEmojiComment()
            },
            .init(id: "feedback.rating.high", size: CGSize(width: 402, height: 874)) {
                catalogFeedbackRatingHigh()
            },
            .init(id: "feedback.thumbs.up", size: CGSize(width: 402, height: 874)) {
                catalogFeedbackThumbsUp()
            },
            .init(id: "feedback.opinion.agree", size: CGSize(width: 402, height: 874)) {
                catalogFeedbackOpinionAgree()
            },
            .init(id: "feedback.comment.populated", size: CGSize(width: 402, height: 874)) {
                catalogFeedbackCommentPopulated()
            },
            .init(id: "feedback.success", size: CGSize(width: 402, height: 874)) {
                catalogFeedbackSuccess()
            },
            .init(id: "feedback.rating-prompt", size: CGSize(width: 402, height: 874)) {
                catalogFeedbackRatingPrompt()
            },
            .init(id: "feedback.event-info", size: CGSize(width: 402, height: 874)) {
                catalogFeedbackEventInfo()
            }
        ]
    }
}
// END GENERATED SNAPSHOT CATALOG
#endif
