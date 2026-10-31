import SwiftUI
import Accessibility

/// A brief, nonmodal confirmation. The owning feature controls its lifetime.
public struct SuccessMessageView: View {
    private let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var body: some View {
        surface
            .accessibilityElement(children: .combine)
            .onAppear {
                AccessibilityNotification.Announcement(message).post()
            }
    }

    @ViewBuilder
    private var surface: some View {
        if #available(iOS 26, macOS 26, *) {
            content.glassEffect(.regular, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        } else {
            content.background(.regularMaterial, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
    }

    private var content: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.themeSuccess)
                .accessibilityHidden(true)
            Text(message)
                .bodyTextStyle()
                .foregroundStyle(Color.themeText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}
