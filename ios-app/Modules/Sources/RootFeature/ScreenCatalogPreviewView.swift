#if DEBUG
import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

private func catalogStartupError(retrying: Bool = false) -> RootFeature.State {
    RootFeature.State(destination: .error(.getSessionError(error: PreviewCatalogFixtures.error)), isLoading: retrying)
}

@MainActor
private func catalogStartupLoading() -> some View {
    ScreenCatalogContainerView {
        RootFeatureView(store: Store(initialState: RootFeature.State()) { EmptyReducer() })
    }
}

#Preview("startup.loading") {
    catalogStartupLoading()
}

@MainActor
private func catalogStartupError() -> some View {
    ScreenCatalogContainerView {
        RootFeatureView(store: Store(initialState: catalogStartupError()) { EmptyReducer() })
    }
}

#Preview("startup.error") {
    catalogStartupError()
}

@MainActor
private func catalogStartupRetrying() -> some View {
    ScreenCatalogContainerView {
        RootFeatureView(store: Store(initialState: catalogStartupError(retrying: true)) { EmptyReducer() })
    }
}

#Preview("startup.retrying") {
    catalogStartupRetrying()
}
#endif
