import Domain
import SwiftUI

extension FeedbackType {
    
    var title: String {
        switch self {
        case .emoji: return "Emoji"
        case .comment: return "Kommentar"
        case .thumpsUpThumpsDown: return "Tommel op/ned"
        case .opinion: return "Enighed"
        case .zeroToTen: return "0–10"
        }
    }

    var shortDescription: String {
        switch self {
        case .emoji: return "Hurtig stemning"
        case .comment: return "Fri tekst"
        case .thumpsUpThumpsDown: return "Ja eller nej"
        case .opinion: return "Hvor enig?"
        case .zeroToTen: return "Præcis vurdering"
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
        case .emoji: return "Deltageren vælger en emoji. Brug den til hurtige temperaturmålinger efter en session."
        case .comment: return "Deltageren skriver et frit svar. Brug den, når du vil forstå årsagen bag feedbacken."
        case .thumpsUpThumpsDown: return "Deltageren vælger tommel op eller ned. Brug den til klare ja/nej-spørgsmål."
        case .opinion: return "Deltageren angiver graden af enighed. Brug den til udsagn som kan vurderes fra uenig til enig."
        case .zeroToTen: return "Deltageren giver en score fra 0 til 10. Brug den, når du vil følge udviklingen over tid."
        }
    }
}
