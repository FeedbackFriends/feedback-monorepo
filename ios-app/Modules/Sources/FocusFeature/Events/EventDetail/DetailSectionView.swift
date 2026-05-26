import Domain
import DesignSystem
import SwiftUI

struct DetailSectionView: View {
    
    let detail: Event
    let agenda: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                detailSectionView
                eventPinSectionView
                    .padding(.top, 4)
                questionsSectionView
                    .padding(.top, 4)
            }
            .padding()
            .padding(.bottom, 80)
        }
        .scrollIndicators(.hidden)
        .background(Color.themeBackground)
        .lineSpacing(5)
        .foregroundStyle(Color.themeText)
    }
}

private extension DetailSectionView {
    
    var detailSectionView: some View {
        VStack(alignment: .leading) {
            SectionHeaderView("Details")
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    if let agenda, !agenda.isEmpty {
                        Text("Agenda")
                            .rowTitleTextStyle()
                        Text(agenda)
                            .multilineTextAlignment(.leading)
                            .supportingTextStyle()
                    }
                    Text("Date")
                        .rowTitleTextStyle()
                    Text(detail.formattedDate)
                        .supportingTextStyle()
                    Text("Duration")
                        .rowTitleTextStyle()
                    Text(detail.durationText)
                        .supportingTextStyle()
                    if let location = detail.location, !location.isEmpty {
                        Text("Location")
                            .rowTitleTextStyle()
                        Text(location)
                            .supportingTextStyle()
                    }
                    if let calendarProviderName = detail.calendarProviderName {
                        Text("Calendar")
                            .rowTitleTextStyle()
                        Text(calendarProviderName)
                            .supportingTextStyle()
                    }
                    if let totalFeedback = detail.overallFeedbackSummary {
                        HStack {
                            Text("\(totalFeedback.responses) responses")
                                .captionTextStyle()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.themeBackground)
                        .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(15)
                if let feedback = detail.overallFeedbackSummary {
                    FeedbackPercentageBarView(feedback: feedback.segmentationStats)
                } else {
                    EmptyFeedbackSegmentationStatsView()
                }
            }
            .bodyTextStyle()
            .background(Color.themeSurface)
            .cornerRadius(14)
        }
    }
    
    @ViewBuilder
    var eventPinSectionView: some View {
        VStack(alignment: .leading) {
            SectionHeaderView("Pin code")
            VStack(alignment: .trailing, spacing: 12) {
                if let pinCode = detail.pinCode?.value {
                    Text("\(pinCode)")
                        .frame(maxWidth: .infinity)
                        .largeTitleTextStyle()
                        .kerning(10)
                        .padding(.vertical, 12)
                        .overlay(
                            alignment: .trailing,
                            content: {
                                ShareLink(item: pinCode) {
                                    HStack {
                                        Image.copyActionIcon
                                    }
                                    .padding(.trailing, 12)
                                }
                                .buttonStyle(PrimaryTextButtonStyle())
                                .frame(maxHeight: .infinity)
                            }
                        )
                        .background(Color.themeSurface)
                        .cornerRadius(14)
                } else {
                    HStack(spacing: 6) {
                        Image.expiredStatusIcon
                            .foregroundColor(Color.themeVerySad)
                            .fontWeight(.semibold)
                        
                        Text("Expired")
                            .supportingTextStyle()
                            .foregroundColor(Color.themeVerySad)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.themeSurface)
                    .cornerRadius(14)
                }
            }
            .frame(maxWidth: .infinity)
            .bodyTextStyle()
        }
    }
    
    @ViewBuilder
    var questionsSectionView: some View {
        VStack(alignment: .leading) {
            SectionHeaderView("Questions")
            ForEach(Array(zip(detail.questionsSnapshot.indices, detail.questionsSnapshot)), id: \.0) { index, question in
                QuestionView(question: question, index: index)
                    .disabled(detail.overallFeedbackSummary == nil)
                
            }
        }
    }
}

struct QuestionView: View {
    let question: ManagerQuestion
    let index: Int
    @State private var isExpanded: Bool = true
    var body: some View {
        GroupBox {
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Comments")
                            .rowTitleTextStyle()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if question.feedbackSummary == nil {
                            Text("No comments yet")
                                .bodyTextStyle()
                                .padding(.vertical, 8)
                        } else {
                            ForEach(question.feedback.sorted(by: {
                                $0.createdAt > $1.createdAt
                            })) { feedback in
                                FeedbackCommentRowView(feedback: feedback)
                            }
                        }
                    }
                    .padding(.top, 16)
                    .foregroundStyle(Color.themeTextSecondary)
                    
                },
                label: {
                    VStack(spacing: 10) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 8) {
                                    Text("Question \(index + 1)")
                                        .supportingTextStyle()
                                    HStack {
                                        question.feedbackType.image
                                            .resizable()
                                            .frame(width: 10, height: 10)
                                        Text(question.feedbackType.title)
                                            .captionTextStyle()
                                            .foregroundStyle(Color.themeTextSecondary)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.themeBackground)
                                    .clipShape(Capsule())
                                }
                                Text(question.questionText)
                                    .captionTextStyle()
                                    .multilineTextAlignment(.leading)
                                if let emojiSummary = question.feedbackSummary?.emojiQuestionFeedbackSummary {
                                    QuestionEmojiSummaryView(emojiSummary: emojiSummary)
                                } else if let thumpsSummary = question.feedbackSummary?.thumpsQuestionFeedbackSummary {
                                    QuestionThumpsSummaryView(thumpsSummary: thumpsSummary)
                                } else if let opinionSummary = question.feedbackSummary?.opinionQuestionFeedbackSummary {
                                    QuestionOpinionSummaryView(opinionSummary: opinionSummary)
                                } else if let zeroToTenSummary = question.feedbackSummary?.zeroToTenQuestionFeedbackSummary {
                                    QuestionZeroToTenSummaryView(zeroToTenSummary: zeroToTenSummary)
                                }
                            }
                        }
                        .padding(.top, 16)
                        .padding(.trailing, 16)
                    }
                }
            )
            .padding(.horizontal, 16)
            
            Color.clear.frame(height: 10)
        }
        .groupBoxStyle(CustomGroupBoxStyle())
    }
}

#Preview("With feedback") {
    let activity = Activity.mock()
    NavigationStack {
        DetailSectionView(
            detail: Event.mock(),
            agenda: activity.agenda
        )
        .navigationTitle("Session with feedback")
    }
}

#Preview("Empty feedback") {
    let activity = Activity.mockEmpty
    NavigationStack {
        DetailSectionView(
            detail: Event.mock(),
            agenda: activity.agenda
        )
        .navigationTitle("Session empty feedback")
    }
}
