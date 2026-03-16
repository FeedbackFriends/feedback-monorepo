import Foundation

public struct Feedback: Equatable, Identifiable, Sendable {
    
    public var id: UUID { UUID() }
    public let type: FeedbackTypeWithData
    public let questionId: UUID
    public var seenByManager: Bool
    public let createdAt: Date
    public var commentsReceived: Bool {
        switch type {
        case .emoji(_, let comment):
            if comment != nil { return true }
        case .comment:
            return true
        case .thumpsUpThumpsDown(_, let comment):
            if comment != nil { return true }
        case .opinion(_, let comment):
            if comment != nil { return true }
        case .zeroToTen(_, let comment):
            if comment != nil { return true }
        }
        return false
    }
    
    public init(type: FeedbackTypeWithData, questionId: UUID, seenByManager: Bool, createdAt: Date) {
        self.type = type
        self.questionId = questionId
        self.seenByManager = seenByManager
        self.createdAt = createdAt
    }
}

public enum FeedbackTypeWithData: Equatable, Sendable {
    case emoji(emoji: Emoji, comment: String?)
    case comment(comment: String)
    case thumpsUpThumpsDown(thumbsUpThumpsDown: ThumbsUpThumpsDown, comment: String?)
    case opinion(opinion: Opinion, comment: String?)
    case zeroToTen(zeroToTen: Int, comment: String?)
}

public enum Emoji: String, Equatable, Sendable, Codable {
    case verySad = "verySad"
    case sad = "sad"
    case happy = "happy"
    case veryHappy = "veryHappy"
}

public enum ThumbsUpThumpsDown: String, Equatable, Sendable, Codable {
    case up = "up"
    case down = "down"
}

public enum Opinion: String, Equatable, Sendable, Codable {
    case stronglyDisagree = "stronglyDisagree"
    case disagree = "disagree"
    case neutral = "neutral"
    case agree = "agree"
    case stronglyAgree = "stronglyAgree"
}

public extension Opinion {
    var localized: String {
        switch self {
        case .stronglyDisagree:
            return "Strongly disagree"
        case .disagree:
            return "Disagree"
        case .neutral:
            return "Neutral"
        case .agree:
            return "Agree"
        case .stronglyAgree:
            return "Strongly agree"
        }
    }
}
