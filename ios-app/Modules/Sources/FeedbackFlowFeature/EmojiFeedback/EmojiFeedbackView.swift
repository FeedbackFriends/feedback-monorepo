import DesignSystem
import ComposableArchitecture
import Domain
import SwiftUI

public struct EmojiFeedbackView: View {
    @FocusState.Binding var commentTextfieldFocused: Bool
    @Bindable var store: StoreOf<EmojiFeedback>

    public init(store: StoreOf<EmojiFeedback>, commentTextfieldFocused: FocusState<Bool>.Binding) {
        self.store = store
        self._commentTextfieldFocused = commentTextfieldFocused
    }

    public var body: some View {
        VStack {
            EmojiRatingView(selected: store.selectedEmoji) { value in
                store.send(.onSmileyTapped(value), animation: .bouncy)
            }
            .padding(.horizontal, 2)
            .frame(maxWidth: Constants.maxWidthForLargeDevices, alignment: .center)

            if store.selectedEmoji != nil {
                FeedbackElaborationTextField(
                    commentTextField: $store.commentTextField,
                    commentTextfieldFocused: $commentTextfieldFocused
                )
                .animation(.bouncy, value: store.selectedEmoji)
            }
        }
        .background(Color.clear)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .animation(.easeInOut(duration: 0.2), value: store.selectedEmoji)
        .onTapGesture { store.send(.onTapOutsideTextfield) }
        .sensoryFeedback(.selection, trigger: store.selectedEmoji)
    }
}

#Preview {
    @Previewable @FocusState var isFocused: Bool
    return EmojiFeedbackView(
        store: StoreOf<EmojiFeedback>(
            initialState: EmojiFeedback.State(
                questionId: UUID(),
                questionText: "Hvordan var mødet?"
            ),
            reducer: { EmojiFeedback() }
        ),
        commentTextfieldFocused: $isFocused
    )
}
