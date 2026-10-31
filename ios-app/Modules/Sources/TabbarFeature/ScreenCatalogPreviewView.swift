#if DEBUG
import ComposableArchitecture
import Domain
import DesignSystem
import SwiftUI
import MoreFeature
import ActivityFeature
import EnterCodeFeature

/// Real app views with fixed data and no reducer effects, exclusively for preview capture.
private struct ScreenCatalogPreviewView: View {
    private let store: StoreOf<Tabbar>

    init(tab: Tab = .activities, empty: Bool = false, deletionSuccess: Bool = false) {
        AppTheme.setUp()
        var state = Tabbar.State(bootstrap: PreviewCatalogFixtures.bootstrap(empty: empty), selectedTab: tab)
        state.activities.referenceDate = PreviewCatalogFixtures.now
        if deletionSuccess {
            state.activities = .screenCatalogDeletionSuccess(bootstrap: state.$bootstrap)
        }
        store = Store(initialState: state) { EmptyReducer() }
    }

    var body: some View {
        ScreenCatalogContainerView {
            TabbarView(store: store)
        }
    }
}

// Screenshot: Main screen.
#Preview("activities.populated") {
    ScreenCatalogPreviewView(tab: .activities)
}

#Preview("feedback-code.empty") {
    ScreenCatalogPreviewView(tab: .feedback)
}

// Screenshot: Distinct empty layout.
#Preview("activities.empty") {
    ScreenCatalogPreviewView(tab: .activities, empty: true)
}

// Screenshot: Deletion returns to the empty list with a brief confirmation.
#Preview("activities.deleted") {
    ScreenCatalogPreviewView(tab: .activities, empty: true, deletionSuccess: true)
}

@MainActor
private func catalogTabbarState(role: Role? = .manager, tab: Tab = .activities) -> Tabbar.State {
    var state = Tabbar.State(bootstrap: PreviewCatalogFixtures.bootstrap(role: role), selectedTab: tab)
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


// Screenshot: Distinct role or content layout.
#Preview("profile.anonymous") {
    catalogProfile(role: nil)
}

// Screenshot: Distinct role or content layout.
#Preview("activities.anonymous") {
    ScreenCatalogContainerView {
        TabbarView(store: Store(initialState: catalogTabbarState(role: nil, tab: .activities)) { EmptyReducer() })
    }
}


// Screenshot: Distinct role or content layout.
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

#Preview("activities.offline") {
    catalogBanner(serverError: false)
}

#Preview("activities.server-error") {
    catalogBanner(serverError: true)
}

@MainActor
func catalogNotificationPermission() -> some View {
    ScreenCatalogContainerView {
        TabbarView(store: Store(initialState: catalogTabbarState()) { EmptyReducer() })
            .sheet(isPresented: .constant(true)) {
                NotificationPermissionView(requestAuthorizationButtonTap: {}, dismissButtonTap: {})
                    .presentationDetents([.height(600)])
            }
    }
}

// Screenshot: Distinct screen or presentation.
#Preview("notifications.permission") {
    catalogNotificationPermission()
}
@MainActor
private func catalogJoinSessionSheet(success: Bool = false) -> some View {
    var state = catalogTabbarState(role: nil, tab: .feedback)
    state.destination = .joinEvent(success ? .screenCatalogSuccess : .init(pinCodeInput: .init(value: "1234")))
    return ScreenCatalogContainerView {
        TabbarView(store: Store(initialState: state) {
            Reduce<Tabbar.State, Tabbar.Action> { state, action in
                if case .destination(.dismiss) = action {
                    state.destination = nil
                }
                return .none
            }
        })
    }
}

// Screenshot: Actual join-session sheet presentation.
#Preview("join-session.ready") {
    catalogJoinSessionSheet()
}

// Screenshot: Success overlay within the join-session sheet.
#Preview("join-session.success") {
    catalogJoinSessionSheet(success: true)
}

// Capture routed screens through the same tab container and navigation stacks as the app.
@MainActor
private func catalogRoutedScreen(
    tab: Tab = .activities,
    activity: Activity = PreviewCatalogFixtures.activity,
    configure: (inout Tabbar.State) -> Void = { _ in }
) -> some View {
    var state = Tabbar.State(bootstrap: PreviewCatalogFixtures.bootstrap(activity: activity), selectedTab: tab)
    state.activities.referenceDate = PreviewCatalogFixtures.now
    configure(&state)
    return ScreenCatalogContainerView {
        TabbarView(store: Store(initialState: state) {
            Reduce<Tabbar.State, Tabbar.Action> { state, action in
                if case .activities(.destination(.dismiss)) = action {
                    state.activities.destination = nil
                }
                return .none
            }
        })
    }
}

// Screenshot: Feedback entry in the real feedback tab, including the profile toolbar.
#Preview("feedback-code.ready") {
    catalogRoutedScreen(tab: .feedback) { state in
        state.enterCode = .init(pinCodeInput: .init(value: "1234"), startFeedbackPincodeInFlight: false)
    }
}

