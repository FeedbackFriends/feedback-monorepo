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
        case .standardMeeting: return "Standard mødefeedback"
        case .teamMeeting: return "Teammøde"
        case .retrospective: return "Retrospektiv"
        case .workshop: return "Workshop"
        case .customQuestions: return "Egne spørgsmål"
        }
    }

    var subtitle: String {
        switch self {
        case .standardMeeting:
            return "Værdi, tydelighed og én forbedring"
        case .teamMeeting:
            return "Energi, deltagelse og opfølgning"
        case .retrospective:
            return "Hvad virkede, hvad skal ændres og samlet vurdering"
        case .workshop:
            return "Nytte, tydelighed og åben forbedring"
        case .customQuestions:
            return "Start tomt og skriv dine egne spørgsmål"
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
                .init(questionText: "Var mødet værdifuldt?", feedbackType: .emoji),
                .init(questionText: "Var formålet tydeligt?", feedbackType: .opinion),
                .init(questionText: "Hvad skal vi forbedre til næste gang?", feedbackType: .comment)
            ]

        case .teamMeeting:
            return [
                .init(questionText: "Hvordan var energien i mødet?", feedbackType: .emoji),
                .init(questionText: "Følte du dig involveret?", feedbackType: .opinion),
                .init(questionText: "Hvad skal vi følge op på?", feedbackType: .comment)
            ]

        case .retrospective:
            return [
                .init(questionText: "Hvad fungerede godt?", feedbackType: .comment),
                .init(questionText: "Hvad kan blive bedre?", feedbackType: .comment),
                .init(questionText: "Samlet vurdering", feedbackType: .zeroToTen)
            ]

        case .workshop:
            return [
                .init(questionText: "Hvor nyttig var workshoppen?", feedbackType: .zeroToTen),
                .init(questionText: "Var næste skridt tydeligt?", feedbackType: .opinion),
                .init(questionText: "Hvad skal vi forbedre næste gang?", feedbackType: .comment)
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
