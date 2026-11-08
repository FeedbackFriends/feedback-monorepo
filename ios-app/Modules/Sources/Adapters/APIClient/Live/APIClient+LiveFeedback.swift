import Foundation
import Domain
import OpenAPI

extension APIClient {
    static func makeStartFeedbackEvent(api: APIProtocol) -> @Sendable (PinCode) async throws -> FeedbackEventDto {
        { pinCode in
            try await withAuthorization {
                let response = try await api.startFeedbackEvent(.init(body: .json(.init(pinCode: pinCode.value))))
                switch response {
                case .ok(let output):
                    return .init(try output.body.json, pinCode: pinCode)
                case .badRequest(let badRequest):
                    throw ApiError(try badRequest.body.json, statusCode: 400)
                case .unauthorized(let unauthorized):
                    throw ApiError(try unauthorized.body.json, statusCode: 401)
                case .forbidden(let forbidden):
                    throw ApiError(try forbidden.body.json, statusCode: 403)
                case .notFound(let notFound):
                    throw ApiError(try notFound.body.json, statusCode: 404)
                case .conflict(let conflict):
                    throw ApiError(try conflict.body.json, statusCode: 409)
                case .serviceUnavailable(let unavailable):
                    throw ApiError(try unavailable.body.json, statusCode: 503)
                case .internalServerError(let internalError):
                    throw ApiError(try internalError.body.json, statusCode: 500)
                case .undocumented(let statusCode, _):
                    throw AppFailure.http(statusCode: statusCode)
                }
            }
        }
    }

    static func makeSubmitFeedback(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable ([FeedbackInput], PinCode) async throws -> Bool {
        { feedback, pinCode in
            try await withAuthorization {
                let response = SubmitFeedbackResponseDto(
                    try await api.submitFeedback(
                        .init(
                            body: .json(
                                .init(
                                    feedback: feedback.map { .init($0) },
                                    pinCode: pinCode.value
                                )
                            )
                        )
                    ).ok.body.json
                )
                await sessionCache.updateOrAppendParticipantEvent(response.event)
                return response.shouldPresentRatingPrompt
            }
        }
    }
}
