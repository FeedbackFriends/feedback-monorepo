import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

/// A read-only illustration using the same answer controls as the participant flow.
public struct FeedbackQuestionIllustrationView: View {
    let questionText: String
    let feedbackType: FeedbackType
    @State private var store: StoreOf<FeedbackFlowCoordinator.Path>
    @FocusState private var commentFocused: Bool

    public init(questionText: String, feedbackType: FeedbackType) {
        self.questionText = questionText
        self.feedbackType = feedbackType
        self._store = State(initialValue: Store(
            initialState: FeedbackFlowCoordinator.Path.State(
                ParticipantQuestion(id: UUID(), questionText: questionText, feedbackType: feedbackType)
            )
        ) { EmptyReducer() })
    }

    public var body: some View {
        VStack(spacing: 8) {
            Text(questionText)
                .bodyTextStyle()
                .foregroundStyle(Color.themeText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)

            answerControl
                .frame(height: answerControlHeight)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.themeGradientBlue, .themeGradientRed],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Eksempel på deltagernes visning. \(questionText)")
    }

    @ViewBuilder
    private var answerControl: some View {
        switch store.case {
        case let .emoji(store):
            EmojiFeedbackView(store: store, commentTextfieldFocused: $commentFocused)
        case let .zeroToTen(store):
            ZeroToTenFeedbackView(store: store, commentTextfieldFocused: $commentFocused)
        case let .thumpsUpThumpsDown(store):
            ThumpsFeedbackView(store: store, commentTextfieldFocused: $commentFocused)
        case let .comment(store):
            CommentFeedbackView(store: store, commentTextfieldFocused: $commentFocused)
        case let .opinion(store):
            OpinionFeedbackView(store: store, commentTextfieldFocused: $commentFocused)
        }
    }

    private var answerControlHeight: CGFloat {
        switch feedbackType {
        case .emoji, .thumpsUpThumpsDown: 100
        case .comment: 180
        case .zeroToTen: 260
        case .opinion: 300
        }
    }
}
