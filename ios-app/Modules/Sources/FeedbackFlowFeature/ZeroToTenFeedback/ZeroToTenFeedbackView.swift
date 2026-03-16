import ComposableArchitecture
import SwiftUI
import DesignSystem

struct ZeroToTenFeedbackView: View {
    
    @FocusState.Binding var commentTextfieldFocused: Bool
    @Bindable var store: StoreOf<ZeroToTenFeedback>
    
    public init(
        store: StoreOf<ZeroToTenFeedback>,
        commentTextfieldFocused: FocusState<Bool>.Binding
    ) {
        self.store = store
        self._commentTextfieldFocused = commentTextfieldFocused
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(store.ratingAsInt)")
                    .font(.montserratBold, 20)
                    .monospacedDigit()
                    .foregroundStyle(store.ratingAsInt.ratingColor)
                Text("af 10")
                    .font(.montserratRegular, 14)
                    .foregroundStyle(Color.themeText)
            }
            Slider(
                value: $store.rating,
                in: 0...10,
                step: 1
            ) {
                Text("Rating")
            } minimumValueLabel: {
                Text("0").font(.montserratMedium, 15)
            } maximumValueLabel: {
                Text("10").font(.montserratMedium, 15)
            } onEditingChanged: { editing in
                store.send(.onEditingSliderChanged(editing))
            }
            .tint(store.ratingAsInt.ratingColor)
            
            FeedbackElaborationTextField(
                commentTextField: $store.commentTextField,
                commentTextfieldFocused: $commentTextfieldFocused
            )
            .padding(.top, 8)
        }
        .background(Color.clear)
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .animation(.easeInOut(duration: 0.2), value: store.rating)
        .onTapGesture { store.send(.onTapOutsideTextfield) }
        .sensoryFeedback(.selection, trigger: store.rating)
        .foregroundStyle(Color.themeText)
    }
}

#Preview {
    @Previewable @FocusState var isFocused: Bool
    return ZeroToTenFeedbackView(
        store: StoreOf<ZeroToTenFeedback>(
            initialState: ZeroToTenFeedback.State(
                questionId: UUID(),
                questionText: "Hello world"
            ),
            reducer: { ZeroToTenFeedback() }
        ),
        commentTextfieldFocused: $isFocused
    )
}
