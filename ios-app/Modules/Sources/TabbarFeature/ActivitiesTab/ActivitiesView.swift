import Domain
import EventsFeature
import SwiftUI

public struct ActivitiesView: View {
    let session: Bootstrap
    let onCreateActivityTap: () -> Void

    public init(session: Bootstrap, onCreateActivityTap: @escaping () -> Void) {
        self.session = session
        self.onCreateActivityTap = onCreateActivityTap
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
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    createCTA

                    if activities.isEmpty {
                        emptyState
                    } else {
                        ForEach(activities) { activity in
                            NavigationLink(value: activity.id) {
                                ActivityCardView(activity: activity)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Activities")
            .navigationDestination(for: UUID.self) { activityId in
                if let activity = activities.first(where: { $0.id == activityId }) {
                    ActivityDetailView(activity: activity)
                } else {
                    ContentUnavailableView(
                        "Activity not found",
                        systemImage: "exclamationmark.triangle"
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onCreateActivityTap()
                    } label: {
                        Image(systemName: "plus")
                    }
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

private struct ActivityCardView: View {
    let activity: Activity

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(activity.title)
                    .font(.headline)

                Spacer()

                TrendBadge(direction: activity.trend.direction)
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

private struct ActivityDetailView: View {
    let activity: Activity

    private var groupedSessions: (today: [Activity], comingUp: [Activity], previous: [Activity]) {
        let sessions = activity.relatedSessions.sorted(by: { $0.date > $1.date })
        return (
            today: sessions.filter { $0.date.isToday },
            comingUp: sessions.filter { $0.date.isAfterToday },
            previous: sessions.filter { $0.date.isBeforeToday }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    TrendBadge(direction: activity.trend.direction)
                    Spacer()
                    Text(activity.durationText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                detailRow(title: "Date", value: activity.formattedDate)

                if let location = activity.location, !location.isEmpty {
                    detailRow(title: "Location", value: location)
                }

                if let pinCode = activity.pinCode?.value {
                    detailRow(title: "PIN", value: "#\(pinCode)")
                }

                if let summary = activity.overallFeedbackSummary {
                    detailRow(title: "Responses", value: "\(summary.responses)")
                    detailRow(title: "New responses", value: "\(summary.unseenResponses)")
                }

                if let agenda = activity.agenda, !agenda.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Agenda")
                            .font(.headline)

                        Text(agenda)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Related sessions")
                        .font(.headline)

                    ManagerSessionsListView(
                        todayEvents: groupedSessions.today,
                        comingUpEvents: groupedSessions.comingUp,
                        previousEvents: groupedSessions.previous
                    )
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle(activity.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(width: 110, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
}

private struct TrendBadge: View {
    let direction: ActivityTrend.Direction

    var body: some View {
        Label(direction.title, systemImage: direction.symbolName)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(direction.color)
            .background(direction.color.opacity(0.12), in: Capsule())
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
    ActivitiesView(session: .mock(), onCreateActivityTap: {})
}
