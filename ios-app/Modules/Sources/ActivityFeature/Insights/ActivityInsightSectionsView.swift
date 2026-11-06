import Localization
import DesignSystem
import Domain
import SwiftUI

struct ActivityQuestionHistoriesView: View {
    let activity: Activity
    let onEventTap: (Event) -> Void

    var body: some View {
        let data = ActivityInsightData(activity: activity)
        if !data.questions.isEmpty {
            DisclosureGroup {
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(appStrings: .insightsHistoryHelp))
                        .captionTextStyle().foregroundStyle(Color.themeTextSecondary)
                    ForEach(data.questions) { history in
                        InsightQuestionHistoryView(history: history, onEventTap: onEventTap)
                    }
                }
                .padding(.top, 12)
            } label: {
                Text(String(appStrings: .insightsQuestions)).rowTitleTextStyle()
            }
            .tint(Color.themePrimaryAction)
            .accessibilityIdentifier("activity_question_histories")
        }
    }
}

struct ActivityTrendSectionView: View {
    let activity: Activity
    let onEventTap: (Event) -> Void

    var body: some View {
        let data = ActivityInsightData(activity: activity)
        if !data.feedbackEvents.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderView(String(appStrings: .insightsTrend))
                InsightTrendView(data: data)
                if data.feedbackEvents.count == 1 {
                    Text(String(appStrings: .insightsTrendHelp)).supportingTextStyle()
                }
                if activity.events.contains(where: { $0.averageRating != nil }) {
                    Text(String(appStrings: .insightsScoreHelp))
                        .captionTextStyle().foregroundStyle(Color.themeTextSecondary)
                    MeetingQualityCardView(activity: activity, onEventTap: onEventTap)
                }
            }
        }
    }
}

private struct InsightQuestionHistoryView: View {
    let history: InsightQuestionHistory
    let onEventTap: (Event) -> Void

    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(history.sessions) { session in
                    VStack(alignment: .leading, spacing: 8) {
                        Button { onEventTap(session.event) } label: {
                            HStack {
                                Text(L10n.Format.date(session.event.date))
                                Spacer()
                                Text(String(appStrings: .feedbackResponseCount(session.question.feedback.count)))
                                Image(systemName: "chevron.right").accessibilityHidden(true)
                            }
                            .captionTextStyle()
                        }
                        .buttonStyle(.plain)
                        InsightQuestionSummaryView(question: session.question)
                    }
                    Divider()
                }
            }
            .padding(.top, 12)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(history.id.text).rowTitleTextStyle()
                FeedbackTypeTagView(history.id.type)
                Text(String(appStrings: .activitySessionCount(history.sessions.count))).captionTextStyle()
            }
        }
        .tint(Color.themePrimaryAction)
        .surfaceCard(padding: 16)
    }
}

private struct InsightQuestionSummaryView: View {
    let question: ManagerQuestion

    var body: some View {
        Group {
            if let summary = question.feedbackSummary?.emojiQuestionFeedbackSummary {
                QuestionEmojiSummaryView(emojiSummary: summary)
            } else if let summary = question.feedbackSummary?.thumpsQuestionFeedbackSummary {
                QuestionThumpsSummaryView(thumpsSummary: summary)
            } else if question.feedbackType == .opinion, !question.feedback.isEmpty {
                InsightOpinionSummaryView(feedback: question.feedback)
            } else if let summary = question.feedbackSummary?.zeroToTenQuestionFeedbackSummary {
                QuestionZeroToTenSummaryView(zeroToTenSummary: summary)
            } else if question.feedbackType == .comment, !question.feedback.isEmpty {
                Text(String(appStrings: .insightsOpenComments))
            } else {
                Text(String(appStrings: .insightsNoAnswers))
            }
        }
        .supportingTextStyle().foregroundStyle(Color.themeTextSecondary)
    }
}

private struct InsightOpinionSummaryView: View {
    let feedback: [Feedback]
    private let opinions: [Opinion] = [.stronglyDisagree, .disagree, .neutral, .agree, .stronglyAgree]

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(opinions, id: \.rawValue) { opinion in
                    let count = feedback.filter {
                        if case .opinion(let value, _) = $0.type { return value == opinion }
                        return false
                    }.count
                    PercentageBar(
                        percentageValue: Double(count) / Double(feedback.count) * 100,
                        countValue: count
                    ) {
                        Text(opinion.localized).frame(width: 64, height: 42).multilineTextAlignment(.center)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(String(appStrings: .insightsOpinionResponses(opinion.localized, count, feedback.count)))
                }
            }
        }
    }
}
