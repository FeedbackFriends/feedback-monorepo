#if DEBUG
import ComposableArchitecture
import Domain
import DesignSystem
import SwiftUI
import MoreFeature

/// Real app views with fixed data and no reducer effects, exclusively for preview capture.
private struct ScreenCatalogPreviewView: View {
    private let store: StoreOf<Tabbar>

    init(tab: Tab = .home, empty: Bool = false) {
        AppTheme.setUp()
        var state = Tabbar.State(bootstrap: PreviewCatalogFixtures.bootstrap(empty: empty), selectedTab: tab)
        state.managerEvents.referenceDate = PreviewCatalogFixtures.now
        state.activities.referenceDate = PreviewCatalogFixtures.now
        store = Store(initialState: state) { EmptyReducer() }
    }

    var body: some View {
        ScreenCatalogContainerView {
            TabbarView(store: store)
        }
    }
}

#Preview("home.populated") {
    ScreenCatalogPreviewView()
}

#Preview("home.empty") {
    ScreenCatalogPreviewView(empty: true)
}

#Preview("activities.populated") {
    ScreenCatalogPreviewView(tab: .activities)
}

#Preview("feedback-code.empty") {
    ScreenCatalogPreviewView(tab: .feedback)
}

#Preview("activities.empty") {
    ScreenCatalogPreviewView(tab: .activities, empty: true)
}

@MainActor
private func catalogTabbarState(role: Role? = .manager, tab: Tab = .home) -> Tabbar.State {
    var state = Tabbar.State(bootstrap: PreviewCatalogFixtures.bootstrap(role: role), selectedTab: tab)
    state.managerEvents.referenceDate = PreviewCatalogFixtures.now
    state.activities.referenceDate = PreviewCatalogFixtures.now
    return state
}

@MainActor
private func catalogProfile(role: Role?) -> some View {
    var state = catalogTabbarState(role: role)
    state.moreSection = .screenCatalog
    return ScreenCatalogContainerView {
        TabbarView(store: Store(initialState: state) { EmptyReducer() }).screenCatalogProfileSheet
    }
}

#Preview("profile.manager") {
    catalogProfile(role: .manager)
}

#Preview("profile.participant") {
    catalogProfile(role: .participant)
}

#Preview("profile.anonymous") {
    catalogProfile(role: nil)
}

#Preview("home.anonymous") {
    ScreenCatalogContainerView {
        TabbarView(store: Store(initialState: catalogTabbarState(role: nil)) { EmptyReducer() })
    }
}

#Preview("home.participant") {
    ScreenCatalogContainerView {
        TabbarView(store: Store(initialState: catalogTabbarState(role: .participant)) { EmptyReducer() })
    }
}

#Preview("feedback-code.anonymous") {
    ScreenCatalogContainerView {
        TabbarView(store: Store(initialState: catalogTabbarState(role: nil, tab: .feedback)) { EmptyReducer() })
    }
}

@MainActor
private func catalogBanner(serverError: Bool) -> some View {
    var state = catalogTabbarState()
    state.tabbarLifecyle.bannerState = serverError
        ? .serverError("Der opstod en serverfejl. Prøv igen om lidt.")
        : .offline("Du er offline. Tjek din internetforbindelse.")
    return ScreenCatalogContainerView {
        TabbarView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("home.offline") {
    catalogBanner(serverError: false)
}

#Preview("home.server-error") {
    catalogBanner(serverError: true)
}

#Preview("notifications.permission") {
    ScreenCatalogContainerView {
        NotificationPermissionView(requestAuthorizationButtonTap: {}, dismissButtonTap: {})
    }
}
#Preview("home.full-content", traits: .fixedLayout(width: 402, height: 1700)) {
    ScreenCatalogPreviewView()
}

#Preview("profile.full-content", traits: .fixedLayout(width: 402, height: 1400)) {
    catalogProfile(role: .manager)
}

#endif
