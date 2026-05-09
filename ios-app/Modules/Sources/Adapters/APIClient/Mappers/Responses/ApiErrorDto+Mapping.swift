import Domain
import OpenAPI

public extension DomainCode {
    init(domainCodeDto: Components.Schemas.ApiError.DomainCodePayload) {
        switch domainCodeDto {
        case .feedbackAlreadySubmitted:
            self = .feedbackAlreadySubmitted
        case .eventAlreadyJoined:
            self = .eventAlreadyJoined
        case .cannotJoinOwnEvent:
            self = .cannotJoinOwnEvent
        case .cannotGiveFeedbackToSelf:
            self = .cannotGiveFeedbackToSelf
        case .pincodeNotFound:
            self = .pincodeNotFound
        }
    }
}

public extension ApiError {
    init(apiErrorDto: Components.Schemas.ApiError) {
        self.init(
            timestamp: apiErrorDto.timestamp,
            message: apiErrorDto.message,
            domainCode: apiErrorDto.domainCode.flatMap { .init(domainCodeDto: $0) },
            exceptionType: apiErrorDto.exceptionType,
            path: apiErrorDto.path
        )
    }
}
