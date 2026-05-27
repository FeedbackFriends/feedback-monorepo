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
            VStack(alignment: .leading, spacing: 12) {
                focusHeader(activity)

                focusSetupSection(activity)

                sessionsSection(
                    groupedSessions: groupedSessions,
                    eventTitle: activity.title
                )
            }
            .padding()
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Color.themeBackground)
        .lineSpacing(5)
        .foregroundStyle(Color.themeText)
        .navigationTitle("Focus")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button {
                        store.send(.editActivityButtonTapped)
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(PrimaryTextButtonStyle())
                    .accessibilityLabel("Edit focus")
                    .accessibilityIdentifier("activity_detail_edit_button")

                    Menu {
                        Button(role: .destructive) {
                            store.send(.deleteActivityButtonTap)
                        } label: {
                            Label("Delete focus", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .buttonStyle(PrimaryTextButtonStyle())
                    .accessibilityLabel("More focus actions")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button("Create session") {
                store.send(.createEventButtonTapped)
            }
            .buttonStyle(LargeButtonStyle())
            .accessibilityIdentifier("activity_detail_create_session_button")
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 16)
            .background(Color.themeBackground)
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

    private func focusHeader(_ activity: Activity) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(activity.title)
                .titleTextStyle()
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                LegacyTrendBadge(direction: activity.trend.direction)
                FocusMetricBadge(text: sessionCountText(for: activity.events.count))
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.themeSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .accessibilityIdentifier("activity_detail_focus_header")
    }

    private func sessionsSection(groupedSessions: GroupedSessions, eventTitle: String) -> some View {
        EventListView(
            todayEvents: groupedSessions.today,
            comingUpEvents: groupedSessions.comingUp,
            previousEvents: groupedSessions.previous,
            eventTitle: eventTitle,
            onEventTap: { store.send(.eventTapped($0)) }
        )
    }

    private func focusSetupSection(_ activity: Activity) -> some View {
        VStack(alignment: .leading) {
            SectionHeaderView("Focus setup")

            Button {
                store.send(.editActivityButtonTapped)
            } label: {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(questionCountText(for: activity.questions.count))
                            .rowTitleTextStyle()
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Label("Edit", systemImage: "pencil")
                            .captionTextStyle()
                            .foregroundStyle(Color.themePrimaryAction)
                    }

                    if let agenda = activity.agenda, !agenda.isEmpty {
                        Text(agenda)
                            .supportingTextStyle()
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    }

                    questionTypeSummary(activity.questions)
                }
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.themeSurface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            }
            .buttonStyle(OpacityButtonStyle())
            .accessibilityLabel("Edit focus setup")
            .accessibilityIdentifier("activity_detail_focus_setup_section")
        }
    }

    private func questionTypeSummary(_ questions: [ManagerQuestion]) -> some View {
        HStack(spacing: 8) {
            ForEach(Array(questions.prefix(4).enumerated()), id: \.element.id) { _, question in
                FocusQuestionTypeBadge(question: question)
            }

            if questions.count > 4 {
                FocusMetricBadge(text: "+\(questions.count - 4)")
            }
        }
    }

    private func sessionCountText(for count: Int) -> String {
        count == 1 ? "1 session" : "\(count) sessions"
    }

    private func questionCountText(for count: Int) -> String {
        count == 1 ? "1 question" : "\(count) questions"
    }
}

private struct FocusQuestionTypeBadge: View {
    let question: ManagerQuestion

    var body: some View {
        Label {
            Text(question.feedbackType.title)
        } icon: {
            question.feedbackType.image
        }
        .captionTextStyle()
        .foregroundStyle(Color.themeTextSecondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.themeBackground, in: Capsule())
    }
}

private struct FocusMetricBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .captionTextStyle()
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(Color.themeTextSecondary)
            .background(Color.themeBackground, in: Capsule())
    }
}

private struct LegacyTrendBadge: View {
    let direction: ActivityTrend.Direction

    var body: some View {
        Label(title, systemImage: symbolName)
            .captionTextStyle()
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
