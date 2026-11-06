import SwiftUI

#if canImport(MessageUI) && canImport(UIKit)
import MessageUI
import UIKit

public struct MailComposerView: UIViewControllerRepresentable {
    private let recipient: String
    private let subject: String
    private let message: String
    private let onComplete: (Bool) -> Void

    public init(recipient: String, subject: String, message: String, onComplete: @escaping (Bool) -> Void) {
        self.recipient = recipient
        self.subject = subject
        self.message = message
        self.onComplete = onComplete
    }

    public func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = context.coordinator
        controller.setToRecipients([recipient])
        controller.setSubject(subject)
        controller.setMessageBody(message, isHTML: false)
        return controller
    }

    public func updateUIViewController(_ controller: MFMailComposeViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator { Coordinator(onComplete: onComplete) }

    public final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        private let onComplete: (Bool) -> Void

        init(onComplete: @escaping (Bool) -> Void) { self.onComplete = onComplete }

        public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            onComplete(result == .failed || error != nil)
        }
    }
}
#else
public struct MailComposerView: View {
    private let recipient: String

    public init(recipient: String, subject: String, message: String, onComplete: @escaping (Bool) -> Void) {
        self.recipient = recipient
    }

    public var body: some View { Text(verbatim: recipient) }
}
#endif
