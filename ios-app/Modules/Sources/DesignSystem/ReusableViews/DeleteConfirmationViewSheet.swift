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
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(message)
                        .bodyTextStyle()
                    actionButton
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(LargeBoxButtonStyle(style: .secondary))
                }
                .padding(.horizontal, 18)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.large)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView {
                        dismiss()
                    }
                }
            }
        }
    }
}
