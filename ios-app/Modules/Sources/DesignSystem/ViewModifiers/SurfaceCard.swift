import SwiftUI

public extension View {
    /// Standard surface for cards. The caller owns content, actions, and accessibility.
    func surfaceCard(padding: CGFloat = Theme.padding) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.themeSurface, in: .rect(cornerRadius: Theme.cornerRadius))
            .clipShape(.rect(cornerRadius: Theme.cornerRadius))
            .contentShape(.rect(cornerRadius: Theme.cornerRadius))
    }
}
