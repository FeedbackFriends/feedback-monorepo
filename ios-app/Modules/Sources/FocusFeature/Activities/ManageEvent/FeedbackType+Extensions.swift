import Domain
import SwiftUI

extension FeedbackType {
    
    var title: String {
        switch self {
        case .emoji: return "Emoji"
        case .comment: return "Kommentar"
        case .thumpsUpThumpsDown: return "Tommel"
        case .opinion: return "Enighed"
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
        case .emoji: return "Vælg en emoji-reaktion. God til hurtige signaler."
        case .comment: return "Skriv fri tekst. Bedst til uddybende feedback."
        case .thumpsUpThumpsDown: return "Enkel tommel op/ned. Hurtigt signal om stemning."
        case .opinion: return "Angiv graden af enighed fra helt uenig til helt enig."
        case .zeroToTen: return "Vurder på en skala fra 0-10 for mere nuance."
        }
    }
}
