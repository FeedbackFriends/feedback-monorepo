import SwiftUI

public struct LargeButtonStyle<BackgroundInput: ShapeStyle>: ButtonStyle {

    @Environment(\.isLoading) private var isLoading
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    let backgroundColor: BackgroundInput
    let foregroundColor: Color
    
    public init(backgroundColor: BackgroundInput = Color.themePrimaryAction.gradient, foregroundColor: Color = Color.themeOnPrimaryAction) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            if isLoading {
                ProgressView()
                    .transition(.blurReplace)
                    .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
            }
            configuration.label
        }
        .frame(maxWidth: Constants.maxWidthForLargeDevices, minHeight: 50, idealHeight: 50, maxHeight: 55, alignment: .center)
        .font(.montserratSemiBold, 16)
        .background(backgroundColor)
        .multilineTextAlignment(.center)
        .opacity(isEnabled ? 1.0 : 0.5)
        .foregroundColor(foregroundColor)
        .animation(.default, value: isEnabled)
        .animation(.default, value: isLoading)
        .clipShape(Capsule(style: .continuous))
        .scaleEffect(configuration.isPressed ? 1.03 : 1)
        .animation(.linear(duration: 0.1), value: configuration.isPressed)
    }
}
