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
            CircleIconView(
                feedbackType.image,
                size: 16,
                padding: 8,
                foregroundColor: .themeTextSecondary,
                backgroundColor: .themeBackground
            )
                .frame(width: 34, height: 34)
                .accessibilityLabel(feedbackType.title)

        case .label:
            PillTagView {
                labelContent.lineLimit(1)
            }
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
