import Domain
import SwiftUI

extension FeedbackType {
    
    var title: String {
        switch self {
        case .emoji: return "Emoji"
        case .comment: return "Comment"
        case .thumpsUpThumpsDown: return "Thumbs"
        case .opinion: return "Opinion"
        case .zeroToTen: return "0–10"
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
        case .emoji: return "Pick an emoji reaction. Great for quick vibes."
        case .comment: return "Write freeform text. Best for detailed feedback."
        case .thumpsUpThumpsDown: return "Simple thumbs up/down. Fast sentiment signal."
        case .opinion: return "Express your level of agreement, from Strongly Disagree to Strongly Agree."
        case .zeroToTen: return "Rate on a 0–10 scale for finer granularity."
        }
    }
}
