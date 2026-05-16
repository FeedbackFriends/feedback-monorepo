import Domain
import SwiftUI
import DesignSystem

struct FeedbackPercentageBarView: View {
    let feedback: FeedbackSegmentationStats
    var body: some View {
        GeometryReader { proxy in
            let withPercent = proxy.size.width / 100
            HStack(spacing: 0) {
                Color.themeVerySad.frame(width: feedback.verySadPercentage * withPercent)
                Color.themeSad.frame(width: feedback.sadPercentage * withPercent)
                Color.themeHappy.frame(width: feedback.happyPercentage * withPercent)
                Color.themeVeryHappy.frame(width: feedback.veryHappyPercentage * withPercent)
            }
            .unredacted()
        }
        .frame(minHeight: 10)
    }
}

struct EmptyFeedbackSegmentationStatsView: View {
    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                Color.gray.opacity(0.2).frame(width: proxy.size.width)
            }
            .unredacted()
        }
        .frame(minHeight: 24)
        .overlay(alignment: .center) {
            Text("No feedback received")
                .font(.montserratMedium, 12)
                .foregroundColor(Color.themeTextSecondary)
        }
    }
}
