import SwiftUI

public struct ScalingButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration
            .label
            .scaleEffect(configuration.isPressed ? 1.03 : 1)
            .animation(.linear(duration: 0.1), value: configuration.isPressed)
    }
}
