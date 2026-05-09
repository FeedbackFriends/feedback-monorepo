import Foundation
import Domain
import OpenAPI

public extension ManagerQuestion {
    init(
        _ dto: Components.Schemas.QuestionDto,
        analytics: Components.Schemas.ManagerQuestionAnalyticsDto? = nil
    ) {
        self.init(
            id: UUID(uuidString: dto.id) ?? UUID(),
            questionText: dto.text,
            feedbackType: analytics.map { .init($0.feedbackType.rawValue) } ?? .comment,
            feedback: [],
            feedbackSummary: analytics?.overallSummary.map(QuestionFeedbackSummary.init)
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
        let currentSession = dto.latestSession
        let relatedSessions = dto.sessions
            .sorted(by: { $0.date > $1.date })
            .map { sessionDto in
                Activity(
                    id: UUID(uuidString: sessionDto.id) ?? UUID(),
                    title: dto.title,
                    agenda: dto.agenda,
                    date: sessionDto.date,
                    pinCode: sessionDto.pinCode.map(PinCode.init(value:)),
                    durationInMinutes: Int(sessionDto.durationInMinutes),
                    location: sessionDto.location,
                    ownerInfo: .init(dto.owner),
                    trend: .insufficientData,
                    overallFeedbackSummary: sessionDto.overallFeedbackSummary.map(OverallFeedbackSummary.init),
                    questions: dto.currentQuestions.map { question in
                        let analytics = UUID(uuidString: question.id).flatMap { analyticsById[$0] }
                        return .init(question, analytics: analytics)
                    },
                    isDraft: false,
                    invitedEmails: dto.invitedEmails,
                    participants: [],
                    calendarProvider: sessionDto.calendarProvider.map(CalendarProvider.init)
                )
            }
        self.init(
            id: UUID(uuidString: dto.id) ?? UUID(),
            title: dto.title,
            agenda: dto.agenda,
            date: currentSession?.date ?? .distantPast,
            pinCode: currentSession?.pinCode.map(PinCode.init(value:)),
            durationInMinutes: Int(currentSession?.durationInMinutes ?? 0),
            location: currentSession?.location,
            ownerInfo: .init(dto.owner),
            trend: .init(dto.trend),
            overallFeedbackSummary: currentSession?.overallFeedbackSummary.map(OverallFeedbackSummary.init),
            questions: dto.currentQuestions.map { question in
                let analytics = UUID(uuidString: question.id).flatMap { analyticsById[$0] }
                return .init(question, analytics: analytics)
            },
            relatedSessions: relatedSessions,
            isDraft: currentSession == nil,
            invitedEmails: dto.invitedEmails,
            participants: [],
            calendarProvider: currentSession?.calendarProvider.map(CalendarProvider.init)
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
    var latestSession: Components.Schemas.SessionDto? {
        sessions.max(by: { $0.date < $1.date })
    }
}
