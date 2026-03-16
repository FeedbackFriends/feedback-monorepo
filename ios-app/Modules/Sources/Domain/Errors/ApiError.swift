import Foundation

public struct ApiError: Error, Sendable {
    let timestamp: String?
    let message: String?
    let domainCode: DomainCode?
    let exceptionType: String?
    let path: String?
    public init(
        timestamp: String?,
        message: String?,
        domainCode: DomainCode?,
        exceptionType: String?,
        path: String?
    ) {
        self.timestamp = timestamp
        self.message = message
        self.domainCode = domainCode
        self.exceptionType = exceptionType
        self.path = path
    }
}

public enum DomainCode: Sendable {
    case feedbackAlreadySubmitted
    case eventAlreadyJoined
    case cannotJoinOwnEvent
    case cannotGiveFeedbackToSelf
    case pincodeNotFound
}
