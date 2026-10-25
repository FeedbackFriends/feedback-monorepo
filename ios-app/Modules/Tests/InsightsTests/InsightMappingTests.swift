@testable import Adapters
import Domain
import Foundation
import OpenAPI
import Testing

struct InsightMappingTests {
    @Test func snapshotUsesSessionSummaryAndStableResponseIdentity() {
        let canonicalId = UUID()
        let questionId = UUID()
        let responseId = UUID()
        let response = Components.Schemas.QuestionResponseDto(
            id: responseId.uuidString, feedbackType: .emoji, questionId: questionId.uuidString,
            comment: "Godt møde", emoji: .happy, seenByManager: false, createdAt: Date(timeIntervalSince1970: 100)
        )
        let dto = Components.Schemas.QuestionDto(
            id: questionId.uuidString, text: "Hvordan gik mødet?", feedbackType: .emoji,
            activityQuestionId: canonicalId.uuidString, feedback: [response],
            summary: .init(emojiQuestionFeedbackSummary: .init(
                countVerySad: 0, countSad: 0, countHappy: 1, countVeryHappy: 0,
                percentageVerySad: 0, percentageSad: 0, percentageHappy: 100, percentageVeryHappy: 0
            ))
        )
        let mapped = ManagerQuestion(dto)
        #expect(mapped.id == questionId)
        #expect(mapped.activityQuestionId == canonicalId)
        #expect(mapped.feedbackSummary?.emojiQuestionFeedbackSummary?.countHappy == 1)
        #expect(mapped.feedback[0].id == responseId)
        #expect(mapped.feedback == ManagerQuestion(dto).feedback)
        #expect(mapped.feedback[0].createdAt == Date(timeIntervalSince1970: 100))
        #expect(mapped.feedback[0].type == .emoji(emoji: .happy, comment: "Godt møde"))
    }

    @Test func responseMapperPreservesEveryFeedbackScale() {
        let cases: [(Components.Schemas.QuestionResponseDto, FeedbackTypeWithData)] = [
            (response(.comment, comment: "Behold pausen"), .comment(comment: "Behold pausen")),
            (response(.zeroToTen, zeroToTen: 0), .zeroToTen(zeroToTen: 0, comment: nil)),
            (response(.opinion, opinion: .neutral), .opinion(opinion: .neutral, comment: nil)),
            (response(.thumpsUpThumpsDown, thumbs: .down), .thumpsUpThumpsDown(thumbsUpThumpsDown: .down, comment: nil))
        ]
        for (dto, expected) in cases {
            #expect(Feedback(dto).type == expected)
        }
    }
}

private func response(
    _ type: Components.Schemas.QuestionResponseDto.FeedbackTypePayload,
    comment: String? = nil,
    zeroToTen: Int32? = nil,
    opinion: Components.Schemas.QuestionResponseDto.OpinionPayload? = nil,
    thumbs: Components.Schemas.QuestionResponseDto.ThumbsUpThumpsDownPayload? = nil
) -> Components.Schemas.QuestionResponseDto {
    .init(
        id: UUID().uuidString, feedbackType: type, questionId: UUID().uuidString, comment: comment,
        thumbsUpThumpsDown: thumbs, opinion: opinion, zeroToTen: zeroToTen, seenByManager: true, createdAt: .distantPast
    )
}
