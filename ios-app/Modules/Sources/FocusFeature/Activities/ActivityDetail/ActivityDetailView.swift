import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

struct ActivityDetailView: View {
    private struct GroupedSessions {
        let today: [Event]
        let comingUp: [Event]
        let previous: [Event]
    }

    @Bindable var store: StoreOf<ActivityDetail>
    @State private var showDeleteConfirmation = false
    
    private var activity: Activity? {
        store.activityDetail
    }

    private var groupedSessions: GroupedSessions {
        let sessions = (activity?.relatedSessions ?? []).sorted(by: { $0.date > $1.date })
        return GroupedSessions(
            today: sessions.filter { $0.date.isToday },
            comingUp: sessions.filter { $0.date.isAfterToday },
            previous: sessions.filter { $0.date.isBeforeToday }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    LegacyTrendBadge(direction: activity?.trend.direction ?? .insufficientData)
                    Spacer()
                    Text(activity?.durationText ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                detailRow(title: "Date", value: activity?.formattedDate ?? "")

                if let location = activity?.location, !location.isEmpty {
                    detailRow(title: "Location", value: location)
                }

                if let pinCode = activity?.pinCode?.value {
                    detailRow(title: "PIN", value: "#\(pinCode)")
                }

                if let summary = activity?.overallFeedbackSummary {
                    detailRow(title: "Responses", value: "\(summary.responses)")
                    detailRow(title: "New responses", value: "\(summary.unseenResponses)")
                }

                if let agenda = activity?.agenda, !agenda.isEmpty {
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

                    relatedSessionsSection
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle(activity?.title ?? "Session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button {
//                        onCreateSessionTap()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("activity_detail_add_session_button")

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .confirmationDialog(
            "Delete activity?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete activity", role: .destructive) {
//                onDeleteActivityTap()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the activity and all related sessions.")
        }
    }

    private var relatedSessionsSection: some View {
        ManagerSessionsListView(
            todayEvents: groupedSessions.today.map { activity?.relatedSessionActivity($0) }.compactMap { $0 },
            comingUpEvents: groupedSessions.comingUp.map { activity?.relatedSessionActivity($0) }.compactMap { $0 },
            previousEvents: groupedSessions.previous.map { activity?.relatedSessionActivity($0) }.compactMap { $0 },
            onEventTap: { _ in }
        )
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

private struct LegacyTrendBadge: View {
    let direction: ActivityTrend.Direction

    var body: some View {
        Label(title, systemImage: symbolName)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(color)
            .background(color.opacity(0.12), in: Capsule())
    }

    private var title: String {
        switch direction {
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

    private var symbolName: String {
        switch direction {
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

    private var color: Color {
        switch direction {
        case .improving:
            return .green
        case .stable:
            return .gray
        case .declining:
            return .orange
        case .insufficientData:
            return .secondary
        }
    }
}
