import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

private struct GroupedSessions {
    let today: [Event]
    let comingUp: [Event]
    let previous: [Event]
}

struct ActivityDetailContentView: View {
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
        .navigationDestination(
            item: $store.scope(
                state: \.destination?.eventDetail,
                action: \.destination.eventDetail
            )
        ) { eventDetailStore in
            EventDetailFeatureView(store: eventDetailStore)
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }

    private func screenBody(groupedSessions: GroupedSessions) -> some View {
        ScrollView {
            contentStack(groupedSessions: groupedSessions)
        }
        .scrollIndicators(.hidden)
        .background(LetsGrowLandingGradient().ignoresSafeArea())
        .lineSpacing(5)
        .foregroundStyle(Color.themeText)
        .navigationTitle(activity.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ViewBuilder
    private func contentStack(groupedSessions: GroupedSessions) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if activity.events.isEmpty {
                emptyEventsNotice

                ActivityDetailHowItWorksView {
                    UIPasteboard.general.string = "feedback@letsgrow.dk"
                }
            } else {
                activityOverviewCard(activity)

                if activity.hasDisplayableTrend {
                    trendSection(activity)
                }

                sessionsSection(
                    groupedSessions: groupedSessions,
                    eventTitle: activity.title
                )
            }
        }
        .padding()
        .padding(.bottom, 24)
    }

    private func activityOverviewCard(_ activity: Activity) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeaderView("Mødedetaljer", horizontalPadding: 0)

                HStack(spacing: 8) {
                    FocusMetricBadge(text: sessionCountText(for: activity.events.count))

                    if activity.hasDisplayableTrend {
                        LegacyTrendBadge(direction: activity.trend.direction)
                    }
                }
            }

            Divider()

            focusSetupContent(activity)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.themeSurface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .accessibilityIdentifier("activity_detail_overview_card")
    }

    private var emptyEventsNotice: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Ingen mødegange endnu")
                .titleTextStyle()

            Text("Når du inviterer LetsGrow til et kalendermøde, vises mødegangen her.")
                .supportingTextStyle()
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.themeSurface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .accessibilityIdentifier("activity_detail_empty_events_notice")
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    store.send(.showHowItWorksButtonTap)
                } label: {
                    Label("Fra møde til feedback", systemImage: "questionmark.circle")
                }

                Button {
                    store.send(.createEventButtonTapped)
                } label: {
                    Label("Opret mødegang", systemImage: "plus")
                }
                .accessibilityIdentifier("activity_detail_create_session_menu_button")

                Button {
                    store.send(.editActivityButtonTapped)
                } label: {
                    Label("Rediger aktivitet", systemImage: "pencil")
                }
                .accessibilityIdentifier("activity_detail_edit_button")

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

    private func sessionsSection(groupedSessions: GroupedSessions, eventTitle: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            EventListView(
                todayEvents: groupedSessions.today,
                comingUpEvents: groupedSessions.comingUp,
                previousEvents: groupedSessions.previous,
                eventTitle: eventTitle,
                onEventTap: { store.send(.eventTapped($0)) }
            )
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

                Text(verbatim: activity.trend.summaryText)
                    .supportingTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)
                    .tint(Color.themeText)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    store.send(.showHowItWorksButtonTap)
                } label: {
                    Label("Fra møde til feedback", systemImage: "questionmark.circle")
                }
                .buttonStyle(SecondaryTextButtonStyle())
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.themeSurface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        }
    }

    private func focusSetupContent(_ activity: Activity) -> some View {
        Button {
            store.send(.editActivityButtonTapped)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        SectionHeaderView("Feedbackopsætning", horizontalPadding: 0)
                        Text(questionCountText(for: activity.questions.count))
                            .rowTitleTextStyle()
                    }
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
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(OpacityButtonStyle())
        .accessibilityLabel("Rediger feedbackopsætning for aktivitet")
        .accessibilityIdentifier("activity_detail_focus_setup_section")
    }

    private func questionTypeSummary(_ questions: [ManagerQuestion]) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(Array(questions.enumerated()), id: \.element.id) { _, question in
                    FeedbackTypeTagView(question.feedbackType)
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private func sessionCountText(for count: Int) -> String {
        count == 1 ? "1 mødegang" : "\(count) mødegange"
    }

    private func questionCountText(for count: Int) -> String {
        count == 1 ? "1 spørgsmål" : "\(count) spørgsmål"
    }
}

private extension Activity {
    var hasDisplayableTrend: Bool {
        trend.direction != .insufficientData
    }
}
