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
                .successConfirmation(store.scope(state: \.confirmation, action: \.confirmation))
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
                .sheet(
                    item: $store.scope(state: \.destination?.manageActivity, action: \.destination.manageActivity),
                    onDismiss: { store.send(.activityEditorDismissed) },
                    content: { activityStore in
                        ManageActivityView(store: activityStore)
                    }
                )
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
        GeometryReader { geometry in
            ScrollView {
                if store.activities.isEmpty {
                    emptyState
                        .frame(minHeight: geometry.size.height)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(store.activities) { activity in
                            ActivityRowButton(activity: activity, now: store.referenceDate ?? .now) { store.send(.activityTap(activity)) }
                        }
                    }
                    .padding()
                }
            }
            .background(LetsGrowLandingGradient().ignoresSafeArea())
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label {
                Text("Opret din første aktivitet")
                    .titleTextStyle()
                    .foregroundStyle(Color.themeText)
            } icon: {
                Image(systemName: "calendar.badge.plus")
                    .foregroundStyle(Color.themePrimaryAction)
            }
        } description: {
            VStack(spacing: 12) {
                Text("Tryk på + øverst til højre for at komme i gang.")
            }
            .supportingTextStyle()
            .foregroundStyle(Color.themeTextSecondary)
        }
    }
}

#Preview("Aktiviteter") {
    ActivityListView(store: .init(initialState: .init(bootstrap: .init(value: .mock())), reducer: { ActivityList() }))
}
