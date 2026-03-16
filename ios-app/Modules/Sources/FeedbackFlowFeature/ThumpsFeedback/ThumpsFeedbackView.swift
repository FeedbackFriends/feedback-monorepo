import ComposableArchitecture
import DesignSystem
import SwiftUI
import Domain

struct ThumpsFeedbackView: View {
    
    @Bindable var store: StoreOf<ThumpsFeedback>
    @FocusState.Binding var commentTextfieldFocused: Bool
    
    var body: some View {
        VStack {
            HStack(spacing: 18) {
                thumpButton(.down)
                thumpButton(.up)
            }
            .frame(maxWidth: 420)
            if store.selectedThump != nil {
                FeedbackElaborationTextField(
                    commentTextField: $store.commentTextField,
                    commentTextfieldFocused: $commentTextfieldFocused
                )
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .animation(.bouncy, value: store.selectedThump)
        .sensoryFeedback(.selection, trigger: store.selectedThump)
    }
    
    @ViewBuilder
    private func thumpButton(_ thump: ThumbsUpThumpsDown) -> some View {
        let isSelected = ThumpsFeedback.isThumpSelected(store.selectedThump, matches: thump)
        Button {
            store.send(.thumpTap(thump), animation: .bouncy)
        } label: {
            thumpImage(thump)
                .font(.system(size: 34, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(isSelected ? Color.themeOnPrimaryAction : Color.themeTextSecondary)
                .frame(width: 40, height: 40)
                .padding(.vertical, 12)
                .frame(width: 150)
                .background(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius * 1.25, style: .continuous)
                        .fill(buttonBackgroundGradient(isSelected: isSelected, thump: thump))
                )
                .scaleEffect(isSelected ? 1.03 : 1.0)
                .rotation3DEffect(
                    .degrees(isSelected ? (thump == .up ? -8 : 8) : 0),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
        }
    }
    
    func thumpImage(_ thump: ThumbsUpThumpsDown) -> Image {
        thump == .up ? Image.thumpsUp : Image.thumpsDown
    }
    
    private func buttonBackgroundGradient(isSelected: Bool, thump: ThumbsUpThumpsDown) -> LinearGradient {
        if isSelected {
            switch thump {
            case .up:
                return LinearGradient(
                    colors: [Color.themeVeryHappy.opacity(0.5), Color.themeVeryHappy.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .down:
                return LinearGradient(
                    colors: [Color.themeVerySad.opacity(0.5), Color.themeVerySad.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        } else {
            return LinearGradient(
                colors: [Color.themeSurface, Color.themeSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

#Preview {
    @Previewable @FocusState var isFocused: Bool
    ThumpsFeedbackView(
        store: StoreOf<ThumpsFeedback>(
            initialState: ThumpsFeedback.State(
                questionId: UUID(),
                questionText: "Hello world"
            ),
            reducer: { ThumpsFeedback() }
        ),
        commentTextfieldFocused: $isFocused
    )
    .background(Color.themeGradientBlue.ignoresSafeArea())
}
