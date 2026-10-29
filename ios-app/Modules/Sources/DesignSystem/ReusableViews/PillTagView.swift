import SwiftUI

public struct PillTagView<Content: View>: View {
    public enum Style {
        case badge
        case compactBadge
        case metadata
    }

    private let style: Style
    private let foregroundColor: Color
    private let backgroundColor: Color
    private let content: Content

    public init(
        style: Style = .metadata,
        foregroundColor: Color = .themeTextSecondary,
        backgroundColor: Color = .themeBackground,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    public var body: some View {
        styledContent
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, style == .metadata ? 10 : style == .badge ? 8 : 6)
            .padding(.vertical, style == .metadata ? 6 : style == .badge ? 5 : 2)
            .background(backgroundColor, in: Capsule())
    }

    @ViewBuilder
    private var styledContent: some View {
        switch style {
        case .badge, .compactBadge:
            content.badgeTextStyle()
        case .metadata:
            content.captionTextStyle()
        }
    }
}

public extension PillTagView where Content == Text {
    init(
        _ text: String,
        style: Style = .metadata,
        foregroundColor: Color = .themeTextSecondary,
        backgroundColor: Color = .themeBackground
    ) {
        self.init(style: style, foregroundColor: foregroundColor, backgroundColor: backgroundColor) {
            Text(text)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        PillTagView("3 sessioner")
        PillTagView("2 nye", style: .badge, foregroundColor: .themeOnPrimaryAction, backgroundColor: .themeBlue)
        PillTagView {
            Label("Spørgsmål", systemImage: "questionmark.circle")
        }
    }
}
