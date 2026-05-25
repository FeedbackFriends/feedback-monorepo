import Domain
import ComposableArchitecture
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
            .navigationTitle("My focus")
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
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text("What do you want feedback on?")
                        .font(.headline)

                    Text("Create an activity and collect feedback after each session.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No activities yet",
            systemImage: "calendar.badge.plus",
            description: Text("Create your first activity to start gathering feedback.")
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
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 10) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text(activity.date, format: .dateTime.day().month(.abbreviated).year())
                }
                .font(.subheadline)

                if let location = activity.location, !location.isEmpty {
                    Text("•")
                        .foregroundStyle(.secondary)

                    Label(location, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .lineLimit(1)
                }
            }
            .foregroundStyle(.secondary)

            if let summary = activity.overallFeedbackSummary {
                Text("\(summary.responses) responses")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            } else {
                Text("No feedback yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
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
            return .green
        case .stable:
            return .orange
        case .declining:
            return .red
        case .insufficientData:
            return .gray
        }
    }
}

//#Preview {
//    ActivityListView(
//        session: .mock(),
//        store: .init(
//            initialState: .init(bootstrap: .init(value: .mock()), activities: []),
//            reducer: { ActivityList() }
//        )
//    )
//}
