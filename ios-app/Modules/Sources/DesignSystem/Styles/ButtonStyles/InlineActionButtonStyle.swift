import SwiftUI

public struct InlineActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.montserratRegular, 13)
            .foregroundStyle(Color.themePrimaryAction)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
            .opacity(isEnabled ? (configuration.isPressed ? 0.4 : 1) : 0.5)
    }
}
