import DesignSystem
import Domain
import SwiftUI

struct FeedbackTypeTagView: View {
    enum Style {
        case iconOnly
        case label
    }

    enum Orientation {
        case horizontal
        case vertical
    }

    let feedbackType: FeedbackType
    let style: Style
    let orientation: Orientation

    init(
        _ feedbackType: FeedbackType,
        style: Style = .label,
        orientation: Orientation = .horizontal
    ) {
        self.feedbackType = feedbackType
        self.style = style
        self.orientation = orientation
    }

    var body: some View {
        switch style {
        case .iconOnly:
            feedbackType.image
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .padding(8)
                .frame(width: 34, height: 34)
                .foregroundStyle(Color.themeTextSecondary)
                .background(Color.themeBackground, in: Circle())
                .accessibilityLabel(feedbackType.title)

        case .label:
            labelContent
                .captionTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.themeBackground, in: Capsule())
                .accessibilityLabel(feedbackType.title)
        }
    }

    @ViewBuilder
    private var labelContent: some View {
        switch orientation {
        case .horizontal:
            Label {
                Text(feedbackType.title)
            } icon: {
                icon
            }

        case .vertical:
            VStack(spacing: 4) {
                icon
                Text(feedbackType.title)
            }
        }
    }

    private var icon: some View {
        feedbackType.image
            .resizable()
            .scaledToFit()
            .frame(width: 12, height: 12)
    }
}
