import ComposableArchitecture
import Domain
import DesignSystem
import SwiftUI
import Utility

public struct ManagerEventsView: View {
    
    @Bindable var store: StoreOf<ManagerEvents>
    private let onboardingTutorialButtonTap: () -> Void
    
    public init(
        store: StoreOf<ManagerEvents>,
        onboardingTutorialButtonTap: @escaping () -> Void = {}
    ) {
        self.store = store
        self.onboardingTutorialButtonTap = onboardingTutorialButtonTap
    }
    
    public var body: some View {
        let eventDetailStore = $store.scope(state: \.destination?.eventDetail, action: \.destination.eventDetail)
        let editQuestionsStore = $store.scope(state: \.destination?.editQuestions, action: \.destination.editQuestions)
        VStack(spacing: 0) {
            if store.syncStatus.visibleSyncState != .hidden {
                syncStatusChip
                    .padding(.horizontal, Theme.padding)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            ScrollView {
                VStack(spacing: 12) {
                    if feedbackEvents.isEmpty {
                        onboardingTutorialState
                    } else {
                        ForEach(feedbackEvents) { event in
                            Button {
                                store.send(.managerEventTap(event))
                            } label: {
                                feedbackCardView(event)
                            }
                        }
                    }
                }
                .padding(.horizontal, Theme.padding)
                .padding(.bottom, 80)
            }
            .lineSpacing(7)
            .scrollContentBackground(.hidden)
        }
        .animation(.easeInOut(duration: 0.2), value: store.syncStatus.visibleSyncState)
        .background(Color.themeBackground)
        .foregroundStyle(Color.themeText)
        .navigationDestination(
            item: eventDetailStore
        ) { store in
            EventDetailFeatureView(store: store)
                .navigationTitle(store.navigationTitle)
        }
        .sheet(item: editQuestionsStore) { store in
            NavigationStack {
                EditQuestionsView(store: store)
            }
        }
    }
}

extension ManagerEventsView {
    
    var feedbackEvents: [ManagerEvent] {
        let draftEvents = store.session.managerData?.draftEvents ?? []
        let managerEvents = store.session.managerData?.managerEvents.map { $0 } ?? []
        let events = draftEvents + managerEvents
        let now = Date()
        let upcoming = events.filter { $0.date >= now }.sorted { $0.date < $1.date }
        let past = events.filter { $0.date < now }.sorted { $0.date > $1.date }
        return upcoming + past
    }

    @ViewBuilder
    var syncStatusChip: some View {
        switch store.syncStatus.visibleSyncState {
        case .hidden:
            EmptyView()
        case .syncing:
            chipView(
                title: "Checking calendar...",
                icon: "arrow.triangle.2.circlepath",
                tint: .themeBlue
            )
        case .synced:
            chipView(
                title: "Calendar up to date",
                icon: "checkmark.circle.fill",
                tint: .themeSuccess
            )
        }
    }

    func chipView(title: String, icon: String, tint: Color) -> some View {
        return HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(tint)
            Text(title)
                .font(.montserratMedium, 12)
                .foregroundStyle(Color.themeText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(tint.opacity(0.12))
        .overlay(
            Capsule()
                .stroke(tint.opacity(0.35), lineWidth: 1)
        )
        .clipShape(Capsule())
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func feedbackCardView(_ event: ManagerEvent) -> some View {
        let status = FeedbackDraftStatus.status(for: event)
        let feedbackSummary = event.overallFeedbackSummary
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                providerBadge(event.calendarProvider)
                VStack(alignment: .leading, spacing: 6) {
                    Text(event.title)
                        .font(.montserratSemiBold, 14)
                    Text("\(event.date.formatted(.dateTime.weekday(.abbreviated))) | \(event.date.timeFormatted())-\(event.end.timeFormatted())")
                        .font(.montserratRegular, 11)
                        .foregroundStyle(Color.themeTextSecondary)
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.themeTextSecondary)
                        Text(participantLabel(event.participants.count))
                            .font(.montserratSemiBold, 11)
                            .foregroundStyle(Color.themeTextSecondary)
                    }
                }
                Spacer()
                statusPill(status)
            }
            if let feedbackSummary, feedbackSummary.responses > 0 {
                FeedbackPercentageBarView(feedback: feedbackSummary.segmentationStats)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(Color.themeText)
        .padding(.all, 12)
        .background(Color.themeSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .lightShadow()
    }

    var onboardingTutorialState: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Set up your first feedback session")
                    .font(.montserratBold, 16)
                Text("Follow these steps, then open the full onboarding tutorial.")
                    .font(.montserratRegular, 12)
                    .foregroundStyle(Color.themeTextSecondary)
            }

