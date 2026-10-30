#if DEBUG
import Domain
import SwiftUI

extension EnvironmentValues {
    @Entry public var isScreenSnapshot = false
}

/// A single named screen and its deterministic snapshot canvas.
@MainActor
public struct ScreenSnapshotSample {
    public let id: String
    public let size: CGSize
    public let makeView: () -> AnyView

    public init<Content: View>(id: String, size: CGSize, @ViewBuilder makeView: @escaping () -> Content) {
        self.id = id
        self.size = size
        self.makeView = { AnyView(makeView()) }
    }
}

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
            .environment(\.isScreenSnapshot, true)
            .environment(\.referenceDate, PreviewCatalogFixtures.now)
            .environment(\.locale, Locale(identifier: "da_DK"))
            .environment(\.calendar, Calendar(identifier: .gregorian))
            .environment(\.timeZone, TimeZone(identifier: "Europe/Copenhagen")!)
            .environment(\.dynamicTypeSize, .large)
            .preferredColorScheme(.light)
            .transaction { $0.disablesAnimations = true }
    }
}
#endif
