import ComposableArchitecture
import DesignSystem
import Domain
import Foundation
import SwiftUI

private struct GroupedSessions {
    let today: [Event]
    let comingUp: [Event]
    let previous: [Event]
}

struct ActivityDetailView: View {
    @Bindable var store: StoreOf<ActivityDetail>

    var body: some View {
        Group {
            if let activity = store.activity {
                ActivityDetailContentView(store: store, activity: activity)
            } else {
                EmptyView()
                    .successOverlay(
                        message: "Focus deleted",
                        show: .constant(true),
                        enableAutomaticDismissal: true
                    )
            }
        }.sheet(isPresented: $store.showDeleteConfirmation) {
            DeleteConfirmationViewSheet(
                title: "Delete focus",
                message: "Delete this focus and its sessions?",
                actionButton: {
                    Button("Delete") {
                        store.send(.deleteActivityConfirmButtonTap)
                    }
                    .buttonStyle(LargeBoxButtonStyle(color: Color.themeVerySad))
                    .isLoading(store.deleteActivityInFlight)
                }
            ).presentationDetents([.height(340)])
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(width: 110, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(Color.themeTextSecondary)

            Spacer()
        }
    }
}

private struct ActivityDetailContentView: View {
    @Bindable var store: StoreOf<ActivityDetail>
    let activity: Activity

    var body: some View {
        let sessions = activity.events.sorted(by: { $0.date > $1.date })
        let groupedSessions = GroupedSessions(
            today: sessions.filter { $0.date.isToday },
            comingUp: sessions.filter { $0.date.isAfterToday },
            previous: sessions.filter { $0.date.isBeforeToday }
        )

        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    LegacyTrendBadge(direction: activity.trend.direction)
                    Spacer()
                    Text(activity.durationText)
                        .font(.subheadline)
                        .foregroundStyle(Color.themeTextSecondary)
                }

                detailRow(title: "Date", value: activity.formattedDate)

                if let location = activity.location, !location.isEmpty {
                    detailRow(title: "Location", value: location)
                }

                if let pinCode = activity.pinCode?.value {
                    let pinValue = "#\(pinCode)"
                    detailRow(title: "PIN", value: pinValue)
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
                            .foregroundStyle(Color.themeTextSecondary)
                    }
                    .padding(.top, 8)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Sessions")
                        .font(.headline)

                    EventListView(
                        todayEvents: groupedSessions.today,
                        comingUpEvents: groupedSessions.comingUp,
                        previousEvents: groupedSessions.previous,
                        eventTitle: activity.title,
                        onEventTap: { store.send(.eventTapped($0)) }
                    )
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle(activity.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button {
                        store.send(.createEventButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("activity_detail_add_session_button")

                    Button {
                        store.send(.editActivityButtonTapped)
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .accessibilityIdentifier("activity_detail_edit_button")

                    Button(role: .destructive) {
                        store.send(.deleteActivityButtonTap)
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.editActivity,
                action: \.destination.editActivity
            )
        ) { editStore in
            ManageActivityView(store: editStore)
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.manageEvent,
                action: \.destination.manageEvent
            )
        ) { manageStore in
            NavigationStack {
                ManageEventView(store: manageStore)
            }
        }
        .navigationDestination(
            item: $store.scope(
                state: \.destination?.eventDetail,
                action: \.destination.eventDetail
            )
        ) { eventDetailStore in
            EventDetailFeatureView(store: eventDetailStore)
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(width: 110, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(Color.themeTextSecondary)

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
            return Color.themeSuccess
        case .stable:
            return Color.themeTextSecondary
        case .declining:
            return Color.themeSad
        case .insufficientData:
            return Color.themeTextSecondary
        }
    }
}
