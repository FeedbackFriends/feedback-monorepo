import SwiftUI

public extension View {
    /// Use for prominent screen or display titles.
    func largeTitleTextStyle() -> some View {
        modifier(TextStyleModifier(style: .largeTitle))
    }

    /// Use for modal, card, overlay, and empty-state titles.
    func titleTextStyle() -> some View {
        modifier(TextStyleModifier(style: .title))
    }

    /// Use for list rows, settings rows, selectable options, and compact headings.
    func rowTitleTextStyle() -> some View {
        modifier(TextStyleModifier(style: .rowTitle))
    }

    /// Use for normal readable body copy.
    func bodyTextStyle() -> some View {
        modifier(TextStyleModifier(style: .body))
    }

    /// Use for secondary, help, or explanatory copy.
    func supportingTextStyle() -> some View {
        modifier(TextStyleModifier(style: .supporting))
    }

    /// Use for metadata, dates, small labels, and counters.
    func captionTextStyle() -> some View {
        modifier(TextStyleModifier(style: .caption))
    }

    /// Use for badge and pill text.
    func badgeTextStyle() -> some View {
        modifier(TextStyleModifier(style: .badge))
    }

    /// Use for section headers.
    func sectionHeaderStyle() -> some View {
        modifier(TextStyleModifier(style: .sectionHeader))
    }
}

private struct TextStyleModifier: ViewModifier {
    let style: TextStyle

    func body(content: Content) -> some View {
        let definition = style.definition

        content
            .font(definition.fontName, definition.size)
            .foregroundStyle(definition.color)
    }
}

private enum TextStyle {
    case largeTitle
    case title
    case rowTitle
    case body
    case supporting
    case caption
    case badge
    case sectionHeader

    var definition: TextStyleDefinition {
        switch self {
        case .largeTitle:
            TextStyleDefinition(
                fontName: .montserratBold,
                size: 28,
                color: Color.themeText
            )
        case .title:
            TextStyleDefinition(
                fontName: .montserratExtraBold,
                size: 18,
                color: Color.themeText
            )
        case .rowTitle:
            TextStyleDefinition(
                fontName: .montserratSemiBold,
                size: 15,
                color: Color.themeText
            )
        case .body:
            TextStyleDefinition(
                fontName: .montserratRegular,
                size: 14,
                color: Color.themeText
            )
        case .supporting:
            TextStyleDefinition(
                fontName: .montserratRegular,
                size: 13,
                color: Color.themeTextSecondary
            )
        case .caption:
            TextStyleDefinition(
                fontName: .montserratMedium,
                size: 12,
                color: Color.themeTextSecondary
            )
        case .badge:
            TextStyleDefinition(
                fontName: .montserratBold,
                size: 10,
                color: Color.themeOnPrimaryAction
            )
        case .sectionHeader:
            TextStyleDefinition(
                fontName: .montserratMedium,
                size: 13,
                color: Color.themeTextSecondary
            )
        }
    }
}

private struct TextStyleDefinition {
    let fontName: Font.FontName
    let size: CGFloat
    let color: Color
}
