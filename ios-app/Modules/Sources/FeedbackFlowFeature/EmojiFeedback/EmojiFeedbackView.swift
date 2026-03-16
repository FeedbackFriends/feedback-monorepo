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
            HStack {
                EmojiFaceButtonView(image: .verySad, isSelected: store.selectedEmoji == .verySad) {
                    store.send(.onSmileyTapped(.verySad), animation: .bouncy)
                }
                EmojiFaceButtonView(image: .sad, isSelected: store.selectedEmoji == .sad) {
                    store.send(.onSmileyTapped(.sad), animation: .bouncy)
                }
                EmojiFaceButtonView(image: .happy, isSelected: store.selectedEmoji == .happy) {
                    store.send(.onSmileyTapped(.happy), animation: .bouncy)
                }
                EmojiFaceButtonView(image: .veryHappy, isSelected: store.selectedEmoji == .veryHappy) {
                    store.send(.onSmileyTapped(.veryHappy), animation: .bouncy)
                }
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

private struct EmojiFaceButtonView: View {
    let image: Image
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .grayscale(isSelected ? 0.0 : 1.0)
                .padding(isSelected ? 10 : 13)
                .opacity(isSelected ? 1.0 : 0.6)
        }
    }
}

#Preview {
    @Previewable @FocusState var isFocused: Bool
    return EmojiFeedbackView(
        store: StoreOf<EmojiFeedback>(
            initialState: EmojiFeedback.State(
                questionId: UUID(),
                questionText: "Hello world"
            ),
            reducer: { EmojiFeedback() }
        ),
        commentTextfieldFocused: $isFocused
    )
}
