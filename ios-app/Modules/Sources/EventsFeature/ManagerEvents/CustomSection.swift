import SwiftUI

struct CustomSection<Content: View>: View {
    let title: String
    let content: () -> Content
    var body: some View {
        Section {
            content()
        } header: {
            Text(title)
                .font(.montserratSemiBold, 14)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .glassEffect()
                .clipShape(Capsule())
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
