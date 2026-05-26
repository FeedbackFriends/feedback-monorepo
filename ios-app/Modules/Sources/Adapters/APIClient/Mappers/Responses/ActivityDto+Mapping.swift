import Foundation
import Domain
import OpenAPI

public extension ManagerQuestion {
    init(
        _ dto: Components.Schemas.QuestionDto,
        analytics: ManagerQuestionAnalytics? = nil
    ) {
        self.init(
            id: UUID(uuidString: dto.id)!,
            questionText: dto.text,
            feedbackType: FeedbackType(dto.feedbackType.rawValue),
            feedback: [],
            feedbackSummary: analytics?.overallSummary
        )
    }
}

public extension Activity {
    init(
        _ dto: Components.Schemas.ActivityDto,
        questionAnalytics: [ManagerQuestionAnalytics] = []
    ) {
        let analyticsById = questionAnalytics.reduce(into: [UUID: ManagerQuestionAnalytics]()) { partialResult, analytics in
            partialResult[analytics.questionId] = analytics
        }
        let analyticsByNormalizedText = questionAnalytics.reduce(into: [String: ManagerQuestionAnalytics]()) { partialResult, analytics in
            let key = analytics.questionText.normalizedQuestionKey
            guard partialResult[key] == nil else { return }
            partialResult[key] = analytics
        }
        let events = dto.events
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
            date: .distantPast,
            pinCode: nil,
            durationInMinutes: 0,
            location: nil,
            ownerInfo: .init(dto.owner),
            trend: .init(dto.trend),
            overallFeedbackSummary: nil,
            questions: dto.currentQuestions.map { question in
                let analytics = UUID(uuidString: question.id).flatMap { analyticsById[$0] }
                    ?? analyticsByNormalizedText[question.text.normalizedQuestionKey]
                return .init(question, analytics: analytics)
            },
            events: events,
            isDraft: dto.events.isEmpty,
            invitedEmails: dto.invitedEmails,
            participants: [],
            calendarProvider: nil
        )
    }
}

private extension String {
    var normalizedQuestionKey: String {
        trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
