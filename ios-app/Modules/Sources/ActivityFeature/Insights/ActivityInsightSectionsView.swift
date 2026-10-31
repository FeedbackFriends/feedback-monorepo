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
                    Text("Hele historikken · Resultater vises på spørgsmålets egen svarskala.")
                        .captionTextStyle().foregroundStyle(Color.themeTextSecondary)
                    ForEach(data.questions) { history in
                        InsightQuestionHistoryView(history: history, onEventTap: onEventTap)
                    }
                }
                .padding(.top, 12)
            } label: {
                Text("Spørgsmål og feedback").rowTitleTextStyle()
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
                SectionHeaderView("Udvikling over tid")
                InsightTrendView(data: data)
                if data.feedbackEvents.count == 1 {
                    Text("Se udviklingen, når flere sessioner har fået feedback.").supportingTextStyle()
                }
                if activity.events.contains(where: { $0.averageRating != nil }) {
                    Text("Feedbackscore fra 0 til 5, baseret på sessionernes 0–10-svar.")
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
                                Text(session.event.date.formatted(date: .abbreviated, time: .omitted))
                                Spacer()
                                Text("\(session.question.feedback.count) svar")
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
                Text("\(history.sessions.count) sessioner").captionTextStyle()
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
                Text("Åbn sessionen for at læse kommentarerne.")
            } else {
                Text("Ingen svar på spørgsmålet i denne session.")
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
                    .accessibilityLabel("\(opinion.localized), \(count) af \(feedback.count) svar")
                }
            }
        }
    }
}
