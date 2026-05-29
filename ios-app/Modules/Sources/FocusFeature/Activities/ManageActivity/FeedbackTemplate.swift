import Foundation
import Domain
import FeedbackFlowFeature

public enum FeedbackTemplate: String, CaseIterable, Identifiable, Sendable {
    case standardMeeting
    case teamMeeting
    case retrospective
    case workshop
    case customQuestions

    public var id: String { rawValue }

    var title: String {
        switch self {
        case .standardMeeting: return "Standard meeting feedback"
        case .teamMeeting: return "Team meeting"
        case .retrospective: return "Retrospective"
        case .workshop: return "Workshop"
        case .customQuestions: return "Custom questions"
        }
    }

    var subtitle: String {
        switch self {
        case .standardMeeting:
            return "Value, clarity, and one improvement"
        case .teamMeeting:
            return "Energy, participation, and follow-up"
        case .retrospective:
            return "What worked, what should change, and overall rating"
        case .workshop:
            return "Usefulness, clarity, and open improvement"
        case .customQuestions:
            return "Start empty and write your own questions"
        }
    }

    var icon: String {
        switch self {
        case .standardMeeting: return "calendar.badge.checkmark"
        case .teamMeeting: return "person.2"
        case .retrospective: return "arrow.clockwise"
        case .workshop: return "lightbulb"
        case .customQuestions: return "square.and.pencil"
        }
    }

    var defaultQuestions: [EventInput.QuestionInput] {
        switch self {
        case .standardMeeting:
            return [
                .init(questionText: "Was this meeting valuable?", feedbackType: .emoji),
                .init(questionText: "Was the purpose clear?", feedbackType: .opinion),
                .init(questionText: "What should we improve for the next meeting?", feedbackType: .comment)
            ]

        case .teamMeeting:
            return [
                .init(questionText: "How was the energy in this meeting?", feedbackType: .emoji),
                .init(questionText: "Did you feel involved?", feedbackType: .opinion),
                .init(questionText: "What should we follow up on?", feedbackType: .comment)
            ]

        case .retrospective:
            return [
                .init(questionText: "What worked well?", feedbackType: .comment),
                .init(questionText: "What could be better?", feedbackType: .comment),
                .init(questionText: "Overall rating", feedbackType: .zeroToTen)
            ]

        case .workshop:
            return [
                .init(questionText: "How useful was the workshop?", feedbackType: .zeroToTen),
                .init(questionText: "Was the next step clear?", feedbackType: .opinion),
                .init(questionText: "What should we improve next time?", feedbackType: .comment)
            ]

        case .customQuestions:
            return []
        }
    }

    static func inferred(from questions: [EventInput.QuestionInput]) -> FeedbackTemplate {
        let signature = questions.map { Signature(text: $0.questionText, type: $0.feedbackType) }
        for template in FeedbackTemplate.allCases where template != .customQuestions {
            let templateSignature = template.defaultQuestions.map {
                Signature(text: $0.questionText, type: $0.feedbackType)
            }
            if signature == templateSignature {
                return template
            }
        }
        return .customQuestions
    }

    private struct Signature: Equatable {
        let text: String
        let type: FeedbackType
    }
}

struct FocusPreviewSession: Equatable, Sendable, Identifiable {
    let id = UUID()
    let state: FeedbackFlowCoordinator.State
}
