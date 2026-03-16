import DesignSystem
import ComposableArchitecture
import Domain
import SwiftUI

public struct CommentFeedbackView: View {
    @FocusState.Binding var commentTextfieldFocused: Bool
    @Bindable var store: StoreOf<CommentFeedback>

    public init(store: StoreOf<CommentFeedback>, commentTextfieldFocused: FocusState<Bool>.Binding) {
        self.store = store
        self._commentTextfieldFocused = commentTextfieldFocused
    }

    public var body: some View {
        VStack {
            FeedbackElaborationTextField(
                commentTextField: $store.commentTextField,
                commentTextfieldFocused: $commentTextfieldFocused
            )
        }
        .background(Color.clear)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .onTapGesture { store.send(.onTapOutsideTextfield) }
        .onAppear { store.send(.onAppear) }
    }
}

#Preview {
    @Previewable @FocusState var isFocused: Bool
    return CommentFeedbackView(
        store: StoreOf<CommentFeedback>(
            initialState: CommentFeedback.State(
                questionId: UUID(),
                questionText: "Hello world"
            ),
            reducer: { CommentFeedback() }
        ),
        commentTextfieldFocused: $isFocused
    )
}
