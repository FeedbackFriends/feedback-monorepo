import DesignSystem
import SwiftUI
import Domain

struct QuestionEmojiSummaryView: View {
    let emojiSummary: EmojiQuestionFeedbackSummary
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                let iconSize: CGFloat = 18
                PercentageBar(
                    percentageValue: emojiSummary.percentageVerySad,
                    countValue: emojiSummary.countVerySad
                ) {
                    Image.verySad
                        .resizable()
                        .frame(width: iconSize, height: iconSize)
                }
                PercentageBar(
                    percentageValue: emojiSummary.percentageSad,
                    countValue: emojiSummary.countSad
                ) {
                    Image.sad
                        .resizable()
                        .frame(width: iconSize, height: iconSize)
                }
                PercentageBar(
                    percentageValue: emojiSummary.percentageHappy,
                    countValue: emojiSummary.countHappy
                ) {
                    Image.happy
                        .resizable()
                        .frame(width: iconSize, height: iconSize)
                }
                PercentageBar(
                    percentageValue: emojiSummary.percentageVeryHappy,
                    countValue: emojiSummary.countVeryHappy
                ) {
                    Image.veryHappy
                        .resizable()
                        .frame(width: iconSize, height: iconSize)
                }
            }
        }
        .font(.montserratSemiBold, 12)
    }
}

struct QuestionZeroToTenSummaryView: View {
    let zeroToTenSummary: ZeroToTenQuestionFeedbackSummary
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    PercentageBar(
                        percentageValue: zeroToTenSummary.percentageValue0,
                        countValue: zeroToTenSummary.countValue0
                    ) {
                        Text("0")
                    }
                    PercentageBar(
                        percentageValue: zeroToTenSummary.percentageValue1,
                        countValue: zeroToTenSummary.countValue1
                    ) {
                        Text("1")
                    }
                    PercentageBar(
                        percentageValue: zeroToTenSummary.percentageValue2,
                        countValue: zeroToTenSummary.countValue2
                    ) {
                        Text("2")
                    }
                    PercentageBar(
                        percentageValue: zeroToTenSummary.percentageValue3,
                        countValue: zeroToTenSummary.countValue3
                    ) {
                        Text("3")
                    }
                    PercentageBar(
                        percentageValue: zeroToTenSummary.percentageValue4,
                        countValue: zeroToTenSummary.countValue4
                    ) {
                        Text("4")
                    }
                    PercentageBar(
                        percentageValue: zeroToTenSummary.percentageValue5,
                        countValue: zeroToTenSummary.countValue5
                    ) {
                        Text("5")
                    }
                    PercentageBar(
                        percentageValue: zeroToTenSummary.percentageValue6,
                        countValue: zeroToTenSummary.countValue6
                    ) {
                        Text("6")
                    }
                    PercentageBar(
                        percentageValue: zeroToTenSummary.percentageValue8,
                        countValue: zeroToTenSummary.countValue8
                    ) {
                        Text("8")
                    }
                    PercentageBar(
                        percentageValue: zeroToTenSummary.percentageValue9,
                        countValue: zeroToTenSummary.countValue9
                    ) {
                        Text("9")
                    }
                    PercentageBar(
                        percentageValue: zeroToTenSummary.percentageValue10,
                        countValue: zeroToTenSummary.countValue10
                    ) {
                        Text("10")
                    }
                    
                }
                .padding(.vertical, 8)
            }
        }
        .font(.montserratSemiBold, 12)
    }
}

struct QuestionOpinionSummaryView: View {
    let opinionSummary: OpinionQuestionFeedbackSummary
    var body: some View {
        let barHeight: CGFloat = 25
        let barWidth: CGFloat = 45
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                PercentageBar(
                    percentageValue: opinionSummary.percentageStronglyAgree,
                    countValue: opinionSummary.countStronglyAgree
                ) {
                    Text("Strongly agree")
                        .multilineTextAlignment(.center)
                        .frame(width: barWidth)
                        .frame(height: barHeight)
                }
                PercentageBar(
                    percentageValue: opinionSummary.percentageAgree,
                    countValue: opinionSummary.countAgree
                ) {
                    Text("Agree")
                        .multilineTextAlignment(.center)
                        .frame(width: barWidth)
                        .frame(height: barHeight)
                }
                PercentageBar(
                    percentageValue: opinionSummary.percentageDisagree,
                    countValue: opinionSummary.countDisagree
                ) {
                    Text("Disagree")
                        .multilineTextAlignment(.center)
                        .frame(width: barWidth)
                        .frame(height: barHeight)
                }
                PercentageBar(
                    percentageValue: opinionSummary.percentageStronglyDisagree,
                    countValue: opinionSummary.countStronglyDisagree
                ) {
                    Text("Strongly disagree")
                        .multilineTextAlignment(.center)
                        .frame(width: barWidth)
                        .frame(height: barHeight)
                }
            }
        }
    }
}

