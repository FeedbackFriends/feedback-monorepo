import Domain
import OpenAPI
import Foundation

extension APIClient {
    static func makeGetBootstrap(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable () async throws -> Bootstrap {
        {
            try await withAuthorization {
                let bootstrap = try await api.getBootstrap().ok.body.json
                let newSession = Bootstrap(bootstrap)
                await sessionCache.updateBootstrap(newSession)
                return newSession
            }
        }
    }

    static func makeSessionChangedListener(sessionCache: APIClientCache) -> @Sendable () async -> AsyncStream<Bootstrap> {
        {
            await sessionCache.bootstrapChangedListener()
        }
    }

    static func makeGetBootstrapUpdate(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable () async throws -> Bootstrap? {
        {
            guard let bootstrapHash = await sessionCache.bootstrapHash else { return .none }
            let response = try await withAuthorization {
                try await api.getBoostrapUpdate(
                    .init(
                        path: .init(hash: bootstrapHash.uuidString)
                    )
                )
            }
            switch response {
            case .ok(let payload):
                let session = Bootstrap(try payload.body.json)
                await sessionCache.updateBootstrap(session)
                return session
            case .noContent:
                return .none
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

    static func makeMarkNotificationHistoryAsSeen(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable () async throws -> Void {
        {
            try await withAuthorization {
                _ = try await api.markNotificationHistoryAsSeen().ok
                try await sessionCache.markNotificationHistoryAsSeen()
                return ()
            }
        }
    }
}
