import Domain
import DesignSystem
import SwiftUI

public struct EventListView: View {
    let todayEvents: [Event]
    let comingUpEvents: [Event]
    let previousEvents: [Event]
    let eventTitle: String
    let onEventTap: ((Event) -> Void)?

    public init(
        todayEvents: [Event],
        comingUpEvents: [Event],
        previousEvents: [Event],
        eventTitle: String,
        onEventTap: ((Event) -> Void)? = nil
    ) {
        self.todayEvents = todayEvents
        self.comingUpEvents = comingUpEvents
        self.previousEvents = previousEvents
        self.eventTitle = eventTitle
        self.onEventTap = onEventTap
    }

    public var body: some View {
        LazyVStack(alignment: .leading, spacing: 18, pinnedViews: [.sectionHeaders]) {
            if todayEvents.isEmpty && comingUpEvents.isEmpty && previousEvents.isEmpty {
                EmptyStateView(
                    title: "No sessions yet.",
                    message: "Add a session to collect feedback for this focus."
                )
            } else {
                if !todayEvents.isEmpty {
                    CustomSection(title: "Today") {
                        ForEach(todayEvents) { event in
                            eventListItem(event)
                        }
                    }
                }
                if !comingUpEvents.isEmpty {
                    CustomSection(title: "Coming up") {
                        ForEach(comingUpEvents) { event in
                            eventListItem(event)
                        }
                    }
                }
                if !previousEvents.isEmpty {
                    CustomSection(title: "Previous") {
                        ForEach(previousEvents) { event in
                            eventListItem(event)
                        }
                    }
                }
            }
        }
    }
}

private extension EventListView {
    func eventListItem(_ event: Event) -> some View {
        Button {
            onEventTap?(event)
        } label: {
            EventListItemView(event: event, eventTitle: eventTitle)
        }
        .buttonStyle(OpacityButtonStyle())
        .accessibilityIdentifier("manager_session_row_\(event.id)")
        .disabled(onEventTap == nil)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

private struct EventListItemView: View {
    let event: Event
    let eventTitle: String

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                header
                Divider()
                metadata
                feedbackSummary
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.themeText)
            .padding(.all, 12)

            feedbackBar
        }
        .background(Color.themeSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(eventTitle)
                .font(.montserratSemiBold, 14)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let overallFeedbackSummary = event.overallFeedbackSummary, overallFeedbackSummary.unseenResponses > 0 {
                Text("\(overallFeedbackSummary.unseenResponses) new")
                    .font(.montserratBold, 10)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .foregroundStyle(Color.themeOnPrimaryAction)
                    .background(Color.themeBlue)
                    .clipShape(Capsule())
                    .accessibilityLabel("\(overallFeedbackSummary.unseenResponses) new responses")
            }

            Image.chevronRight
                .resizable()
                .scaledToFit()
                .frame(width: 9, height: 9)
                .foregroundColor(.themeText.opacity(0.55))
        }
    }

    private var metadata: some View {
        VStack(alignment: .leading, spacing: 8) {
            metadataRow(
                image: Image.calendar,
                text: event.date.formatted(date: .abbreviated, time: .shortened)
            )

            metadataRow(
                image: Image(systemName: "clock"),
                text: event.durationText
            )

            if let location = event.location, !location.isEmpty {
                metadataRow(
                    image: Image(systemName: "mappin.and.ellipse"),
                    text: location
                )
            }
        }
    }

    private var feedbackSummary: some View {
        HStack(spacing: 8) {
            if let pinCode = event.pinCode?.value {
                pill(text: "#\(pinCode)", foregroundColor: Color.themeText)
            } else {
                pill(text: "Expired", foregroundColor: Color.themeVerySad)
            }

            Spacer(minLength: 8)

            Text(responseText)
                .font(.montserratSemiBold, 11)
                .foregroundStyle(Color.themeTextSecondary)
        }
    }

    @ViewBuilder
    private var feedbackBar: some View {
        if let overallFeedbackSummary = event.overallFeedbackSummary {
            FeedbackPercentageBarView(feedback: overallFeedbackSummary.segmentationStats)
                .frame(height: 10)
        } else {
            EmptyFeedbackSegmentationStatsView()
                .frame(height: 24)
        }
    }

    private var responseText: String {
        guard let responses = event.overallFeedbackSummary?.responses else {
            return "No responses yet"
        }

        return responses == 1 ? "1 response" : "\(responses) responses"
    }

    private var accessibilityLabel: String {
        "\(eventTitle), \(event.formattedDate), \(responseText)"
    }

    private func metadataRow(image: Image, text: String) -> some View {
        HStack(spacing: 8) {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 13, height: 13)
                .foregroundStyle(Color.themeTextSecondary)

            Text(text)
                .font(.montserratRegular, 11)
                .foregroundStyle(Color.themeTextSecondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func pill(text: String, foregroundColor: Color) -> some View {
        Text(text)
            .font(.montserratSemiBold, 10)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.themeBackground)
            .clipShape(Capsule())
    }
}