struct QuestionThumpsSummaryView: View {
    let thumpsSummary: ThumpsQuestionFeedbackSummary
    var body: some View {
        let iconSize: CGFloat = 14
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 14) {
                PercentageBar(
                    percentageValue: thumpsSummary.percentageUp,
                    countValue: thumpsSummary.countUp
                ) {
                    Image.thumpsUp
                        .resizable()
                        .frame(width: iconSize, height: iconSize)
                        .padding(.bottom, 4)
                        .foregroundStyle(Color.themeTextSecondary.gradient)
                }
                PercentageBar(
                    percentageValue: thumpsSummary.percentageDown,
                    countValue: thumpsSummary.countDown
                ) {
                    Image.thumpsDown
                        .resizable()
                        .frame(width: iconSize, height: iconSize)
                        .padding(.bottom, 4)
                        .foregroundStyle(Color.themeTextSecondary.gradient)
                }
            }
        }
    }
}

struct PercentageBar<TopView: View>: View {
    let percentageValue: Double
    let countValue: Int
    @ViewBuilder var topView: TopView
    var body: some View {
        let height: CGFloat = 40
        let width: CGFloat = 24
        VStack(spacing: 4) {
            topView
                .font(.montserratSemiBold, 8)
            ZStack(alignment: .bottom) {
                Capsule()
                    .fill(Color.themeChartBackground)
                    .frame(width: width, height: height)
                Rectangle()
                    .fill(Color.themeChartHighlighted.gradient)
                    .frame(width: width, height: CGFloat(percentageValue) * 0.4)
                    .mask(alignment: .bottom) {
                            Capsule()
                            .frame(height: height)
                    }
            }
            Text("\(String(format: "%.0f", percentageValue))%")
                .font(.montserratRegular, 8)
        }
    }
}

#Preview {
    List {
        Section {
            QuestionEmojiSummaryView(
                emojiSummary: EmojiQuestionFeedbackSummary(
                    countVerySad: 10,
                    countSad: 10,
                    countHappy: 20,
                    countVeryHappy: 20,
                    percentageVerySad: 20,
                    percentageSad: 20,
                    percentageHappy: 30,
                    percentageVeryHappy: 30
                )
            )
        }
        Section {
            QuestionZeroToTenSummaryView(
                zeroToTenSummary: ZeroToTenQuestionFeedbackSummary(
                    percentageValue0: 0,
                    percentageValue1: 0,
                    percentageValue2: 0,
                    percentageValue3: 33,
                    percentageValue4: 33,
                    percentageValue5: 33,
                    percentageValue6: 0,
                    percentageValue7: 0,
                    percentageValue8: 0,
                    percentageValue9: 0,
                    percentageValue10: 0,
                    countValue0: 0,
                    countValue1: 0,
                    countValue2: 0,
                    countValue3: 50,
                    countValue4: 50,
                    countValue5: 50,
                    countValue6: 10,
                    countValue7: 10,
                    countValue8: 10,
                    countValue9: 10,
                    countValue10: 10
                )
            )
        }
        Section {
            QuestionOpinionSummaryView(
                opinionSummary: OpinionQuestionFeedbackSummary(
                    countStronglyAgree: 20,
                    countAgree: 20,
                    countStronglyDisagree: 100,
                    countDisagree: 100,
                    percentageStronglyAgree: 10,
                    percentageAgree: 10,
                    percentageStronglyDisagree: 40,
                    percentageDisagree: 40
                )
            )
        }
        Section {
            QuestionThumpsSummaryView(
                thumpsSummary: ThumpsQuestionFeedbackSummary(
                    countUp: 20,
                    countDown: 100,
                    percentageUp: 10,
                    percentageDown: 90
                )
            )
        }
    }
}
