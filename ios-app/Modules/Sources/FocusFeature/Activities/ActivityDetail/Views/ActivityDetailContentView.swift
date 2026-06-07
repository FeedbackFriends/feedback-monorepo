import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

struct ActivityDetailContentView: View {
    @Bindable var store: StoreOf<ActivityDetail>
    let activity: Activity

    var body: some View {
        let sessionGrouping = ActivityDetailSessionGrouping(events: activity.events)

        return screenBody(sessionGrouping: sessionGrouping)
            .modifier(ActivityDetailSheetsModifier(store: store))
            .modifier(ActivityDetailNavigationModifier(store: store))
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }

    private func screenBody(sessionGrouping: ActivityDetailSessionGrouping) -> some View {
        ScrollView {
            contentStack(sessionGrouping: sessionGrouping)
        }
        .scrollIndicators(.hidden)
        .background(Color.themeBackground.ignoresSafeArea())
        .lineSpacing(5)
        .foregroundStyle(Color.themeText)
        .navigationTitle(activity.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ViewBuilder
    private func contentStack(sessionGrouping: ActivityDetailSessionGrouping) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if activity.events.isEmpty {
                ActivityDetailHowItWorksView {
                    UIPasteboard.general.string = "feedback@letsgrow.dk"
                }
            } else {
                meetingQualitySection(activity)

                if !sessionGrouping.activeSections.isEmpty {
                    sessionsSection(
                        sessionSections: sessionGrouping.activeSections,
                        eventTitle: activity.title,
                        showsAllSessionsButton: sessionGrouping.hasSessionsOutsideActive
                    )
                }
            }
        }
        .padding()
        .padding(.bottom, 24)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    store.send(.showHowItWorksButtonTap)
                } label: {
                    Label("Fra kalender til feedback", systemImage: "questionmark.circle")
                }

                Button {
                    store.send(.createEventButtonTapped)
                } label: {
                    Label("Opret session", systemImage: "plus")
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

    private func sessionsSection(
        sessionSections: [EventListSection],
        eventTitle: String,
        showsAllSessionsButton: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            EventListView(
                sections: sessionSections,
                eventTitle: eventTitle,
                onEventTap: { store.send(.eventTapped($0)) },
                sectionTrailingContent: { section in
                    guard showsAllSessionsButton, section.title == "Aktuelt" else {
                        return nil
                    }

                    return AnyView(seeAllSessionsButton)
                }
            )
        }
    }

    private func meetingQualitySection(_ activity: Activity) -> some View {
        VStack(alignment: .leading) {
            SectionHeaderView("Feedback over tid")

            MeetingQualityCardView(
                activity: activity,
                showHowItWorks: {
                    store.send(.showHowItWorksButtonTap)
                },
                onEventTap: { event in
                    store.send(.eventTapped(event))
                }
            )
        }
    }

    private var seeAllSessionsButton: some View {
        Button {
            store.send(.showAllSessionsButtonTapped)
        } label: {
            Text("Se alle")
                .captionTextStyle()
                .foregroundStyle(Color.themePrimaryAction)
        }
        .buttonStyle(OpacityButtonStyle())
        .accessibilityIdentifier("activity_detail_see_all_sessions_button")
    }
}

private struct ActivityDetailSheetsModifier: ViewModifier {
    @Bindable var store: StoreOf<ActivityDetail>

    func body(content: Content) -> some View {
        content
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
    }
}

private struct ActivityDetailNavigationModifier: ViewModifier {
    @Bindable var store: StoreOf<ActivityDetail>

    func body(content: Content) -> some View {
        content
            .navigationDestination(
                item: $store.scope(
                    state: \.destination?.eventDetail,
                    action: \.destination.eventDetail
                )
            ) { eventDetailStore in
                EventDetailFeatureView(store: eventDetailStore)
            }
            .navigationDestination(
                item: $store.scope(
                    state: \.destination?.sessionList,
                    action: \.destination.sessionList
                )
            ) { sessionListStore in
                ActivityDetailSessionListView(store: sessionListStore)
            }
    }
}
