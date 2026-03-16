import SwiftUI

public struct SecondaryTextButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.isLoading) private var isLoading: Bool
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            if isLoading {
                ProgressView()
            } else {
                configuration.label
            }
        }
        .padding(.horizontal, 8)
        .font(.montserratMedium, 15)
        .foregroundStyle(Color.themeText)
        .opacity(isEnabled ? 1.0 : 0.5)
        .animation(.default, value: isEnabled)
        .progressViewStyle(CircularProgressViewStyle(tint: Color.themeText))
        .opacity(configuration.isPressed ? 0.4 : 1.0)
        .fixedSize()
    }
}
