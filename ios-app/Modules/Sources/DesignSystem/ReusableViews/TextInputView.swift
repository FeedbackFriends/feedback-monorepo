import SwiftUI

public struct TextInputView: View {
    private let title: String
    private let prompt: String
    @Binding private var text: String
    @FocusState.Binding private var isFocused: Bool
    private let axis: Axis
    private let lineLimit: ClosedRange<Int>
    private let accessibilityLabel: String
    private let accessibilityIdentifier: String

    public init(
        title: String,
        prompt: String,
        text: Binding<String>,
        isFocused: FocusState<Bool>.Binding,
        axis: Axis = .horizontal,
        lineLimit: ClosedRange<Int> = 1...1,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String
    ) {
        self.title = title
        self.prompt = prompt
        self._text = text
        self._isFocused = isFocused
        self.axis = axis
        self.lineLimit = lineLimit
        self.accessibilityLabel = accessibilityLabel ?? title
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .rowTitleTextStyle()

            TextField(
                "",
                text: $text,
                prompt: Text(prompt).foregroundStyle(Color.themeTextSecondary),
                axis: axis
            )
            .textInputTextStyle()
            .textInputAutocapitalization(.sentences)
            .lineLimit(lineLimit)
            .focused($isFocused)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityIdentifier(accessibilityIdentifier)
        }
        .surfaceCard(padding: 15)
    }
}
