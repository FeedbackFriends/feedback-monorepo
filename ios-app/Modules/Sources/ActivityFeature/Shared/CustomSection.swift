import SwiftUI
import DesignSystem

struct CustomSection<Content: View>: View {
    let title: String
    let trailingContent: AnyView?
    let content: () -> Content

    init(
        title: String,
        trailingContent: AnyView? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.trailingContent = trailingContent
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                SectionHeaderView(title)

                Spacer(minLength: 8)

                if let trailingContent {
                    trailingContent
                        .padding(.trailing, 15)
                }
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 12) {
                content()
            }
        }
    }
}
