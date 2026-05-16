import Domain
import ComposableArchitecture
import SwiftUI

public struct MyActivitiesView: View {
    let session: Bootstrap
    let onCreateActivityTap: () -> Void
    @Bindable var managerEventsStore: StoreOf<ActivitiesFeature>

    public init(
        session: Bootstrap,
        onCreateActivityTap: @escaping () -> Void,
        managerEventsStore: StoreOf<ActivitiesFeature>
    ) {
        self.session = session
        self.onCreateActivityTap = onCreateActivityTap
        self.managerEventsStore = managerEventsStore
    }

    private var activities: [Activity] {
        guard let managerData = session.managerData else {
            return []
        }

        return managerData.activities.sorted { lhs, rhs in
            lhs.date > rhs.date
        }
    }

    public var body: some View {
        let eventDetailStore = $managerEventsStore.scope(
            state: \.destination?.eventDetail,
            action: \.destination.eventDetail
        )
        let createEventStore = $managerEventsStore.scope(
            state: \.destination?.createEvent,
            action: \.destination.createEvent
        )
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    createCTA
                        .accessibilityIdentifier("my_activity_create_cta")

                    if activities.isEmpty {
                        emptyState
                    } else {
                        ForEach(activities) { activity in
                            NavigationLink(value: activity.id) {
                                FocusCardView(activity: activity)
                            }
                            .accessibilityIdentifier("activity_row_\(activity.title)")
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("My Activities")
//            .navigationDestination(for: UUID.self) { activityId in
//                if let activity = activities.first(where: { $0.id == activityId }) {
//                    FocusDetailView(
//                        activity: activity,
//                        onCreateSessionTap: {
//                            managerEventsStore.send(.activityCreateSessionTap(activity))
//                        },
//                        managerEventsStore: managerEventsStore,
//                        onDeleteFocusTap: {
//                            managerEventsStore.send(.deleteActivityTap(activity.id))
//                        }
//                    )
//                } else {
//                    ContentUnavailableView(
//                        "Focus not found",
//                        systemImage: "exclamationmark.triangle"
//                    )
//                }
//            }
            .navigationDestination(item: eventDetailStore) { store in
                EventDetailFeatureView(store: store)
            }
            .sheet(item: createEventStore) { store in
                NavigationStack {
                    CreateEventView(store: store)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onCreateActivityTap()
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
            onCreateActivityTap()
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

private struct FocusCardView: View {
    let activity: Activity

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(activity.title)
                    .font(.headline)

                Spacer()

//                TrendBadge(direction: activity.trend.direction)
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

#Preview {
    MyActivitiesView(
        session: .mock(),
        onCreateActivityTap: {},
        managerEventsStore: .init(
            initialState: .init(session: .init(value: .mock())),
            reducer: { ActivitiesFeature() }
        )
    )
}
