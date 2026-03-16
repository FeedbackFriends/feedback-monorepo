import SwiftUI
import DesignSystem
import Domain

@main
struct FeedbackErrorApp: App {
    var body: some Scene {
        WindowGroup {
            ErrorViewWrapper()
        }
    }
}

struct ErrorViewWrapper: View {
    @State var isLoading = false
    var body: some View {
        ErrorView(
            error: PresentableError(
                title: "Title",
                message: "Message"
            ),
            isLoading: $isLoading,
            tryAgainButtonTapped: {
                Task { @MainActor in
                    self.isLoading = true
                    try await Task.sleep(for: .seconds(1))
                    self.isLoading = false
                }
            }
        )
    }
}
