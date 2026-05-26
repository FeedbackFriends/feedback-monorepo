import SwiftUI
import DesignSystem

struct CustomSection<Content: View>: View {
    let title: String
    let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeaderView(title)
            VStack(alignment: .leading, spacing: 12) {
                content()
            }
        }
    }
}
