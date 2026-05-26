import SwiftUI

public struct SectionHeaderView: View {
    private let title: String
    private let horizontalPadding: CGFloat

    public init(
        _ title: String,
        horizontalPadding: CGFloat = 15
    ) {
        self.title = title
        self.horizontalPadding = horizontalPadding
    }

    public var body: some View {
        Text(title.uppercased())
            .sectionHeaderStyle()
            .padding(.horizontal, horizontalPadding)
    }
}
