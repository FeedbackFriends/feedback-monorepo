import SwiftUI

public extension View {
    func sectionHeaderStyle() -> some View {
        modifier(SectionTextStyleModifier())
    }
}

struct SectionTextStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.montserratMedium, 13)
            .foregroundColor(Color.themeTextSecondary)
    }
}
