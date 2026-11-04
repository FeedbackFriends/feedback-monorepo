import Localization
import Domain
import DesignSystem
import SwiftUI

public struct EventListSection: Identifiable, Equatable, Sendable {
    public enum SectionID: String, Sendable {
        case current, upcoming, previous
    }

    public let id: SectionID
    public let title: String
    public let events: [Event]

    public init(id: SectionID, title: String, events: [Event]) {
        self.id = id
        self.title = title
        self.events = events
    }
}

public struct EventListView: View {
    let sections: [EventListSection]
    let eventTitle: String
    let onEventTap: ((Event) -> Void)?
    let sectionTrailingContent: ((EventListSection) -> AnyView?)?

    public init(
        sections: [EventListSection],
        eventTitle: String,
        onEventTap: ((Event) -> Void)? = nil,
        sectionTrailingContent: ((EventListSection) -> AnyView?)? = nil
    ) {
        self.sections = sections
        self.eventTitle = eventTitle
        self.onEventTap = onEventTap
        self.sectionTrailingContent = sectionTrailingContent
    }

    public var body: some View {
        LazyVStack(alignment: .leading, spacing: 18) {
            if sections.isEmpty {
                VStack(alignment: .center, spacing: 14) {
                    VStack(spacing: 6) {
                        Text(String(appStrings: .sessionEmptyTitle))
                            .rowTitleTextStyle()
                            .foregroundStyle(Color.themeText)

                        Text(String(appStrings: .sessionEmptyMessage))
                            .supportingTextStyle()
                            .foregroundStyle(Color.themeTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 50)
                .padding(.top, 50)

            } else {
                ForEach(sections) { section in
                    ContentSectionView(
                        title: section.title,
                        trailingContent: sectionTrailingContent?(section)
                    ) {
                        ForEach(section.events) { event in
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
    @Environment(\.referenceDate) private var referenceDate
    @Environment(\.calendar) private var calendar
    let event: Event
    let eventTitle: String

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                header
                if hasLocation {
                    Divider()
                    metadata
                }
                feedbackSummary
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.themeText)
            .padding(.all, 12)

            feedbackBar
        }
        .surfaceCard(padding: 0)
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
                PillTagView(
                    String(appStrings: .feedbackNewCount(overallFeedbackSummary.unseenResponses)),
                    style: .badge,
                    foregroundColor: .themeOnPrimaryAction,
                    backgroundColor: .themeBlue
                )
                    .accessibilityLabel(String(appStrings: .feedbackNewResponses(overallFeedbackSummary.unseenResponses)))
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
            if let location = event.location, !location.isEmpty {
                metadataRow(
                    image: Image(systemName: "mappin.and.ellipse"),
                    text: location
                )
            }
        }
    }

    private var sessionTitle: String {
        if calendar.isDate(event.date, inSameDayAs: referenceDate ?? .now) {
            return String(appStrings: .sessionToday(L10n.Format.date(event.date, date: .omitted, time: .shortened)))
        }

        if calendar.isDate(event.date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: referenceDate ?? .now)!) {
            return String(appStrings: .sessionYesterday(L10n.Format.date(event.date, date: .omitted, time: .shortened)))
        }

        if calendar.isDate(event.date, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: referenceDate ?? .now)!) {
            return String(appStrings: .sessionTomorrow(L10n.Format.date(event.date, date: .omitted, time: .shortened)))
        }

        return L10n.Format.date(event.date, time: .shortened)
    }

    private var feedbackSummary: some View {
        HStack(spacing: 8) {
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
            return String(appStrings: .feedbackNoResponses)
        }

        return String(appStrings: .feedbackResponseCount(responses))
    }

    private var accessibilityLabel: String {
        String(appStrings: .sessionRowAccessibility(eventTitle, event.formattedDate, responseText))
    }

    private var hasLocation: Bool {
        guard let location = event.location else { return false }
        return !location.isEmpty
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

}
