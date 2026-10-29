import SwiftUI

public struct DeleteConfirmationViewSheet<ActionButton: View>: View {
    public let title: String
    public let message: String
    public let actionButton: ActionButton
    @Environment(\.dismiss) private var dismiss

    public init(
        title: String,
        message: String,
        @ViewBuilder actionButton: () -> ActionButton
    ) {
        self.title = title
        self.message = message
        self.actionButton = actionButton()
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)
                Text(message)
                    .bodyTextStyle()
                actionButton
                Button("Annuller") {
                    dismiss()
                }
                .buttonStyle(LargeBoxButtonStyle(style: .secondary))
            }
            .foregroundStyle(Color.themeText)
            .padding(24)
        }
        .presentationBackground(Color.themeBackground)
    }
}
