import DesignSystem
import Domain
import SwiftUI

struct FocusMetricBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .captionTextStyle()
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(Color.themeTextSecondary)
            .background(Color.themeBackground, in: Capsule())
    }
}

struct LegacyTrendBadge: View {
    let direction: ActivityTrend.Direction

    var body: some View {
        Label(direction.title, systemImage: direction.symbolName)
            .captionTextStyle()
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(direction.color)
            .background(Color.themeBackground, in: Capsule())
    }
}

extension ActivityTrend {
    var deltaText: String? {
        guard let delta else { return nil }
        let sign = delta > 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", delta))"
    }

    var summaryText: String {
        switch direction {
        case .improving:
            return "Mødekvaliteten stiger sammenlignet med tidligere mødegange."
        case .stable:
            return "Mødekvaliteten ligger stabilt. Hold øje med næste mødegang."
        case .declining:
            return "Mødekvaliteten falder. Brug feedbacken til at justere formatet."
        case .insufficientData:
            return "Inviter feedback@letsgrow.dk og saml flere svar for at se udviklingen."
        }
    }
}

extension ActivityTrend.Direction {
    var title: String {
        switch self {
        case .improving:
            return "Bliver bedre"
        case .stable:
            return "Stabilt"
        case .declining:
            return "Falder"
        case .insufficientData:
            return "For lidt data"
        }
    }

    var symbolName: String {
        switch self {
        case .improving:
            return "arrow.up.right"
        case .stable:
            return "arrow.right"
        case .declining:
            return "arrow.down.right"
        case .insufficientData:
            return "questionmark"
        }
    }

    var color: Color {
        switch self {
        case .improving:
            return Color.themeSuccess
        case .stable:
            return Color.themeTextSecondary
        case .declining:
            return Color.themeSad
        case .insufficientData:
            return Color.themeTextSecondary
        }
    }
}
