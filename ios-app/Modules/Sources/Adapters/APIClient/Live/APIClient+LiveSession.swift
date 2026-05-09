import Domain
import OpenAPI

extension APIClient {
    static func makeGetBootstrap(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable () async throws -> Bootstrap {
        {
            try await withAuthorization {
                let bootstrap = try await api.getBootstrap().ok.body.json
                let newSession = Bootstrap(bootstrap)
                await sessionCache.updateSession(newSession)
                return newSession
            }
        }
    }

    static func makeSessionChangedListener(sessionCache: APIClientCache) -> @Sendable () async -> AsyncStream<Bootstrap> {
        {
            await sessionCache.sessionChangedListener()
        }
    }

    static func makeGetBoostrapUpdate(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable () async throws -> Bootstrap? {
        {
            guard let feedbackSessionHash = await sessionCache.feedbackSessionHash else { return .none }
            let bootstrap = try await withAuthorization {
                try await api.getBoostrapUpdate(
                    .init(
                        path: .init(hash: feedbackSessionHash.uuidString)
                    )
                ).ok.body.json
            }
            let session = Bootstrap(bootstrap)
            await sessionCache.updateSession(session)
            return session
        }
    }

    static func makeMarkNotificationHistoryAsSeen(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable () async throws -> Void {
        {
            try await withAuthorization {
                _ = try await api.markNotificationHistoryAsSeen().ok
                await sessionCache.markNotificationHistoryAsSeen()
                return ()
            }
        }
    }
}
