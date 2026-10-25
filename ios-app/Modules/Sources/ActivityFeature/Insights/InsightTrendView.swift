import DesignSystem
import Domain
import SwiftUI

struct InsightTrendView: View {
    let data: ActivityInsightData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(data.activity.trend.insightTitle, systemImage: data.activity.trend.insightSymbol).rowTitleTextStyle()
            if data.activity.trend.direction != .insufficientData {
                Text("Sammenligner de seneste \(data.activity.trend.comparedEventCount) sessioner med rating · \(data.comparisonResponseCount) ratingsvar")
                    .captionTextStyle().foregroundStyle(Color.themeTextSecondary)
            }
        }
    }
}
