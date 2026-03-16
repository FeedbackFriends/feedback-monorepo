import DesignSystem
import ComposableArchitecture
import Domain
import SwiftUI

public struct OpinionFeedbackView: View {
    @FocusState.Binding var commentTextfieldFocused: Bool
    @Bindable var store: StoreOf<OpinionFeedback>

    public init(store: StoreOf<OpinionFeedback>, commentTextfieldFocused: FocusState<Bool>.Binding) {
        self.store = store
        self._commentTextfieldFocused = commentTextfieldFocused
    }

    public var body: some View {
        VStack {
            VStack {
                if let selectedOpinion = store.selectedOpinion {
                    opinionView(
                        opinion: selectedOpinion
                    ) {
                        store.send(.onOpinionTapped(selectedOpinion))
                    }
                    .transition(.blurReplace)
                } else {
                    opinionView(
                        opinion: .stronglyAgree
                    ) {
                        store.send(.onOpinionTapped(.stronglyAgree))
                    }
                    opinionView(
                        opinion: .agree
                    ) {
                        store.send(.onOpinionTapped(.agree))
                    }
                    opinionView(
                        opinion: .neutral
                    ) {
                        store.send(.onOpinionTapped(.neutral))
                    }
                    opinionView(
                        opinion: .disagree
                    ) {
                        store.send(.onOpinionTapped(.disagree))
                    }
                    opinionView(
                        opinion: .stronglyDisagree
                    ) {
                        store.send(.onOpinionTapped(.stronglyDisagree))
                    }
                }
            }
            .padding(.horizontal, 2)
            .frame(maxWidth: Constants.maxWidthForLargeDevices, alignment: .center)

            if store.selectedOpinion != nil {
                FeedbackElaborationTextField(
                    commentTextField: $store.commentTextField,
                    commentTextfieldFocused: $commentTextfieldFocused
                )
            }
        }
        .animation(.smooth, value: store.selectedOpinion)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .onTapGesture { store.send(.onTapOutsideTextfield) }
        .sensoryFeedback(.selection, trigger: store.selectedOpinion)
    }
    
    @ViewBuilder
    func opinionView(
        opinion: Opinion,
        action: @escaping () -> Void
    ) -> some View {
        let isSelected = (store.selectedOpinion == opinion)
            Button(action: action) {
                HStack(spacing: 14) {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(opinion.color.gradient)
                    Text(opinion.localized)
                        .font(.montserratMedium, 14)
                        .lineLimit(2)
                        .foregroundColor(.themeText)
                    Spacer(minLength: 0)
                    if isSelected {
                        Text("Change")
                            .font(.montserratRegular, 10)
                            .foregroundColor(.themeTextSecondary)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .animation(.smooth, value: isSelected)
                .transition(.blurReplace)
            }
            .buttonStyle(GlassButtonStyle())
    }
}

#Preview {
    @Previewable @FocusState var isFocused: Bool
    return OpinionFeedbackView(
        store: StoreOf<OpinionFeedback>(
            initialState: OpinionFeedback.State(
                questionId: UUID(),
                questionText: "Hello world"
            ),
            reducer: { OpinionFeedback() }
        ),
        commentTextfieldFocused: $isFocused
    )
}
