import Foundation

public struct ApiError: Error, Sendable {
    let statusCode: Int?
    let timestamp: String?
    let message: String?
    let domainCode: DomainCode?
    let exceptionType: String?
    let path: String?
    public let rawDomainCode: String?
    let userTitle: String?
    let userMessage: String?
    public init(
        timestamp: String?,
        message: String?,
        domainCode: DomainCode?,
        exceptionType: String?,
        path: String?,
        statusCode: Int? = nil,
        rawDomainCode: String? = nil,
        userTitle: String? = nil,
        userMessage: String? = nil
    ) {
        self.statusCode = statusCode
        self.timestamp = timestamp
        self.message = message
        self.domainCode = domainCode
        self.exceptionType = exceptionType
        self.path = path
        self.rawDomainCode = rawDomainCode ?? domainCode?.rawValue
        self.userTitle = userTitle
        self.userMessage = userMessage
    }
}

public enum DomainCode: String, Sendable {
    case feedbackAlreadySubmitted = "FEEDBACK_ALREADY_SUBMITTED"
    case eventAlreadyJoined = "EVENT_ALREADY_JOINED"
    case cannotJoinOwnEvent = "CANNOT_JOIN_OWN_EVENT"
    case cannotGiveFeedbackToSelf = "CANNOT_GIVE_FEEDBACK_TO_SELF"
    case forbiddenResourceAccess = "FORBIDDEN_RESOURCE_ACCESS"
    case pincodeNotFound = "PINCODE_NOT_FOUND"
}
