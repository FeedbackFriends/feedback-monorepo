import DesignSystem
import Domain
import SwiftUI

struct ActivityCardView: View {
    let activity: Activity

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(activity.title)
                    .rowTitleTextStyle()
                Spacer()
            }

            Text(activity.events.count == 1 ? "1 session" : "\(activity.events.count) sessioner")
                .captionTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.themeBackground, in: Capsule())

            if let nextEvent = activity.events.filter({ $0.date > Date() }).min(by: { $0.date < $1.date }) {
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.themeSurface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct ActivityRowButton: View {
    let activity: Activity
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ActivityCardView(activity: activity)
        }
        .buttonStyle(.plain)
    }
}