// Screenshot: Activity refresh failure retains results and offers retry.
#Preview("activities.refresh-error") {
    catalogRoutedScreen { state in
        state.activities = .screenCatalogRefreshError
    }
}

// Screenshot: Activity pushed from the activities tab.
#Preview("activity-detail.populated") {
    catalogRoutedScreen(tab: .activities) { state in
        state.activities.path.append(.activityDetail(.init(
            activityId: PreviewCatalogFixtures.activity.id, bootstrap: state.$bootstrap
        )))
    }
}

// Screenshot: Empty activity pushed from the activities tab.
#Preview("activity-detail.no-sessions") {
    catalogRoutedScreen(tab: .activities, activity: PreviewCatalogFixtures.emptyActivity) { state in
        state.activities.path.append(.activityDetail(.init(
            activityId: PreviewCatalogFixtures.emptyActivity.id, bootstrap: state.$bootstrap
        )))
    }
}

@MainActor
private func catalogRoutedSession(event: Event) -> some View {
    var activity = PreviewCatalogFixtures.activity
    activity.events = [event]
    return catalogRoutedScreen(tab: .activities, activity: activity) { state in
        state.activities.path.append(.eventDetail(.init(
            activityId: activity.id, eventId: event.id, bootstrap: state.$bootstrap,
            webBaseUrl: URL(string: "https://letsgrow.dk")
        )))
    }
}

// Screenshot: Upcoming session pushed from the activities tab.
#Preview("session-detail.no-feedback") {
    catalogRoutedSession(event: PreviewCatalogFixtures.upcomingEvent)
}

// BEGIN GENERATED SNAPSHOT CATALOG
// Generated by scripts/screen-catalog.py --generate. Do not edit this section.
@MainActor
enum TabbarFeatureScreenSnapshotCatalog {
    static var samples: [ScreenSnapshotSample] {
        [
            .init(id: "activities.populated", size: CGSize(width: 402, height: 874)) {
                ScreenCatalogPreviewView(tab: .activities)
            },
            .init(id: "activities.empty", size: CGSize(width: 402, height: 874)) {
                ScreenCatalogPreviewView(tab: .activities, empty: true)
            },
            .init(id: "activities.deleted", size: CGSize(width: 402, height: 874)) {
                ScreenCatalogPreviewView(tab: .activities, empty: true, deletionSuccess: true)
            },
            .init(id: "profile.anonymous", size: CGSize(width: 402, height: 874)) {
                catalogProfile(role: nil)
            },
            .init(id: "activities.anonymous", size: CGSize(width: 402, height: 874)) {
                ScreenCatalogContainerView {
                    TabbarView(store: Store(initialState: catalogTabbarState(role: nil, tab: .activities)) { EmptyReducer() })
                }
            },
            .init(id: "feedback-code.anonymous", size: CGSize(width: 402, height: 874)) {
                ScreenCatalogContainerView {
                    TabbarView(store: Store(initialState: catalogTabbarState(role: nil, tab: .feedback)) { EmptyReducer() })
                }
            },
            .init(id: "notifications.permission", size: CGSize(width: 402, height: 874)) {
                catalogNotificationPermission()
            },
            .init(id: "join-session.ready", size: CGSize(width: 402, height: 874)) {
                catalogJoinSessionSheet()
            },
            .init(id: "join-session.success", size: CGSize(width: 402, height: 874)) {
                catalogJoinSessionSheet(success: true)
            },
            .init(id: "feedback-code.ready", size: CGSize(width: 402, height: 874)) {
                catalogRoutedScreen(tab: .feedback) { state in
                    state.enterCode = .init(pinCodeInput: .init(value: "1234"), startFeedbackPincodeInFlight: false)
                }
            },
            .init(id: "activities.refresh-error", size: CGSize(width: 402, height: 874)) {
                catalogRoutedScreen { state in
                    state.activities = .screenCatalogRefreshError
                }
            },
            .init(id: "activity-detail.populated", size: CGSize(width: 402, height: 874)) {
                catalogRoutedScreen(tab: .activities) { state in
                    state.activities.path.append(.activityDetail(.init(
                        activityId: PreviewCatalogFixtures.activity.id, bootstrap: state.$bootstrap
                    )))
                }
            },
            .init(id: "activity-detail.no-sessions", size: CGSize(width: 402, height: 874)) {
                catalogRoutedScreen(tab: .activities, activity: PreviewCatalogFixtures.emptyActivity) { state in
                    state.activities.path.append(.activityDetail(.init(
                        activityId: PreviewCatalogFixtures.emptyActivity.id, bootstrap: state.$bootstrap
                    )))
                }
            },
            .init(id: "session-detail.no-feedback", size: CGSize(width: 402, height: 874)) {
                catalogRoutedSession(event: PreviewCatalogFixtures.upcomingEvent)
            }
        ]
    }
}
// END GENERATED SNAPSHOT CATALOG
#endif
