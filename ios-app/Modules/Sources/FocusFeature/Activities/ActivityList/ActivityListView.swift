import Domain
import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct ActivityListView: View {
    
    @Bindable var store: StoreOf<ActivityList>

    public init(
        store: StoreOf<ActivityList>
    ) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    createCTA
                        .accessibilityIdentifier("my_activity_create_cta")
                    if store.activities.isEmpty {
                        emptyState
                    } else {
                        ForEach(store.activities) { activity in
                            ActivityRowButton(activity: activity) {
                                store.send(.activityTap(activity))
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.themeBackground.ignoresSafeArea())
            .navigationTitle("Recurring meetings")
            .navigationDestination(
                item: $store.scope(
                    state: \.destination?.activityDetail,
                    action: \.destination.activityDetail
                )
            ) { store in
                ActivityDetailView(store: store)
            }
            .sheet(
                item: $store.scope(
                    state: \.destination?.manageActivity,
                    action: \.destination.manageActivity
                )
            ) { store in
                NavigationStack {
                    ManageActivityView(store: store)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.store.send(.createActivityButtonTap)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("my_activity_add_button")
                }
            }
        }
    }

    private var createCTA: some View {
        Button {
            self.store.send(.createActivityButtonTap)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .titleTextStyle()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Add recurring meeting")
                        .rowTitleTextStyle()

                    Text("Invite feedback@letsgrow.dk to your calendar event and track meeting feedback over time.")
                        .supportingTextStyle()
                        .foregroundStyle(Color.themeTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.themeTextSecondary.opacity(0.7))
            }
            .padding()
            .background(Color.themeSurface, in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No recurring meetings yet",
            systemImage: "calendar.badge.plus",
            description: Text("Add your first recurring meeting to start gathering feedback.")
        )
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

private struct ActivityCardView: View {
    let activity: Activity

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(activity.title)
                    .rowTitleTextStyle()
                Spacer()
            }

            Text("\(activity.events.count) sessions")
                .supportingTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.themeSurface)
        )
    }
}

private struct ActivityRowButton: View {
    let activity: Activity
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ActivityCardView(activity: activity)
        }
        .buttonStyle(.plain)
    }
}

private extension ActivityTrend.Direction {
    var title: String {
        switch self {
        case .improving:
            return "Improving"
        case .stable:
            return "Stable"
        case .declining:
            return "Declining"
        case .insufficientData:
            return "Insufficient data"
        }
    }

    var symbolName: String {
        switch self {
        case .improving:
            return "arrow.up.right"
        case .stable:
            return "arrow.right"
        case .declining:
            return "arrow.down.right"
        case .insufficientData:
            return "questionmark"
        }
    }

    var color: Color {
        switch self {
        case .improving:
            return Color.themeSuccess
        case .stable:
            return Color.themeNeutral
        case .declining:
            return Color.themeVerySad
        case .insufficientData:
            return Color.themeNeutral
        }
    }
}

// #Preview {
//     ActivityListView(
//         session: .mock(),
//         store: .init(
//             initialState: .init(bootstrap: .init(value: .mock()), activities: []),
//             reducer: { ActivityList() }
//         )
//     )
// }
