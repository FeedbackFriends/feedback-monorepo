import Localization
import Foundation
import Domain

public enum FeedbackTemplate: String, CaseIterable, Identifiable, Sendable {
    case standardMeeting
    case teamMeeting
    case retrospective
    case workshop
    case customQuestions

    public var id: String { rawValue }

    var title: String {
        switch self {
        case .standardMeeting: return String(appStrings: .templatesStandardTitle)
        case .teamMeeting: return String(appStrings: .templatesTeamTitle)
        case .retrospective: return String(appStrings: .templatesRetroTitle)
        case .workshop: return String(appStrings: .templatesWorkshopTitle)
        case .customQuestions: return String(appStrings: .templatesCustomTitle)
        }
    }

    var subtitle: String {
        switch self {
        case .standardMeeting:
            return String(appStrings: .templatesStandardSubtitle)
        case .teamMeeting:
            return String(appStrings: .templatesTeamSubtitle)
        case .retrospective:
            return String(appStrings: .templatesRetroSubtitle)
        case .workshop:
            return String(appStrings: .templatesWorkshopSubtitle)
        case .customQuestions:
            return String(appStrings: .templatesCustomSubtitle)
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
                .init(questionText: String(appStrings: .templatesMeetingValue), feedbackType: .emoji),
                .init(questionText: String(appStrings: .templatesClearPurpose), feedbackType: .opinion),
                .init(questionText: String(appStrings: .templatesImproveNextTime), feedbackType: .comment)
            ]

        case .teamMeeting:
            return [
                .init(questionText: String(appStrings: .templatesEnergy), feedbackType: .emoji),
                .init(questionText: String(appStrings: .templatesInvolvement), feedbackType: .opinion),
                .init(questionText: String(appStrings: .templatesFollowUp), feedbackType: .comment)
            ]

        case .retrospective:
            return [
                .init(questionText: String(appStrings: .templatesWorkedWell), feedbackType: .comment),
                .init(questionText: String(appStrings: .templatesImprovements), feedbackType: .comment),
                .init(questionText: String(appStrings: .templatesOverallRating), feedbackType: .zeroToTen)
            ]

        case .workshop:
            return [
                .init(questionText: String(appStrings: .templatesWorkshopValue), feedbackType: .zeroToTen),
                .init(questionText: String(appStrings: .templatesNextStep), feedbackType: .opinion),
                .init(questionText: String(appStrings: .templatesImproveNext), feedbackType: .comment)
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
