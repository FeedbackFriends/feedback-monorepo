import ComposableArchitecture
import Foundation
import Domain
import OpenAPI

public extension ManagerData {
    init(_ dto: Components.Schemas.ManagerDataDto) {
        self.init(
            activities: .init(
                uniqueElements: dto.activities.map { activity in
                    Activity(activity, questionAnalytics: dto.questionAnalytics)
                }
            ),
            notificationHistory: .init(dto.notificationHistory),
            recentlyUsedQuestions: Set(dto.questionAnalytics.map(RecentlyUsedQuestions.init)),
            feedbackSessionHash: UUID(uuidString: dto.bootstrapHash)!
        )
    }
}

public extension RecentlyUsedQuestions {
    init(_ dto: Components.Schemas.ManagerQuestionAnalyticsDto) {
        self.init(
            questionText: dto.questionText,
            feedbackType: .init(dto.feedbackType.rawValue),
            updatedAt: dto.latestAskedAt ?? .distantPast
        )
    }
}
