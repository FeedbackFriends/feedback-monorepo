import DesignSystem
import Domain
import SwiftUI

struct FeedbackTypeTagView: View {
    enum Style {
        case iconOnly
        case label
    }

    let feedbackType: FeedbackType
    let style: Style

    init(
        _ feedbackType: FeedbackType,
        style: Style = .label
    ) {
        self.feedbackType = feedbackType
        self.style = style
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
                HStack(spacing: 6) {
                    feedbackType.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .captionTextStyle()
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.themeText)
                        .frame(minWidth: 16)
                        .accessibilityHidden(true)
                    Text(feedbackType.title)
                        .fixedSize(horizontal: true, vertical: true)
                }
            }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(feedbackType.title)
        }
    }
}
