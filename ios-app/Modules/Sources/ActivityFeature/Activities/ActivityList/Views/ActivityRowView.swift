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

            PillTagView(activity.events.count == 1 ? "1 session" : "\(activity.events.count) sessioner")

            if let nextEvent = activity.events.filter({ $0.date > now }).min(by: { $0.date < $1.date }) {
                Label {
                    Text("Næste session: \(nextEvent.date.formatted(date: .abbreviated, time: .shortened))")
                } icon: {
                    Image(systemName: "calendar")
                }
                .supportingTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
            } else {
                Text("Ingen kommende sessioner").supportingTextStyle().foregroundStyle(Color.themeTextSecondary)
            }

            let data = ActivityInsightData(activity: activity)
            if data.feedbackEvents.isEmpty {
                Text("Afventer første feedback").captionTextStyle().foregroundStyle(Color.themeTextSecondary)
            } else {
                Label(activity.trend.insightTitle, systemImage: activity.trend.insightSymbol)
                    .supportingTextStyle()
                Text("\(data.responseCount) svar i alt").captionTextStyle().foregroundStyle(Color.themeTextSecondary)
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
