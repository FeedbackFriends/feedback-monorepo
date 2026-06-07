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
        LazyVStack(alignment: .leading, spacing: 18) {
            if todayEvents.isEmpty && comingUpEvents.isEmpty && previousEvents.isEmpty {
                VStack(alignment: .center, spacing: 14) {
                    VStack(spacing: 6) {
                        Text("Ingen sessioner endnu")
                            .rowTitleTextStyle()
                            .foregroundStyle(Color.themeText)

                        Text("Brug kalenderopsætning til fast feedback. Tilføj kun en enkelt session ved behov.")
                            .supportingTextStyle()
                            .foregroundStyle(Color.themeTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 50)
                .padding(.top, 50)

            } else {
                if !todayEvents.isEmpty {
                    CustomSection(title: "I dag") {
                        ForEach(todayEvents) { event in
                            eventListItem(event)
                        }
                    }
                }
                if !comingUpEvents.isEmpty {
                    CustomSection(title: "Kommende") {
                        ForEach(comingUpEvents) { event in
                            eventListItem(event)
                        }
                    }
                }
                if !previousEvents.isEmpty {
                    CustomSection(title: "Tidligere") {
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.themeSurface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(sessionTitle)
                .rowTitleTextStyle()
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let overallFeedbackSummary = event.overallFeedbackSummary, overallFeedbackSummary.unseenResponses > 0 {
                Text("\(overallFeedbackSummary.unseenResponses) nye")
                    .badgeTextStyle()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .foregroundStyle(Color.themeOnPrimaryAction)
                    .background(Color.themeBlue)
                    .clipShape(Capsule())
                    .accessibilityLabel("\(overallFeedbackSummary.unseenResponses) nye svar")
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

    private var sessionTitle: String {
        if event.date.isToday {
            return "I dag kl. \(event.date.formatted(date: .omitted, time: .shortened))"
        }

        return event.date.formatted(date: .abbreviated, time: .shortened)
    }

    private var feedbackSummary: some View {
        HStack(spacing: 8) {
            if let pinCode = event.pinCode?.value {
                pill(text: "#\(pinCode)", foregroundColor: Color.themeText)
            } else {
                pill(text: "Udløbet", foregroundColor: Color.themeVerySad)
            }

            Spacer(minLength: 8)

            Text(responseText)
                .captionTextStyle()
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
            return "Ingen svar endnu"
        }

        return responses == 1 ? "1 svar" : "\(responses) svar"
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
                .captionTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func pill(text: String, foregroundColor: Color) -> some View {
        Text(text)
            .captionTextStyle()
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.themeBackground, in: Capsule())
    }
}