            tutorialStepRow(
                icon: "1.circle.fill",
                message: "Create your meeting invite in your favorite calendar, just like you already do."
            )
            tutorialStepRow(
                icon: "2.circle.fill",
                message: "Add feedback@letsgrow.dk as a participant. That is the only extra step."
            )
            tutorialStepRow(
                icon: "3.circle.fill",
                message: "We will figure out the rest, and your draft appears in My sessions for final setup."
            )

            Button("Open onboarding tutorial") {
                onboardingTutorialButtonTap()
            }
            .buttonStyle(LargeButtonStyle())
        }
        .padding(.all, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.themeSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .lightShadow()
    }

    func tutorialStepRow(icon: String, message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.themePrimaryAction)
            Text(message)
                .font(.montserratRegular, 12)
                .foregroundStyle(Color.themeTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func participantLabel(_ count: Int) -> String {
        if count == 0 {
            return "No participants yet"
        }
        return "\(count) participant\(count == 1 ? "" : "s")"
    }

    func statusPill(_ status: FeedbackDraftStatus) -> some View {
        Text(status.title)
            .font(.montserratSemiBold, 10)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(status.accentColor)
            .background(status.accentColor.opacity(0.15))
            .clipShape(Capsule())
    }

    func providerBadge(_ provider: CalendarProvider?) -> some View {
        let config = providerBadgeConfig(provider)
        return ZStack {
            if #available(iOS 26.0, *) {
                Circle()
                    .fill(Color.clear)
                    .glassEffect()
            } else {
                Circle()
                    .fill(.ultraThinMaterial)
            }
            if let tint = config.tint {
                config.image
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(tint)
            } else {
                config.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
        }
        .frame(width: 34, height: 34)
        .overlay(Circle().stroke((config.tint ?? Color.themeTextSecondary).opacity(0.2), lineWidth: 1))
    }

    func providerBadgeConfig(_ provider: CalendarProvider?) -> ProviderBadgeConfig {
        guard let provider else {
            return ProviderBadgeConfig(
                image: Image.calendar,
                tint: Color.themeTextSecondary,
                label: "Calendar"
            )
        }
        switch provider {
        case .APPLE:
            return ProviderBadgeConfig(image: Image.iconApple, tint: Color.themeText, label: "Apple Calendar")
        case .GOOGLE:
            return ProviderBadgeConfig(image: Image.iconGoogle, tint: nil, label: "Google Calendar")
        case .MICROSOFT:
            return ProviderBadgeConfig(image: Image.iconMicrosoft, tint: nil, label: "Microsoft Outlook")
        case .ZOOM:
            return ProviderBadgeConfig(image: Image(systemName: "video.fill"), tint: Color.themeBlue, label: "Zoom")
        }
    }
}

struct ProviderBadgeConfig {
    let image: Image
    let tint: Color?
    let label: String
}

enum FeedbackDraftStatus {
    case addQuestions
    case ready
    case feedbackReceived

    static func status(for event: ManagerEvent) -> FeedbackDraftStatus {
        if let summary = event.overallFeedbackSummary, summary.responses > 0 {
            return .feedbackReceived
        }
        if event.questions.isEmpty {
            return .addQuestions
        }
        return .ready
    }

    var title: String {
        switch self {
        case .addQuestions:
            return "Add questions"
        case .ready:
            return "Ready"
        case .feedbackReceived:
            return "Feedback received"
        }
    }

    var accentColor: Color {
        switch self {
        case .addQuestions:
            return Color.themeBlue
        case .ready:
            return Color.themeSuccess
        case .feedbackReceived:
            return Color.themeBlue
        }
    }
}

#Preview("Events") {
	NavigationStack {
        ManagerEventsView(
            store: .init(
                initialState: ManagerEvents.State(
                    session: .init(value: .mock())
                ),
                reducer: {
                    ManagerEvents()
                }
            )
        )
        .navigationTitle("Events")
    }
}

#Preview("Empty") {
    NavigationStack {
        ManagerEventsView(
            store: .init(
                initialState: ManagerEvents.State(
                    session: .init(value: .empty())
                ),
                reducer: {
                    ManagerEvents()
                }
            )
        )
        .navigationTitle("Events")
    }
}
