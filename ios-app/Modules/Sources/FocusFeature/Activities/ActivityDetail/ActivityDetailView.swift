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
                        message: "Aktivitet slettet",
                        show: .constant(true),
                        enableAutomaticDismissal: true
                    )
            }
        }.sheet(isPresented: $store.showDeleteConfirmation) {
            DeleteConfirmationViewSheet(
                title: "Slet aktivitet",
                message: "Slet dette faste møde og al feedback?",
                actionButton: {
                    Button("Slet") {
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

        return screenBody(groupedSessions: groupedSessions)
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
        .sheet(isPresented: $store.showCalendarSetup) {
            calendarSetupSheet
                .presentationDetents([.medium])
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

    private var calendarSetupSheet: some View {
        CalendarSetupView(
            email: "feedback@letsgrow.dk",
            didCopyEmail: store.didCopyCalendarEmail,
            onCopyEmail: {
                UIPasteboard.general.string = "feedback@letsgrow.dk"
                store.didCopyCalendarEmail = true
            },
            onCreateOneOffSession: {
                Task { @MainActor in
                    store.showCalendarSetup = false
                    store.send(.createEventButtonTapped)
                }
            }
        )
    }

    private func screenBody(groupedSessions: GroupedSessions) -> some View {
        ScrollView {
            contentStack(groupedSessions: groupedSessions)
        }
        .scrollIndicators(.hidden)
        .background(Color.themeBackground)
        .lineSpacing(5)
        .foregroundStyle(Color.themeText)
        .navigationTitle("Aktivitet")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ViewBuilder
    private func contentStack(groupedSessions: GroupedSessions) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            focusHeader(activity)

            trendSection(activity)

            focusSetupSection(activity)

            sessionsSection(
                groupedSessions: groupedSessions,
                eventTitle: activity.title
            )
        }
        .padding()
        .padding(.bottom, 24)
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

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack {
                Button {
                    store.showCalendarSetup = true
                } label: {
                    Image(systemName: "calendar.badge.plus")
                }
                .buttonStyle(PrimaryTextButtonStyle())
                .accessibilityLabel("Åbn kalenderopsætning")

                Button {
                    store.send(.editActivityButtonTapped)
                } label: {
                    Image(systemName: "pencil")
                }
                .buttonStyle(PrimaryTextButtonStyle())
                .accessibilityLabel("Rediger aktivitet")
                .accessibilityIdentifier("activity_detail_edit_button")

                Menu {
                    Button(role: .destructive) {
                        store.send(.deleteActivityButtonTap)
                    } label: {
                        Label("Slet aktivitet", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
                .buttonStyle(PrimaryTextButtonStyle())
                .accessibilityLabel("Flere handlinger for aktivitet")
            }
        }
    }

    private func sessionsSection(groupedSessions: GroupedSessions, eventTitle: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            EventListView(
                todayEvents: groupedSessions.today,
                comingUpEvents: groupedSessions.comingUp,
                previousEvents: groupedSessions.previous,
                eventTitle: eventTitle,
                onEventTap: { store.send(.eventTapped($0)) }
            )

            Button {
                store.send(.createEventButtonTapped)
            } label: {
                Label("Tilføj enkelt mødegang", systemImage: "plus")
            }
            .buttonStyle(SecondaryTextButtonStyle())
            .accessibilityIdentifier("activity_detail_create_session_button")
        }
    }

    private func trendSection(_ activity: Activity) -> some View {
        VStack(alignment: .leading) {
            SectionHeaderView("Mødekvalitet")

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Label(activity.trend.direction.title, systemImage: activity.trend.direction.symbolName)
                        .rowTitleTextStyle()
                        .foregroundStyle(activity.trend.direction.color)

                    Spacer()

                    if let deltaText = activity.trend.deltaText {
                        Text(deltaText)
                            .captionTextStyle()
                            .foregroundStyle(activity.trend.direction.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.themeBackground, in: Capsule())
                    }
                }

                Text(activity.trend.summaryText)
                    .supportingTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    store.showCalendarSetup = true
                } label: {
                    Label("Inviter feedback@letsgrow.dk", systemImage: "calendar.badge.plus")
                }
                .buttonStyle(SecondaryTextButtonStyle())
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.themeSurface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        }
    }

    private func focusSetupSection(_ activity: Activity) -> some View {
        VStack(alignment: .leading) {
            SectionHeaderView("Feedbackopsætning")

            Button {
                store.send(.editActivityButtonTapped)
            } label: {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(questionCountText(for: activity.questions.count))
                            .rowTitleTextStyle()
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Label("Rediger", systemImage: "pencil")
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
            .accessibilityLabel("Rediger feedbackopsætning for aktivitet")
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
        count == 1 ? "1 mødegang" : "\(count) mødegange"
    }

    private func questionCountText(for count: Int) -> String {
        count == 1 ? "1 spørgsmål" : "\(count) spørgsmål"
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
        Label(direction.title, systemImage: direction.symbolName)
            .captionTextStyle()
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(direction.color)
            .background(Color.themeBackground, in: Capsule())
    }
}

private extension ActivityTrend {
    var deltaText: String? {
        guard let delta else { return nil }
        let sign = delta > 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", delta))"
    }

    var summaryText: String {
        switch direction {
        case .improving:
            return "Mødekvaliteten stiger sammenlignet med tidligere mødegange."
        case .stable:
            return "Mødekvaliteten ligger stabilt. Hold øje med næste mødegang."
        case .declining:
            return "Mødekvaliteten falder. Brug feedbacken til at justere formatet."
        case .insufficientData:
            return "Inviter feedback@letsgrow.dk og saml flere svar for at se udviklingen."
        }
    }
}

private extension ActivityTrend.Direction {
    var title: String {
        switch self {
        case .improving:
            return "Bliver bedre"
        case .stable:
            return "Stabilt"
        case .declining:
            return "Falder"
        case .insufficientData:
            return "For lidt data"
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
            return Color.themeTextSecondary
        case .declining:
            return Color.themeSad
        case .insufficientData:
            return Color.themeTextSecondary
        }
    }
}
