import SwiftUI

public struct PillTagView: View {
    let text: String
    let foregroundColor: Color

    public init(_ text: String, foregroundColor: Color = Color.themeText) {
        self.text = text
        self.foregroundColor = foregroundColor
    }

    public var body: some View {
        Text(text)
            .badgeTextStyle()
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.themeBackground)
            .clipShape(Capsule())
    }
}
