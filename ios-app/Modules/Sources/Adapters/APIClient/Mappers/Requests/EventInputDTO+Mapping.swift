import Domain
import Foundation
import OpenAPI
import Utility

public extension Components.Schemas.QuestionInput.FeedbackTypePayload {
    init(_ feedbackType: FeedbackType) {
        guard let payload = Self(rawValue: feedbackType.rawValue.uppercasingFirst()) else {
            fatalError("Could not create FeedbackTypePayload for \(feedbackType.rawValue.uppercasingFirst())")
        }
        self = payload
    }
}

public extension Components.Schemas.QuestionInput {
    init(_ question: EventInput.QuestionInput) {
        self.init(
            id: question.id.uuidString,
            questionText: question.questionText,
            feedbackType: .init(question.feedbackType)
        )
    }
}

public extension Components.Schemas.SessionInput {
    init(_ session: SessionInput) {
        self.init(
            activityId: session.activityId.uuidString,
            date: session.date,
            durationInMinutes: Int32(session.durationInMinutes),
            location: session.location
        )
    }
}

public extension Components.Schemas.ActivityInput {
    init(legacyEvent event: EventInput) {
        self.init(
            title: event.title,
            agenda: event.agenda,
            questions: event.questions.map(Components.Schemas.QuestionInput.init),
            runMode: .manual,
            invitedEmails: [],
            sendEmails: false
        )
    }
}
