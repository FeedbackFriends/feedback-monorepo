//import SwiftUI
//import DesignSystem
//import Domain
//
//struct FocusDetailView: View {
//    let activity: Activity
//    let onCreateSessionTap: () -> Void
//    @Bindable var managerEventsStore: StoreOf<ActivitiesFeature>
//    let onDeleteFocusTap: () -> Void
//    @State private var showDeleteConfirmation = false
//
//    private var groupedSessions: (today: [ManagerEvent], comingUp: [ManagerEvent], previous: [ManagerEvent]) {
//        let sessions = activity.relatedSessions.sorted(by: { $0.date > $1.date })
//        return (
//            today: sessions.filter { $0.date.isToday },
//            comingUp: sessions.filter { $0.date.isAfterToday },
//            previous: sessions.filter { $0.date.isBeforeToday }
//        )
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                HStack {
//                    TrendBadge(direction: activity.trend.direction)
//                    Spacer()
//                    Text(activity.durationText)
//                        .font(.subheadline)
//                        .foregroundStyle(.secondary)
//                }
//
//                detailRow(title: "Date", value: activity.formattedDate)
//
//                if let location = activity.location, !location.isEmpty {
//                    detailRow(title: "Location", value: location)
//                }
//
//                if let pinCode = activity.pinCode?.value {
//                    detailRow(title: "PIN", value: "#\(pinCode)")
//                }
//
//                if let summary = activity.overallFeedbackSummary {
//                    detailRow(title: "Responses", value: "\(summary.responses)")
//                    detailRow(title: "New responses", value: "\(summary.unseenResponses)")
//                }
//
//                if let agenda = activity.agenda, !agenda.isEmpty {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Agenda")
//                            .font(.headline)
//
//                        Text(agenda)
//                            .font(.body)
//                            .foregroundStyle(.secondary)
//                    }
//                    .padding(.top, 8)
//                }
//
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Related sessions")
//                        .font(.headline)
//
//                    relatedSessionsSection
//                }
//                .padding(.top, 8)
//            }
//            .padding()
//        }
//        .navigationTitle(activity.title)
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .topBarTrailing) {
//                HStack {
//                    Button {
//                        onCreateSessionTap()
//                    } label: {
//                        Image(systemName: "plus")
//                    }
//                    .accessibilityIdentifier("focus_detail_add_session_button")
//
//                    Button(role: .destructive) {
//                        showDeleteConfirmation = true
//                    } label: {
//                        Image(systemName: "trash")
//                    }
//                }
//            }
//        }
//        .confirmationDialog(
//            "Delete focus?",
//            isPresented: $showDeleteConfirmation,
//            titleVisibility: .visible
//        ) {
//            Button("Delete focus", role: .destructive) {
//                onDeleteFocusTap()
//            }
//            Button("Cancel", role: .cancel) {}
//        } message: {
//            Text("This removes the focus area and all related sessions.")
//        }
//    }
//
//    private var relatedSessionsSection: some View {
//        ManagerSessionsListView(
//            todayEvents: groupedSessions.today.map { activity.relatedSessionActivity($0) },
//            comingUpEvents: groupedSessions.comingUp.map { activity.relatedSessionActivity($0) },
//            previousEvents: groupedSessions.previous.map { activity.relatedSessionActivity($0) },
//            onEventTap: { event in
//                managerEventsStore.send(.managerEventTap(event.event))
//            }
//        )
//    }
//
//    private func detailRow(title: String, value: String) -> some View {
//        HStack(alignment: .top, spacing: 8) {
//            Text(title)
//                .font(.subheadline.weight(.semibold))
//                .frame(width: 110, alignment: .leading)
//
//            Text(value)
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
//
//            Spacer()
//        }
//    }
//}
//
//private struct TrendBadge: View {
//    let direction: ActivityTrend.Direction
//
//    var body: some View {
//        Label(direction.title, systemImage: direction.symbolName)
//            .font(.caption.weight(.semibold))
//            .padding(.horizontal, 10)
//            .padding(.vertical, 6)
//            .foregroundStyle(direction.color)
//            .background(direction.color.opacity(0.12), in: Capsule())
//    }
//}
