import Domain
import Localization
import SwiftUI

/// The same value/action control is used for meeting feedback and product contact.
public struct EmojiRatingView: View {
    private let selected: Emoji?
    private let onSelect: (Emoji) -> Void

    public init(selected: Emoji?, onSelect: @escaping (Emoji) -> Void) {
        self.selected = selected
        self.onSelect = onSelect
    }

    public var body: some View {
        HStack {
            face(.verySad, image: .verySad, label: String(appStrings: .feedbackEmojiVerySad))
            face(.sad, image: .sad, label: String(appStrings: .feedbackEmojiSad))
            face(.happy, image: .happy, label: String(appStrings: .feedbackEmojiHappy))
            face(.veryHappy, image: .veryHappy, label: String(appStrings: .feedbackEmojiVeryHappy))
        }
    }

    private func face(_ value: Emoji, image: Image, label: String) -> some View {
        Button { onSelect(value) } label: {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .grayscale(selected == value ? 0 : 1)
                .padding(selected == value ? 10 : 13)
                .opacity(selected == value ? 1 : 0.6)
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(selected == value ? .isSelected : [])
        .accessibilityIdentifier("feedback_emoji_\(value.rawValue)")
    }
}
