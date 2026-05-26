import SwiftUI

public struct LetsGrowFeedbackLogoView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            Text("Lets Grow")
                .font(.montserratMedium, 30)
                .foregroundStyle(Color.themeTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Feedback")
                .font(.montserratExtraBold, 42)
                .foregroundStyle(Color.themeText.gradient)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: 250)
    }
}
