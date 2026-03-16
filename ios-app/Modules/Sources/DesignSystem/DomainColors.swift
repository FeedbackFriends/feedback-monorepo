import Domain
import SwiftUI

public extension Opinion {
    var color: Color {
        switch self {
        case .stronglyDisagree:
            return Color.themeVerySad
        case .disagree:
            return Color.themeSad
        case .neutral:
            return Color.gray
        case .agree:
            return Color.themeHappy
        case .stronglyAgree:
            return Color.themeVeryHappy
        }
    }
}

public extension Int {
    var ratingColor: Color {
        switch Int(self) {
        case 0...2:  return Color.themeVerySad
        case 3...4:  return Color.themeSad
        case 5:  return Color.gray
        case 6...7:  return Color.themeHappy
        case 8...10:  return Color.themeVeryHappy
        default:
            return Color.themeVeryHappy
        }
    }
}
