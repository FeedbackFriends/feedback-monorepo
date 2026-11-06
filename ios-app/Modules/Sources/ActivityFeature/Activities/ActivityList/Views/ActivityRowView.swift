import Localization
import DesignSystem
import Domain
import SwiftUI

struct ActivityCardView: View {
    let activity: Activity
    var now: Date = .now

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(activity.title)
                    .rowTitleTextStyle()
                Spacer()
            }

            PillTagView(String(appStrings: .activitySessionCount(activity.events.count)))

            if let nextEvent = activity.events.filter({ $0.date > now }).min(by: { $0.date < $1.date }) {
                Label {
                    Text(String(appStrings: .activityNextSession(L10n.Format.date(nextEvent.date, time: .shortened))))
                } icon: {
                    Image(systemName: "calendar")
                }
                .supportingTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
            } else {
                Text(String(appStrings: .activityNoUpcoming)).supportingTextStyle().foregroundStyle(Color.themeTextSecondary)
            }

            let data = ActivityInsightData(activity: activity)
            if data.feedbackEvents.isEmpty {
                Text(String(appStrings: .activityAwaitingFeedback)).captionTextStyle().foregroundStyle(Color.themeTextSecondary)
            } else {
                Label(activity.trend.insightTitle, systemImage: activity.trend.insightSymbol)
                    .supportingTextStyle()
                Text(String(appStrings: .feedbackTotalResponses(data.responseCount))).captionTextStyle().foregroundStyle(Color.themeTextSecondary)
            }
        }
        .surfaceCard(padding: 16)
    }
}

struct ActivityRowButton: View {
    let activity: Activity
    var now: Date = .now
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ActivityCardView(activity: activity, now: now)
        }
        .buttonStyle(.plain)
    }
}
