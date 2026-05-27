import Domain
import OpenAPI

public extension ApiError {
    init(_ dto: Components.Schemas.ApiError) {
        self.init(
            timestamp: dto.timestamp,
            message: dto.message,
            domainCode: dto.domainCode.map { DomainCode($0) },
            exceptionType: dto.exceptionType,
            path: dto.path
        )
    }
}

public extension DomainCode {
    init(_ payload: Components.Schemas.ApiError.DomainCodePayload) {
        switch payload {
        case .feedbackAlreadySubmitted:
            self = .feedbackAlreadySubmitted
        case .eventAlreadyJoined:
            self = .eventAlreadyJoined
        case .cannotJoinOwnEvent:
            self = .cannotJoinOwnEvent
        case .cannotGiveFeedbackToSelf:
            self = .cannotGiveFeedbackToSelf
        case .forbiddenResourceAccess:
            self = .forbiddenResourceAccess
        case .pincodeNotFound:
            self = .pincodeNotFound
        }
    }
}
