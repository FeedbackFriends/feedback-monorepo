import Foundation
import Domain
import FeedbackFlowFeature

public enum FeedbackTemplate: String, CaseIterable, Identifiable, Sendable {
    case quickFeedback
    case engagement
    case learning
    case retrospective
    case leadership
    case buildYourOwn

    public var id: String { rawValue }

    var title: String {
        switch self {
        case .quickFeedback: return "Quick feedback"
        case .engagement: return "Engagement"
        case .learning: return "Learning"
        case .retrospective: return "Retrospective"
        case .leadership: return "Leadership"
        case .buildYourOwn: return "Build your own"
        }
    }

    var subtitle: String {
        switch self {
        case .quickFeedback:
            return "Fast rating with optional comment"
        case .engagement:
            return "Energy and participation"
        case .learning:
            return "Clarity and usefulness"
        case .retrospective:
            return "Reflect and improve as a team"
        case .leadership:
            return "Feedback on leadership and direction"
        case .buildYourOwn:
            return "Start empty and write every question yourself"
        }
    }

    var icon: String {
        switch self {
        case .quickFeedback: return "bolt"
        case .engagement: return "person.2"
        case .learning: return "lightbulb"
        case .retrospective: return "arrow.clockwise"
        case .leadership: return "person.crop.circle.badge.checkmark"
        case .buildYourOwn: return "square.and.pencil"
        }
    }

    var defaultQuestions: [EventInput.QuestionInput] {
        switch self {
        case .quickFeedback:
            return [
                .init(questionText: "How was this session?", feedbackType: .emoji),
                .init(questionText: "What went well?", feedbackType: .comment),
                .init(questionText: "What could be improved?", feedbackType: .comment)
            ]

        case .engagement:
            return [
                .init(questionText: "How was the energy?", feedbackType: .emoji),
                .init(questionText: "Did you feel involved?", feedbackType: .opinion),
                .init(questionText: "What affected engagement?", feedbackType: .comment)
            ]

        case .learning:
            return [
                .init(questionText: "How clear was it?", feedbackType: .zeroToTen),
                .init(questionText: "How useful was it?", feedbackType: .zeroToTen),
                .init(questionText: "What is still unclear?", feedbackType: .comment)
            ]

        case .retrospective:
            return [
                .init(questionText: "What worked well?", feedbackType: .comment),
                .init(questionText: "What could be better?", feedbackType: .comment),
                .init(questionText: "Overall rating", feedbackType: .zeroToTen)
            ]

        case .leadership:
            return [
                .init(questionText: "Did you feel well guided?", feedbackType: .opinion),
                .init(questionText: "Was communication clear?", feedbackType: .opinion),
                .init(questionText: "What could be improved in leadership?", feedbackType: .comment)
            ]

        case .buildYourOwn:
            return []
        }
    }
}

struct FocusPreviewSession: Equatable, Sendable, Identifiable {
    let id = UUID()
    let state: FeedbackFlowCoordinator.State
}
