import SwiftUI
import DesignSystem

struct CustomSection<Content: View>: View {
    let title: String
    let content: () -> Content
    var body: some View {
        Section {
            content()
        } header: {
            Text(title)
                .sectionHeaderStyle()
                .padding(.horizontal, Theme.padding)
        }
    }
}
