import Domain
import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct ActivityListView: View {
    private let onProfileButtonTap: (() -> Void)?
    @Bindable var store: StoreOf<ActivityList>

    public init(
        store: StoreOf<ActivityList>,
        onProfileButtonTap: (() -> Void)? = nil
    ) {
        self.store = store
        self.onProfileButtonTap = onProfileButtonTap
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            Group {
                switch store.presentation {
                case .overview:
                    TimelineView(.periodic(from: .now, by: 60)) { context in
                        ScrollView {
                            HomeOverviewView(store: store, now: context.date)
                                .padding()
                        }
                    }
                case .activities:
                    HomeActivitiesView(store: store)
                }
            }
            .background(LetsGrowLandingGradient().ignoresSafeArea())
            .navigationTitle(store.presentation == .overview ? "Overblik" : "Aktiviteter")
            .refreshable { await store.send(.refresh).finish() }
            .toolbar {
                if let onProfileButtonTap {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Profil", systemImage: "person.crop.circle", action: onProfileButtonTap)
                            .accessibilityIdentifier("profile_button")
                    }
                }
                if store.presentation == .activities {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Opret aktivitet", systemImage: "plus") { store.send(.createActivityButtonTap) }
                            .accessibilityIdentifier("my_activity_add_button")
                    }
                }
            }
            .sheet(item: $store.scope(state: \.destination?.manageActivity, action: \.destination.manageActivity)) { activityStore in
                ManageActivityView(store: activityStore)
            }
            .sheet(item: $store.scope(state: \.destination?.quickLook, action: \.destination.quickLook)) { detailStore in
                NavigationStack {
                    ActivityDetailView(store: detailStore)
                }
                .environment(\.dismissActivitySheet, { store.send(.destination(.dismiss)) })
                .presentationDetents([.large])
            }
        } destination: { pathStore in
            switch pathStore.case {
            case .unreadFeedback:
                HomeUnreadFeedbackView(store: store)
            case .activityDetail(let detailStore):
                ActivityDetailView(store: detailStore)
            case .eventDetail(let detailStore):
                EventDetailFeatureView(store: detailStore)
            }
        }
    }
}

private struct HomeActivitiesView: View {
    let store: StoreOf<ActivityList>

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if store.activities.isEmpty {
                    Text("Du har ingen aktiviteter endnu.").supportingTextStyle()
                }
                ForEach(store.activities) { activity in
                    ActivityRowButton(activity: activity) { store.send(.activityTap(activity)) }
                }
            }
            .padding()
        }
        .background(LetsGrowLandingGradient().ignoresSafeArea())
    }
}

private struct HomeUnreadFeedbackView: View {
    let store: StoreOf<ActivityList>

    var body: some View {
        let overview = HomeOverview(activities: store.activities, now: .now)
        ScrollView {
            LazyVStack(spacing: 12) {
                if overview.unreadSessions.isEmpty {
                    ContentUnavailableView("Du har læst al feedback", systemImage: "checkmark.circle")
                }
                ForEach(overview.unreadSessions) { session in
                    HomeSessionCardView(session: session, isUpcoming: false) {
                        store.send(.eventTap(activityId: session.activity.id, eventId: session.event.id))
                    }
                }
            }
            .padding()
        }
        .background(LetsGrowLandingGradient().ignoresSafeArea())
        .navigationTitle("Ny feedback")
    }
}

#Preview("Overblik") {
    ActivityListView(store: .init(initialState: .init(bootstrap: .init(value: .mock()), presentation: .overview), reducer: { ActivityList() }))
}
