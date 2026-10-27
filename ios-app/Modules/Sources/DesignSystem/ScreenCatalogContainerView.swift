#if DEBUG
import Domain
import SwiftUI

/// Shared rendering environment for catalog-only previews, never an app route.
public struct ScreenCatalogContainerView<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        AppTheme.setUp()
        self.content = content()
    }

    public var body: some View {
        content
            .tint(Color.themePrimaryAction)
            .environment(\.locale, Locale(identifier: "da_DK"))
            .environment(\.calendar, Calendar(identifier: .gregorian))
            .environment(\.timeZone, TimeZone(identifier: "Europe/Copenhagen")!)
            .environment(\.dynamicTypeSize, .large)
            .preferredColorScheme(.light)
            .transaction { $0.disablesAnimations = true }
    }
}
#endif
