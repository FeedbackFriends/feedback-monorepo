import Foundation
import Domain
import OpenAPI

extension APIClient {
    static func makeCreateActivity(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable (ActivityInput) async throws -> ActivityDto {
        { activityInput in
            try await withAuthorization {
                let activity = try await api.createActivity(body: .json(.init(forCreate: activityInput))).ok.body.json
                let mappedActivity = ActivityDto(activity)
                await sessionCache.updateOrAppendActivity(mappedActivity)
                return mappedActivity
            }
        }
    }

    static func makeUpdateActivity(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable (ActivityInput, UUID) async throws -> ActivityDto {
        { activityInput, activityId in
            try await withAuthorization {
                let activity = try await api.updateActivity(
                    path: .init(activityId: activityId.uuidString),
                    body: .json(.init(activityInput))
                ).ok.body.json
                let mappedActivity = ActivityDto(activity)
                await sessionCache.updateOrAppendActivity(mappedActivity)
                return mappedActivity
            }
        }
    }

    static func makeDeleteActivity(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable (UUID) async throws -> Void {
        { activityId in
            try await withAuthorization {
                _ = try await api.deleteActivity(path: .init(activityId: activityId.uuidString)).ok
                let bootstrap = try await api.getBootstrap().ok.body.json
                await sessionCache.updateSession(Bootstrap(bootstrap))
                return ()
            }
        }
    }

    static func makeCreateSession(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable (SessionInput) async throws -> ActivityDto {
        { sessionInput in
            try await withAuthorization {
                let activity = try await api.createSession(body: .json(.init(sessionInput))).ok.body.json
                let mappedActivity = ActivityDto(activity)
                await sessionCache.updateOrAppendActivity(mappedActivity)
                return mappedActivity
            }
        }
    }

    static func makeUpdateSession(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable (SessionInput, UUID) async throws -> ActivityDto {
        { sessionInput, sessionId in
            try await withAuthorization {
                let activity = try await api.updateSession(
                    path: .init(sessionId: sessionId.uuidString),
                    body: .json(.init(sessionInput))
                ).ok.body.json
                let mappedActivity = ActivityDto(activity)
                await sessionCache.updateOrAppendActivity(mappedActivity)
                return mappedActivity
            }
        }
    }

    static func makeDeleteSession(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable (UUID) async throws -> Void {
        { sessionId in
            try await withAuthorization {
                _ = try await api.deleteSession(path: .init(sessionId: sessionId.uuidString)).ok
                let bootstrap = try await api.getBootstrap().ok.body.json
                await sessionCache.updateSession(Bootstrap(bootstrap))
                return ()
            }
        }
    }

    static func makeJoinSession(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable (PinCode) async throws -> ParticipantSessionDto {
        { pinCode in
            try await withAuthorization {
                let response = try await api.joinSession(.init(path: .init(pinCode: pinCode.value)))

                switch response {
                case .ok(let output):
                    let participantSession = ParticipantSessionDto(try output.body.json)
                    await sessionCache.updateOrAppendParticipantEvent(participantSession)
                    return participantSession
                case .internalServerError(let internalError):
                    throw ApiError(try internalError.body.json)
                case .undocumented:
                    throw URLError(.unknown)
                }
            }
        }
    }

    static func makeMarkSessionAsSeen(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable (UUID) async throws -> Void {
        { sessionId in
            try await withAuthorization {
                _ = try await api.markSessionAsSeen(.init(path: .init(sessionId: sessionId.uuidString))).ok
                let bootstrap = try await api.getBootstrap().ok.body.json
                await sessionCache.updateSession(Bootstrap(bootstrap))
                return ()
            }
        }
    }
}
