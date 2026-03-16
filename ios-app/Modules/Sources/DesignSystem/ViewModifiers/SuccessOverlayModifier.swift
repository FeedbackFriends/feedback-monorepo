import SwiftUI

public extension View {
    /// Success overlay animation shown before navigation
    /// - Parameter message: Message displayed on success overlay
    /// - Parameter delay: Delay time before navigationCallback is triggered, default value is 2.5 seconds
    /// - Parameter show: Decides when overlay should be shown
    /// - Parameter enableAutomaticDismissal: If automatic dismissal should be enabled after given delay
    func successOverlay(
        message: String,
        delay: Double = 1.8,
        show: Binding<Bool>,
        enableAutomaticDismissal: Bool = true
    ) -> some View {
        modifier(
            SuccessOverlayViewModifier(
                show: show,
                animationDelay: delay,
                message: message,
                enableAutomaticDismissal: enableAutomaticDismissal
            )
        )
    }
}

struct SuccessOverlayViewModifier: ViewModifier {
    
    @Binding var show: Bool
    let animationDelay: Double
    let message: String
    let enableAutomaticDismissal: Bool
    @Environment(\.dismiss) var dismiss
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if show {
                SuccessOverlayView(message: message)
                    .zIndex(999)
                    .onAppear {
                        Task { @MainActor in
                            if enableAutomaticDismissal {
                            try await Task.sleep(for: .seconds(animationDelay))
                                dismiss()
                            }
                        }
                    }
            }
        }
        .animation(.linear(duration: 0.5), value: show)
    }
}
