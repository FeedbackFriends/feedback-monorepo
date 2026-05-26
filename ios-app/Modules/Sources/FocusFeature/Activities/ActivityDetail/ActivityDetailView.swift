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
            VStack(alignment: .leading, spacing: 8) {
                detailsSection(activity)

                sessionsSection(
                    groupedSessions: groupedSessions,
                    eventTitle: activity.title
                )
                .padding(.top, 4)
            }
            .padding()
            .padding(.bottom, 80)
        }
        .scrollIndicators(.hidden)
        .background(Color.themeBackground)
        .lineSpacing(5)
        .foregroundStyle(Color.themeText)
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
                    .buttonStyle(PrimaryTextButtonStyle())
                    .accessibilityIdentifier("activity_detail_add_session_button")

                    Button {
                        store.send(.editActivityButtonTapped)
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(PrimaryTextButtonStyle())
                    .accessibilityIdentifier("activity_detail_edit_button")

                    Button(role: .destructive) {
                        store.send(.deleteActivityButtonTap)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(PrimaryTextButtonStyle())
                    .accessibilityLabel("Delete focus")
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

    private func detailsSection(_ activity: Activity) -> some View {
        VStack(alignment: .leading) {
            Text("DETAILS")
                .sectionHeaderStyle()
                .padding(.leading, 18)

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        LegacyTrendBadge(direction: activity.trend.direction)
                        Spacer()
                        Text(activity.durationText)
                            .font(.montserratRegular, 13)
                            .foregroundStyle(Color.themeTextSecondary)
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
                        Text("Agenda")
                            .font(.montserratSemiBold, 13)

                        Text(agenda)
                            .font(.montserratRegular, 13)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(15)

                if let feedback = activity.overallFeedbackSummary {
                    FeedbackPercentageBarView(feedback: feedback.segmentationStats)
                } else {
                    EmptyFeedbackSegmentationStatsView()
                }
            }
            .font(.montserratRegular, 14)
            .background(Color.themeSurface)
            .cornerRadius(14)
        }
    }

    private func sessionsSection(groupedSessions: GroupedSessions, eventTitle: String) -> some View {
        EventListView(
            todayEvents: groupedSessions.today,
            comingUpEvents: groupedSessions.comingUp,
            previousEvents: groupedSessions.previous,
            eventTitle: eventTitle,
            onEventTap: { store.send(.eventTapped($0)) },
            onCreateEventTap: {
                store.send(.createEventButtonTapped)
            }
        )
    }

    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.montserratSemiBold, 13)

            Text(value)
                .font(.montserratRegular, 13)
        }
    }
}

private struct LegacyTrendBadge: View {
    let direction: ActivityTrend.Direction

    var body: some View {
        Label(title, systemImage: symbolName)
            .font(.montserratMedium, 12)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(color)
            .background(Color.themeBackground, in: Capsule())
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
