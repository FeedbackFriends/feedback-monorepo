import ComposableArchitecture
import Foundation
import Domain
import OpenAPI

public extension ManagerData {
    init(_ dto: Components.Schemas.ManagerDataDto) {
        let questionAnalytics = dto.questionAnalytics.map(ManagerQuestionAnalytics.init)
        self.init(
            activities: .init(
                uniqueElements: dto.activities.map { activity in
                    Activity(activity, questionAnalytics: questionAnalytics)
                }
            ),
            notificationHistory: .init(dto.notificationHistory),
            questionAnalytics: questionAnalytics,
            bootstrapHash: UUID(uuidString: dto.bootstrapHash)!
        )
    }
}

public extension ManagerQuestionAnalytics {
    init(_ dto: Components.Schemas.ManagerQuestionAnalyticsDto) {
        self.init(
            questionId: UUID(uuidString: dto.questionId)!,
            questionText: dto.questionText,
            feedbackType: .init(dto.feedbackType.rawValue),
            eventCount: Int(dto.eventCount),
            responseCount: Int(dto.responseCount),
            latestAskedAt: dto.latestAskedAt,
            overallSummary: dto.overallSummary.map(QuestionFeedbackSummary.init),
            timeline: dto.timeline.map(QuestionTrendPoint.init)
        )
    }
}

public extension QuestionTrendPoint {
    init(_ dto: Components.Schemas.QuestionTrendPointDto) {
        self.init(
            eventId: dto.eventId,
            eventDate: dto.eventDate,
            responseCount: Int(dto.responseCount),
            summary: dto.summary.map(QuestionFeedbackSummary.init)
        )
    }
}
