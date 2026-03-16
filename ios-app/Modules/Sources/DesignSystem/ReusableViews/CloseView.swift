import SwiftUI

public struct CloseButtonView: View {
    
    let dismiss: () -> Void
    
    public init(dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
    }
    public var body: some View {
        Button(role: .close) {
            dismiss()
        }
        .tint(Color.themeText)
    }
}
