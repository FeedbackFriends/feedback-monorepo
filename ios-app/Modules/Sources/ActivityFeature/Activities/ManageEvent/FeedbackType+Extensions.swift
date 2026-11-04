import Localization
import Domain
import SwiftUI

extension FeedbackType {
    
    var title: String {
        switch self {
        case .emoji: return String(appStrings: .answerTypesEmoji)
        case .comment: return String(appStrings: .answerTypesComment)
        case .thumpsUpThumpsDown: return String(appStrings: .answerTypesThumbs)
        case .opinion: return String(appStrings: .answerTypesOpinion)
        case .zeroToTen: return String(appStrings: .answerTypesRating)
        }
    }

    var shortDescription: String {
        switch self {
        case .emoji: return String(appStrings: .answerTypesEmojiSubtitle)
        case .comment: return String(appStrings: .answerTypesCommentSubtitle)
        case .thumpsUpThumpsDown: return String(appStrings: .answerTypesThumbsSubtitle)
        case .opinion: return String(appStrings: .answerTypesOpinionSubtitle)
        case .zeroToTen: return String(appStrings: .answerTypesRatingSubtitle)
        }
    }
    
    var image: Image {
        switch self {
        case .emoji: return .feedbackTypeEmoji
        case .comment: return .feedbackTypeComment
        case .thumpsUpThumpsDown: return .feedbackTypeThumpsUpThumpsDown
        case .opinion: return .feedbackTypeOpinion
        case .zeroToTen: return .feedbackTypeZeroToTen
        }
    }
    
    var helpDescription: String {
        switch self {
        case .emoji: return String(appStrings: .answerTypesEmojiHelp)
        case .comment: return String(appStrings: .answerTypesCommentHelp)
        case .thumpsUpThumpsDown: return String(appStrings: .answerTypesThumbsHelp)
        case .opinion: return String(appStrings: .answerTypesOpinionHelp)
        case .zeroToTen: return String(appStrings: .answerTypesRatingHelp)
        }
    }
}
