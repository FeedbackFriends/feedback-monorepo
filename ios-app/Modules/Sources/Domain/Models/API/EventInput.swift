import Foundation
import Utility

public struct EventInput: Equatable, Sendable {
    public var title: String
    public var agenda: String?
    public var date: Date
    public var durationInMinutes: Int
    public var location: String?
    public var questions: [QuestionInput]
    
    public struct QuestionInput: Equatable, Hashable, Sendable, Identifiable {
        public var id: UUID
        public var questionText: String
        public var feedbackType: FeedbackType
        
        public init(id: UUID = UUID(), questionText: String, feedbackType: FeedbackType) {
            self.id = id
            self.questionText = questionText
            self.feedbackType = feedbackType
        }
    }
    
    public init(
        title: String = "",
        agenda: String? = nil,
        date: Date = Date().roundedUpcoming5Min(),
        durationInMinutes: Int = 30,
        location: String? = nil,
        questions: [QuestionInput] = []
    ) {
        self.title = title
        self.agenda = agenda
        self.date = date
        self.durationInMinutes = durationInMinutes
        self.location = location
        self.questions = questions
    }
}

public extension EventInput {
     init(
        _ activity: Activity
    ) {
        self.init(
            title: activity.title,
            agenda: activity.agenda,
            date: activity.date,
            durationInMinutes: activity.durationInMinutes,
            location: activity.location,
            questions: activity.questions.map { .init(questionText: $0.questionText, feedbackType: $0.feedbackType) }
        )
    }
}
