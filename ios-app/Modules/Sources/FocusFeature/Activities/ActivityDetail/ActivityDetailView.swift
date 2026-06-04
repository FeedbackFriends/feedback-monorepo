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
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.showDeleteConfirmation,
                action: \.destination.showDeleteConfirmation
            )
        ) { _ in
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
            )
            .presentationDetents([.height(340)])
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.showHowItWorks,
                action: \.destination.showHowItWorks
            )
        ) { _ in
            ActivityDetailHowItWorksSheetView {
                UIPasteboard.general.string = "feedback@letsgrow.dk"
            }
            .presentationDetents([.medium, .large])
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
                ActivityDetailHowItWorksView {
                    UIPasteboard.general.string = "feedback@letsgrow.dk"
                }
            }

            if !activity.events.isEmpty {
                activityOverviewCard(activity)
                trendSection(activity)
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
                    LegacyTrendBadge(direction: activity.trend.direction)
                    FocusMetricBadge(text: sessionCountText(for: activity.events.count))
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

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    store.send(.showHowItWorksButtonTap)
                } label: {
                    Label("Sådan virker det", systemImage: "questionmark.circle")
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
                    Label("Sådan virker det", systemImage: "questionmark.circle")
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

struct ActivityDetailHowItWorksView: View {
    let onCopyEmail: () -> Void
    @State private var showCopiedAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Sådan virker det")
                    .titleTextStyle()
                    .foregroundStyle(Color.themeText)

                Text(
                    """
                    Du behøver ikke ændre den måde, du planlægger møder på. Opret møder i det kalenderværktøj, du \
                    allerede bruger, og inviter blot 'Lets Grow'-mailen. Så oprettes sessionen automatisk her i appen.
                    """
                )
                    .bodyTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 14) {
                Text(
                    """
                    Tilføj feedback@letsgrow.dk til kalenderaftalen. Invitationen skal sendes fra mailadressen på din \
                    LetsGrow-konto, fx navn@firma.dk. Du kan ændre den under Indstillinger.
                    """
                )
                    .bodyTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)

                CalendarIntegrationsView()

                HStack(spacing: 12) {
                    Text(verbatim: "feedback@letsgrow.dk")
                        .rowTitleTextStyle()
                        .foregroundStyle(Color.themeText)
                        .tint(Color.themeText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Spacer(minLength: 0)

                    Button("Kopiér") {
                        onCopyEmail()
                        showCopiedAlert = true
                    }
                    .buttonStyle(PrimaryTextButtonStyle())
                }
                .padding(Theme.padding)
                .background(Color.themeBackground, in: Capsule(style: .continuous))
            }

            Divider()

            Text("Du kan også oprette en mødegang manuelt i Mere-menuen, hvis du foretrækker det.")
                .supportingTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Theme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.themeSurface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .alert("Mailen er kopieret", isPresented: $showCopiedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Sæt den ind i den kalenderaftale, du allerede bruger.")
        }
    }
}

private struct CalendarIntegrationsView: View {
    private let integrations: [CalendarIntegration] = [
        CalendarIntegration(name: "Teams", image: .calendarTeamsLogo),
        CalendarIntegration(name: "Outlook", image: .calendarMicrosoftOutlook),
        CalendarIntegration(name: "Google", image: .calendarGoogle),
        CalendarIntegration(name: "Apple", image: .calendarAppleLogo),
        CalendarIntegration(name: "Zoho", image: .calendarZoho),
        CalendarIntegration(name: "Proton", image: .calendarProton)
    ]

    private let columns = Array(
        repeating: GridItem(.flexible(minimum: 44), spacing: 8),
        count: 6
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(integrations) { integration in
                VStack(spacing: 8) {
                    integration.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)

                    Text(integration.name)
                        .captionTextStyle()
                        .foregroundStyle(Color.themeTextSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .allowsTightening(true)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(integration.name)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct CalendarIntegration: Identifiable {
    let name: String
    let image: Image

    var id: String { name }
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
