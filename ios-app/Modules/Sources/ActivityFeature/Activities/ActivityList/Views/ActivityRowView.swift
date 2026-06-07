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
