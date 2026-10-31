import SwiftUI

public extension View {
    /// Shows a confirmation at the top without moving or blocking the content.
    /// Features own the timer and any navigation after success.
    func successMessage(_ message: String, isPresented: Bool) -> some View {
        overlay(alignment: .top) {
            if isPresented {
                SuccessMessageView(message)
                    .frame(maxWidth: Constants.maxWidthForLargeDevices)
                    .padding(.horizontal, Theme.padding)
                    .padding(.top, 12)
                    .allowsHitTesting(false)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented)
        .sensoryFeedback(.success, trigger: isPresented)
    }
}
