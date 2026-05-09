import Foundation
import Domain
import OpenAPI

extension APIClient {
    static func makeStartFeedbackSession(api: APIProtocol) -> @Sendable (PinCode) async throws -> FeedbackSession {
        { pinCode in
            try await withAuthorization {
                let response = try await api.startFeedbackSession(.init(body: .json(.init(pinCode: pinCode.value))))
                switch response {
                case .ok(let output):
                    return .init(try output.body.json, pinCode: pinCode)
                case .internalServerError(let internalError):
                    throw ApiError(try internalError.body.json)
                case .undocumented:
                    throw URLError(.unknown)
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
