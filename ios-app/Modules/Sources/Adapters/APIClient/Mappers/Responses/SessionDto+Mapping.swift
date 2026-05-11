import Domain
import OpenAPI
import Foundation

public extension CalendarProvider {
    init(_ payload: Components.Schemas.EventDto.CalendarProviderPayload) {
        self.init(payload.rawValue)
    }
}

public extension OverallFeedbackSummary {
    init(_ dto: Components.Schemas.OverallFeedbackSummaryDto) {
        self.init(
            segmentationStats: .init(dto.segmentationStats),
            countStats: .init(dto.countStats),
            unseenResponses: Int(dto.unseenResponses),
            responses: Int(dto.responses)
        )
    }
}

public extension Event {
    init(_ dto: Components.Schemas.EventDto) {
        self.init(
            id: UUID(uuidString: dto.id)!,
            date: dto.date,
            pinCode: dto.pinCode.map(PinCode.init(value:)),
            createdFromMailListener: dto.createdFromMailListener,
            durationInMinutes: Int(dto.durationInMinutes),
            location: dto.location,
            calendarEventId: dto.calendarEventId,
            averageRating: dto.averageRating,
            overallFeedbackSummary: dto.overallFeedbackSummary.map(OverallFeedbackSummary.init),
            questionsSnapshot: dto.questionsSnapshot.map { .init($0) },
            calendarProvider: dto.calendarProvider.map(CalendarProvider.init)
        )
    }
}

public extension FeedbackSegmentationStats {
    init(_ dto: Components.Schemas.OverallFeedbackSegmentationStatsDto) {
        self.init(
            verySadPercentage: dto.verySadPercentage,
            sadPercentage: dto.sadPercentage,
            happyPercentage: dto.happyPercentage,
            veryHappyPercentage: dto.veryHappyPercentage
        )
    }
}

public extension FeedbackCountStats {
    init(_ dto: Components.Schemas.OverallFeedbackCountStatsDto) {
        self.init(
            verySadCount: Int(dto.verySadCount),
            sadCount: Int(dto.sadCount),
            happyCount: Int(dto.happyCount),
            veryHappyCount: Int(dto.veryHappyCount),
            commentsCount: Int(dto.commentsCount)
        )
    }
}

public extension QuestionFeedbackSummary {
    init(_ dto: Components.Schemas.QuestionFeedbackSummaryDto) {
        self.init(
            emojiQuestionFeedbackSummary: dto.emojiQuestionFeedbackSummary.map(EmojiQuestionFeedbackSummary.init),
            thumpsQuestionFeedbackSummary: dto.thumpsQuestionFeedbackSummary.map(ThumpsQuestionFeedbackSummary.init),
            opinionQuestionFeedbackSummary: dto.opinionQuestionFeedbackSummary.map(OpinionQuestionFeedbackSummary.init),
            zeroToTenQuestionFeedbackSummary: dto.zeroToTenQuestionFeedbackSummary.map(ZeroToTenQuestionFeedbackSummary.init)
        )
    }
}

public extension EmojiQuestionFeedbackSummary {
    init(_ dto: Components.Schemas.EmojiQuestionFeedbackSummary) {
        self.init(
            countVerySad: Int(dto.countVerySad),
            countSad: Int(dto.countSad),
            countHappy: Int(dto.countHappy),
            countVeryHappy: Int(dto.countVeryHappy),
            percentageVerySad: dto.percentageVerySad,
            percentageSad: dto.percentageSad,
            percentageHappy: dto.percentageHappy,
            percentageVeryHappy: dto.percentageVeryHappy
        )
    }
}

public extension ThumpsQuestionFeedbackSummary {
    init(_ dto: Components.Schemas.ThumpsQuestionFeedbackSummary) {
        self.init(
            countUp: Int(dto.countUp),
            countDown: Int(dto.countDown),
            percentageUp: dto.percentageUp,
            percentageDown: dto.percentageDown
        )
    }
}

public extension OpinionQuestionFeedbackSummary {
    init(_ dto: Components.Schemas.OpinionQuestionFeedbackSummary) {
        self.init(
            countStronglyAgree: Int(dto.countStronglyAgree),
            countAgree: Int(dto.countAgree),
            countStronglyDisagree: Int(dto.countStronglyDisagree),
            countDisagree: Int(dto.countDisagree),
            percentageStronglyAgree: dto.percentageStronglyAgree,
            percentageAgree: dto.percentageAgree,
            percentageStronglyDisagree: dto.percentageStronglyDisagree,
            percentageDisagree: dto.percentageDisagree
        )
    }
}

public extension ZeroToTenQuestionFeedbackSummary {
    init(_ dto: Components.Schemas.ZeroToTenQuestionFeedbackSummary) {
        self.init(
            percentageValue0: dto.percentageValue0,
            percentageValue1: dto.percentageValue1,
            percentageValue2: dto.percentageValue2,
            percentageValue3: dto.percentageValue3,
            percentageValue4: dto.percentageValue4,
            percentageValue5: dto.percentageValue5,
            percentageValue6: dto.percentageValue6,
            percentageValue7: dto.percentageValue7,
            percentageValue8: dto.percentageValue8,
            percentageValue9: dto.percentageValue9,
            percentageValue10: dto.percentageValue10,
            countValue0: Int(dto.countValue0),
            countValue1: Int(dto.countValue1),
            countValue2: Int(dto.countValue2),
            countValue3: Int(dto.countValue3),
            countValue4: Int(dto.countValue4),
            countValue5: Int(dto.countValue5),
            countValue6: Int(dto.countValue6),
            countValue7: Int(dto.countValue7),
            countValue8: Int(dto.countValue8),
            countValue9: Int(dto.countValue9),
            countValue10: Int(dto.countValue10)
        )
    }
}
