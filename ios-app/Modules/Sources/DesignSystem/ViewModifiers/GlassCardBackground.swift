import SwiftUI

public extension View {
    func glassCardBackground(cornerRadius: CGFloat = Theme.cornerRadius) -> some View {
        self.glassEffect(in: .rect(cornerRadius: cornerRadius))
    }
}
