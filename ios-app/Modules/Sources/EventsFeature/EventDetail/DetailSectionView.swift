import Domain
import DesignSystem
import SwiftUI

struct DetailSectionView: View {
    
    let event: ManagerEvent
    
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
            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11, weight: .semibold))
                Text("Meeting details (from your calendar)")
            }
            .sectionHeaderStyle()
            .padding(.leading, 18)
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    if let agenda = event.agenda {
                        Text("Agenda")
                            .font(.montserratSemiBold, 13)
                        Text(agenda)
                            .multilineTextAlignment(.leading)
                            .font(.montserratRegular, 13)
                    }
                    Text("Date")
                        .font(.montserratSemiBold, 13)
                    Text(event.formattedDate)
                        .font(.montserratRegular, 13)
                    Text("Participants")
                        .font(.montserratSemiBold, 13)
                    Text(participantLabel(event.participants.count))
                        .font(.montserratRegular, 13)
                    Text("Inviterede uden for lets grow: \(event.invitedEmails.count)")
                    if let totalFeedback = event.overallFeedbackSummary {
                        HStack {
                            Text("\(totalFeedback.responses) responses")
                                .font(.montserratMedium, 12)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.themeBackground)
                        .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(15)
                if let feedback = event.overallFeedbackSummary {
                    FeedbackPercentageBarView(feedback: feedback.segmentationStats)
                } else {
                    EmptyFeedbackSegmentationStatsView()
                }
            }
            .font(.montserratRegular, 14)
            .background(Color.themeSurfaceSecondary)
            .cornerRadius(14)
        }
    }
    
    @ViewBuilder
    var eventPinSectionView: some View {
        VStack(alignment: .leading) {
            Text("PIN CODE")
                .sectionHeaderStyle()
                .padding(.leading, 18)
            VStack(alignment: .trailing, spacing: 12) {
                if let pinCode = event.pinCode?.value {
                    Text("\(pinCode)")
                        .frame(maxWidth: .infinity)
                        .font(.montserratMedium, 30)
                        .kerning(10)
                        .padding(.vertical, 12)
                        .overlay(
                            alignment: .trailing,
                            content: {
                                ShareLink(item: pinCode) {
                                    HStack {
                                        Image.documentOnDocument
                                            .font(.system(size: 16, weight: .regular))
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
                        Image.clockBadgeXmark
                            .foregroundColor(.red)
                            .font(.system(size: 14, weight: .semibold))
                        
                        Text("Expired")
                            .font(.montserratRegular, 12)
                            .foregroundColor(.red)
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
            .font(.montserratRegular, 14)
        }
    }
    
    @ViewBuilder
    var questionsSectionView: some View {
        VStack(alignment: .leading) {
            Text("FEEDBACK QUESTIONS")
                .sectionHeaderStyle()
                .padding(.leading, 18)
            ForEach(Array(zip(event.questions.indices, event.questions)), id: \.0) { index, question in
                QuestionView(question: question, index: index)
                    .disabled(event.overallFeedbackSummary == nil)
                
            }
        }
    }

    func participantLabel(_ count: Int) -> String {
        if count == 0 {
            return "No participants yet"
        }
        return "\(count) participant\(count == 1 ? "" : "s")"
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
                            .font(.montserratSemiBold, 13)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if question.feedbackSummary == nil {
                            Text("No comments yet")
                                .font(.montserratRegular, 14)
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
                                        .font(.montserratRegular, 13)
                                    HStack {
                                        question.feedbackType.image
                                            .resizable()
                                            .frame(width: 10, height: 10)
                                        Text(question.feedbackType.title)
                                            .font(.montserratMedium, 9)
                                            .foregroundStyle(Color.themeTextSecondary)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.themeBackground)
                                    .clipShape(Capsule())
                                }
                                Text(question.questionText)
                                    .font(.montserratMedium, 12)
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
    NavigationStack {
        DetailSectionView(
            event: .mock()
        )
        .navigationTitle("Session with feedback")
    }
}

#Preview("Empty feedback") {
    NavigationStack {
        DetailSectionView(
            event: .mockEmpty
        )
        .navigationTitle("Session empty feedback")
    }
}
