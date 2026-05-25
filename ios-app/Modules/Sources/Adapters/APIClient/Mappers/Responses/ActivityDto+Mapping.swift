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
        let currentEvent = dto.latestEvent
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
            events: events,
            isDraft: currentEvent == nil,
            invitedEmails: dto.invitedEmails,
            participants: [],
            calendarProvider: currentEvent?.calendarProvider.map(CalendarProvider.init)
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
