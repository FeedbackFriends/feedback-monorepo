import Foundation
import Utility

public enum CalendarProvider: String, Codable, Equatable, RawRepresentable, Sendable, CaseIterable {
    case GOOGLE, APPLE, MICROSOFT, ZOOM
}

extension CalendarProvider {
    public init(_ input: String) {
        guard let feedbackType = CalendarProvider(rawValue: input) else {
            fatalError("Could not parse \(input) into a valid FeedbackType")
        }
        self = feedbackType
    }
}
