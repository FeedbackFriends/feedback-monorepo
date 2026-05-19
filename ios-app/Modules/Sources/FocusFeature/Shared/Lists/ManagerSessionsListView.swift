import Domain
import DesignSystem
import SwiftUI

public struct ManagerSessionsListView: View {
    let todayEvents: [Activity]
    let comingUpEvents: [Activity]
    let previousEvents: [Activity]
    let onEventTap: ((Activity) -> Void)?

    public init(
        todayEvents: [Activity],
        comingUpEvents: [Activity],
        previousEvents: [Activity],
        onEventTap: ((Activity) -> Void)? = nil
    ) {
        self.todayEvents = todayEvents
        self.comingUpEvents = comingUpEvents
        self.previousEvents = previousEvents
        self.onEventTap = onEventTap
    }

    public var body: some View {
        LazyVStack(alignment: .leading, spacing: 18, pinnedViews: [.sectionHeaders]) {
            if todayEvents.isEmpty && comingUpEvents.isEmpty && previousEvents.isEmpty {
                EmptyStateView(
                    message: "No sessions yet."
                )
            } else {
                if !todayEvents.isEmpty {
                    CustomSection(title: "Today") {
                        ForEach(todayEvents) { event in
                            managerEventListItem(event)
                        }
                    }
                }
                if !comingUpEvents.isEmpty {
                    CustomSection(title: "Coming up") {
                        ForEach(comingUpEvents) { event in
                            managerEventListItem(event)
                        }
                    }
                }
                if !previousEvents.isEmpty {
                    CustomSection(title: "Previous") {
                        ForEach(previousEvents) { event in
                            managerEventListItem(event)
                        }
                    }
                }
            }
        }
    }
}

private extension ManagerSessionsListView {
    func managerEventListItem(_ event: Activity) -> some View {
        Button {
            onEventTap?(event)
        } label: {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(event.title)
                            .font(.montserratSemiBold, 14)
                        Spacer()
                        if let overallFeedbackSummary = event.overallFeedbackSummary, overallFeedbackSummary.unseenResponses > 0 {
                            Text("\(overallFeedbackSummary.unseenResponses) new")
                                .font(.montserratBold, 10)
                                .padding(4)
                                .padding(.horizontal, 4)
                                .foregroundStyle(Color.themeOnPrimaryAction)
                                .background(Color.themeBlue)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                        }
                    }
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(event.date.formatted(date: .abbreviated, time: .omitted))")
                                .font(.montserratRegular, 10)
                            if let pinCode = event.pinCode?.value {
                                Text("#\(pinCode)")
                                    .font(.montserratSemiBold, 10)
                            }
                        }
                        Spacer()
                        Image.chevronRight
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.themeText.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.montserratRegular, 12)
                .foregroundColor(Color.themeText)
                .padding(.all, 10)
                if let overallFeedbackSummary = event.overallFeedbackSummary {
                    FeedbackPercentageBarView(feedback: overallFeedbackSummary.segmentationStats)
                        .frame(height: 10)
                } else {
                    EmptyFeedbackSegmentationStatsView()
                }
            }
            .background(Color.themeSurface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        }
        .buttonStyle(OpacityButtonStyle())
        .accessibilityIdentifier("manager_session_row_\(event.title)")
        .disabled(onEventTap == nil)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}
