import SwiftUI
import StoreKit
import Domain
import DesignSystem

public struct RatingAlertView: View {
    
    let title: String
    let message: String
    @Environment(\.dismiss) var dismiss
    @AccessibilityFocusState private var isFocused: Bool
    @Environment(\.requestReview) var requestReview
    
    public init(
        title: String = "Happy with the app so far?",
        message: String = "A rating on App Store can encourage others to give it a try. 👌🏽"
    ) {
        self.title = title
        self.message = message
    }
    
    public var body: some View {
        NavigationStack {
            content
                .presentationDetents([.height(300)])
				.frame(maxWidth: .infinity)
				.background(Color.themeSurface.ignoresSafeArea())
				.interactiveDismissDisabled()
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						CloseButtonView {
							self.dismiss()
						}
					}
					ToolbarItem(placement: .bottomBar) {
						Button("Not now") {
							self.dismiss()
						}
						.buttonStyle(SecondaryTextButtonStyle())
					}
					.sharedBackgroundVisibility(.hidden)
					ToolbarSpacer(.flexible, placement: .bottomBar)
					ToolbarItem(placement: .bottomBar) {
						Button("Rate app") {
							Task { @MainActor in
								self.dismiss()
								// Delay the task by 0.5 second
								try await Task.sleep(for: .seconds(0.5))
								requestReview()
							}
						}
						.buttonStyle(PrimaryTextButtonStyle())
					}
					.sharedBackgroundVisibility(.hidden)
				}
		}
    }
}

private extension RatingAlertView {
    
    private var content: some View {
        VStack(alignment: .center, spacing: 26) {
            Text(title)
                .font(.montserratBold, 20)
                .foregroundColor(Color.themeText)
                .multilineTextAlignment(.center)
                .accessibilityFocused($isFocused)
            LottieView(lottieFile: .fiveStars)
                .frame(width: 300, height: 36)
            Text(message)
                .font(.montserratRegular, 14)
                .foregroundColor(Color.themeText.opacity(0.7))
                .multilineTextAlignment(.center)
                .accessibilityFocused($isFocused)
                .lineSpacing(5)
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
	RatingAlertView(title: "Title", message: "Message")
}
