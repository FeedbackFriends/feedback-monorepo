import Foundation
import Domain
import OpenAPI

public extension ManagerQuestion {
    init(
        _ dto: Components.Schemas.QuestionDto,
        analytics: Components.Schemas.ManagerQuestionAnalyticsDto? = nil
    ) {
        let feedbackSummary = analytics?.overallSummary.map(QuestionFeedbackSummary.init)
        let feedbackType = analytics
            .map { FeedbackType($0.feedbackType.rawValue) }
            ?? FeedbackType.inferred(from: feedbackSummary)
            ?? .comment

        self.init(
            id: UUID(uuidString: dto.id)!,
            questionText: dto.text,
            feedbackType: feedbackType,
            feedback: [],
            feedbackSummary: feedbackSummary
        )
    }
}

public extension Activity {
    init(
        _ dto: Components.Schemas.ActivityDto,
        questionAnalytics: [Components.Schemas.ManagerQuestionAnalyticsDto] = []
    ) {
        let analyticsById = questionAnalytics.reduce(into: [UUID: Components.Schemas.ManagerQuestionAnalyticsDto]()) { partialResult, analytics in
            guard let questionId = UUID(uuidString: analytics.questionId) else { return }
            partialResult[questionId] = analytics
        }
        let analyticsByNormalizedText = questionAnalytics.reduce(into: [String: Components.Schemas.ManagerQuestionAnalyticsDto]()) { partialResult, analytics in
            let key = analytics.questionText.normalizedQuestionKey
            guard partialResult[key] == nil else { return }
            partialResult[key] = analytics
        }
        let currentEvent = dto.latestEvent
        let relatedSessions = dto.events
            .sorted(by: { $0.date > $1.date })
            .map { eventDto in
                Event(
                    id: UUID(uuidString: eventDto.id)!,
                    date: eventDto.date,
                    pinCode: eventDto.pinCode.map(PinCode.init(value:)),
                    createdFromMailListener: eventDto.createdFromMailListener,
                    durationInMinutes: Int(eventDto.durationInMinutes),
                    location: eventDto.location,
                    calendarEventId: eventDto.calendarEventId,
                    averageRating: eventDto.averageRating,
                    overallFeedbackSummary: eventDto.overallFeedbackSummary.map(OverallFeedbackSummary.init),
                    questionsSnapshot: eventDto.questionsSnapshot.map { question in
                        let analytics = UUID(uuidString: question.id).flatMap { analyticsById[$0] }
                            ?? analyticsByNormalizedText[question.text.normalizedQuestionKey]
                        return .init(question, analytics: analytics)
                    },
                    calendarProvider: eventDto.calendarProvider.map(CalendarProvider.init)
                )
            }
        self.init(
            id: UUID(uuidString: dto.id)!,
            title: dto.title,
            agenda: dto.agenda,
            date: currentEvent?.date ?? .distantPast,
            pinCode: currentEvent?.pinCode.map(PinCode.init(value:)),
            durationInMinutes: Int(currentEvent?.durationInMinutes ?? 0),
            location: currentEvent?.location,
            ownerInfo: .init(dto.owner),
            trend: .init(dto.trend),
            overallFeedbackSummary: currentEvent?.overallFeedbackSummary.map(OverallFeedbackSummary.init),
            questions: dto.currentQuestions.map { question in
                let analytics = UUID(uuidString: question.id).flatMap { analyticsById[$0] }
                    ?? analyticsByNormalizedText[question.text.normalizedQuestionKey]
                return .init(question, analytics: analytics)
            },
            relatedSessions: relatedSessions,
            isDraft: currentEvent == nil,
            invitedEmails: dto.invitedEmails,
            participants: [],
            calendarProvider: currentEvent?.calendarProvider.map(CalendarProvider.init)
        )
    }
}

public extension EventWrapper {
    init(
        _ dto: Components.Schemas.ActivityDto,
        questionAnalytics: [Components.Schemas.ManagerQuestionAnalyticsDto] = []
    ) {
        self.init(
            activity: .init(dto, questionAnalytics: questionAnalytics),
            recentlyUsedQuestions: Set(questionAnalytics.map(RecentlyUsedQuestions.init))
        )
    }
}

private extension Components.Schemas.ActivityDto {
    var latestEvent: Components.Schemas.EventDto? {
        events.max(by: { $0.date < $1.date })
    }
}

private extension String {
    var normalizedQuestionKey: String {
        trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

private extension FeedbackType {
    static func inferred(from summary: QuestionFeedbackSummary?) -> FeedbackType? {
        guard let summary else { return nil }
        if summary.emojiQuestionFeedbackSummary != nil { return .emoji }
        if summary.thumpsQuestionFeedbackSummary != nil { return .thumpsUpThumpsDown }
        if summary.opinionQuestionFeedbackSummary != nil { return .opinion }
        if summary.zeroToTenQuestionFeedbackSummary != nil { return .zeroToTen }
        return nil
    }
}
