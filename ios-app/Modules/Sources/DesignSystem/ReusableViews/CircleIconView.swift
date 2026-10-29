import SwiftUI

public struct CircleIconView: View {
    private let image: Image
    private let size: CGFloat
    private let padding: CGFloat
    private let foregroundColor: Color
    private let backgroundColor: Color

    public init(
        _ image: Image,
        size: CGFloat = 20,
        padding: CGFloat = 9,
        foregroundColor: Color = .themePrimaryAction,
        backgroundColor: Color = .themePrimaryAction.opacity(0.12)
    ) {
        self.image = image
        self.size = size
        self.padding = padding
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }

    public var body: some View {
        image
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(foregroundColor)
            .padding(padding)
            .background(backgroundColor, in: Circle())
    }
}
