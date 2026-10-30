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
            HomeActivitiesView(store: store)
                .background(LetsGrowLandingGradient().ignoresSafeArea())
                .navigationTitle("Aktiviteter")
                .refreshable { await store.send(.refresh).finish() }
                .toolbar {
                    if let onProfileButtonTap {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Profil", systemImage: "person.crop.circle", action: onProfileButtonTap)
                                .accessibilityIdentifier("profile_button")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Opret aktivitet", systemImage: "plus") { store.send(.createActivityButtonTap) }
                            .accessibilityIdentifier("my_activity_add_button")
                    }
                }
                .sheet(item: $store.scope(state: \.destination?.manageActivity, action: \.destination.manageActivity)) { activityStore in
                    ManageActivityView(store: activityStore)
                }
        } destination: { pathStore in
            switch pathStore.case {
            case .activityDetail(let detailStore):
                ActivityDetailView(store: detailStore)
            case .eventDetail(let detailStore):
                EventDetailFeatureView(store: detailStore)
            }
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
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
                    ActivityRowButton(activity: activity, now: store.referenceDate ?? .now) { store.send(.activityTap(activity)) }
                }
            }
            .padding()
        }
        .background(LetsGrowLandingGradient().ignoresSafeArea())
    }
}

#Preview("Aktiviteter") {
    ActivityListView(store: .init(initialState: .init(bootstrap: .init(value: .mock())), reducer: { ActivityList() }))
}
