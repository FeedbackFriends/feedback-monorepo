import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

struct HomeOverviewView: View {
    let store: StoreOf<ActivityList>
    let now: Date

    var body: some View {
        let overview = HomeOverview(activities: store.activities, now: now)
        LazyVStack(alignment: .leading, spacing: 24) {
            if let error = store.refreshError {
                VStack(alignment: .leading, spacing: 8) {
                    Text(error).supportingTextStyle()
                    Button("Prøv igen") { store.send(.refresh) }.disabled(store.isRefreshing)
                }
                .accessibilityIdentifier("home_refresh_error")
            }
            if store.activities.isEmpty {
                ContentUnavailableView {
                    Label {
                        Text("Din første aktivitet").titleTextStyle()
                    } icon: {
                        Image(systemName: "calendar.badge.plus")
                            .foregroundStyle(Color.themeTextSecondary)
                    }
                } description: {
                    Text("Saml ærlig feedback efter dine møder, og se hvad der virker over tid.")
                        .bodyTextStyle()
                } actions: {
                    Button { store.send(.createActivityButtonTap) } label: {
                        Text("Opret din første aktivitet")
                            .padding(.horizontal, 24)
                    }
                    .buttonStyle(LargeButtonStyle())
                    .accessibilityIdentifier("home_create_first_activity")
                }
            } else {
                if !overview.unreadSessions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            SectionHeaderView("Ny feedback")
                            Spacer()
                            if overview.unreadSessions.count > 2 {
                                Button { store.send(.unreadFeedbackButtonTap) } label: {
                                    Text("Vis alle (\(overview.unreadSessions.count))").captionTextStyle()
                                }
                                .accessibilityIdentifier("home_all_feedback_button")
                            }
                        }
                        ForEach(Array(overview.unreadSessions.prefix(2))) { session in
                            HomeSessionCardView(session: session, isUpcoming: false) {
                                store.send(.eventTap(activityId: session.activity.id, eventId: session.event.id))
                            }
                        }
                    }
                }
                if let session = overview.latestFeedbackSession {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView("Seneste feedback")
                        HomeSessionCardView(session: session, isUpcoming: false) {
                            store.send(.eventTap(activityId: session.activity.id, eventId: session.event.id))
                        }
                    }
                    .accessibilityIdentifier("home_latest_feedback")
                }
                if let session = overview.nextSession {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView("Næste session")
                        HomeSessionCardView(session: session, isUpcoming: true) {
                            store.send(.eventTap(activityId: session.activity.id, eventId: session.event.id))
                        }
                    }
                }
                if !overview.developments.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView("Udvikling")
                        Text("Ændringer fra feedback modtaget de seneste 30 dage.")
                            .captionTextStyle().foregroundStyle(Color.themeTextSecondary)
                        ForEach(Array(overview.developments.prefix(1))) { activity in
                            Button { store.send(.activityTap(activity)) } label: {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(activity.title).rowTitleTextStyle()
                                    InsightTrendView(data: .init(activity: activity))
                                    Label("Se udvikling", systemImage: "arrow.right").captionTextStyle()
                                        .foregroundStyle(Color.themePrimaryAction)
                                }
                                .surfaceCard(padding: 16)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("home_development_\(activity.id)")
                        }
                    }
                }
                if overview.unreadSessions.isEmpty && overview.latestFeedbackSession == nil &&
                    overview.nextSession == nil && overview.developments.isEmpty {
                    ContentUnavailableView {
                        Label("Du er opdateret", systemImage: "checkmark.circle")
                    } description: {
                        Text("Ingen ulæst feedback eller kommende sessioner lige nu. Planlæg din næste session i din kalender, som du plejer.")
                    }
                    .accessibilityIdentifier("home_up_to_date")
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeaderView("Seneste 30 dage")
                    Text(overview.recentSessionCount == 1 ? "1 session" : "\(overview.recentSessionCount) sessioner")
                        .supportingTextStyle()
                    Text("\(overview.recentFeedbackSessionCount) med feedback")
                        .captionTextStyle()
                    Text("Afsluttede sessioner med start i perioden.")
                        .captionTextStyle()
                }
                .foregroundStyle(Color.themeTextSecondary)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("home_recent_status")
            }
        }
        .foregroundStyle(Color.themeText)
    }
}

struct HomeSessionCardView: View {
    let session: HomeOverview.Session
    let isUpcoming: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Text(session.activity.title).rowTitleTextStyle()
                Text(session.event.date.formatted(date: .abbreviated, time: .shortened))
                    .supportingTextStyle().foregroundStyle(Color.themeTextSecondary)
                if isUpcoming {
                    if session.event.questionsSnapshot.isEmpty {
                        Label("Der mangler feedbackspørgsmål", systemImage: "exclamationmark.circle")
                            .supportingTextStyle()
                    } else {
                        Label("\(session.event.questionsSnapshot.count) feedbackspørgsmål klar", systemImage: "checkmark.circle")
                            .supportingTextStyle()
                    }
                } else {
                    if session.unseenResponses > 0 {
                        Text(session.unseenResponses == 1 ? "1 nyt svar" : "\(session.unseenResponses) nye svar")
                            .supportingTextStyle()
                    } else {
                        Text(session.responseCount == 1 ? "1 besvarelse" : "\(session.responseCount) besvarelser")
                            .supportingTextStyle()
                    }
                }
                Label(isUpcoming ? "Se session" : "Læs feedback", systemImage: "arrow.right")
                    .captionTextStyle().foregroundStyle(Color.themePrimaryAction)
            }
            .surfaceCard(padding: 16)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("home_\(isUpcoming ? "upcoming" : session.unseenResponses > 0 ? "unread" : "latest")_\(session.id)")
    }
}
