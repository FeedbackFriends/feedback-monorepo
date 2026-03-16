import Foundation
import Utility

public enum FeedbackType: String, Codable, Equatable, RawRepresentable, Sendable, CaseIterable {
    case emoji, comment, thumpsUpThumpsDown, opinion, zeroToTen
}

extension FeedbackType {
    public init(_ input: String) {
        guard let feedbackType = FeedbackType(rawValue: input.lowercasingFirst()) else {
            fatalError("Could not parse \(input) into a valid FeedbackType")
        }
        self = feedbackType
    }
}
