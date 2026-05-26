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
            case .internalServerError(let internalError):
                throw ApiError(try internalError.body.json)
            case .undocumented:
                throw URLError(.unknown)
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
