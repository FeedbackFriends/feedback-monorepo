import Domain
import SwiftUI

public struct DeleteConfirmationViewSheet<Response: Sendable>: View {
    public let title: String
    public let message: String
    public var successMessage: String
    public let confirmationAction: @Sendable () async throws -> Response
    public let onDismiss: () -> Void
    public let onSuccess: (Response) -> Void
    
    @Environment(\.dismiss) private var dismiss

    @State private var inFlight = false
    @State private var showSuccessOverlay = false
    @State private var presentableError: PresentableError?

    public init(
        title: String,
        message: String,
        successMessage: String = "Deleted",
        confirmationAction: @Sendable @escaping () async throws -> Response,
        onDismiss: @escaping () -> Void,
        onSuccess: @escaping (Response) -> Void
    ) {
        self.title = title
        self.message = message
        self.successMessage = successMessage
        self.confirmationAction = confirmationAction
        self.onDismiss = onDismiss
        self.onSuccess = onSuccess
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(message)
                        .font(.montserratRegular, 14)

                    VStack(alignment: .center, spacing: 12) {
                        Button("Delete") {
                            performAction()
                        }
                        .buttonStyle(LargeBoxButtonStyle(color: Color.themeVerySad))
                        .isLoading(inFlight)

                        Button("Cancel") {
                            dismiss()
                            onDismiss()
                        }
                        .buttonStyle(LargeBoxButtonStyle(style: .secondary))
                    }
                }
                .padding(.horizontal, 18)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.large)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView {
                        dismiss()
                        onDismiss()
                    }
                }
            }
        }
        .successOverlay(
            message: successMessage,
            show: $showSuccessOverlay,
            enableAutomaticDismissal: false
        )
        .alert(
            presentableError?.title ?? "",
            isPresented: Binding(
                get: { presentableError != nil },
                set: { if !$0 { presentableError = nil } }
            ),
            presenting: presentableError
        ) { _ in
            Button("Ok", role: .cancel) {}
        } message: { error in
            Text(error.message)
        }
    }

    private func performAction() {
        Task { @MainActor in
            inFlight = true
            do {
                let response = try await confirmationAction()
                inFlight = false
                showSuccessOverlay = true
                try await Task.sleep(for: .seconds(1.2))
                onSuccess(response)
            } catch {
                inFlight = false
                presentableError = error.localized
            }
        }
    }
}
