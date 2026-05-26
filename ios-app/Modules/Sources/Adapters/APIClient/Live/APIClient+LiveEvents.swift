import Foundation
import Domain
import OpenAPI

extension APIClient {
    static func makeCreateActivity(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable (ActivityInput) async throws -> Activity {
        { activityInput in
            try await withAuthorization {
                let activity = try await api.createActivity(body: .json(.init(forCreate: activityInput))).ok.body.json
                let mappedActivity = Activity(activity)
                await sessionCache.updateOrAppendActivity(mappedActivity)
                return mappedActivity
            }
        }
    }

    static func makeUpdateActivity(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable (ActivityInput, UUID) async throws -> Activity {
        { activityInput, activityId in
            try await withAuthorization {
                let activity = try await api.updateActivity(
                    path: .init(activityId: activityId.uuidString),
                    body: .json(.init(activityInput))
                ).ok.body.json
                let mappedActivity = Activity(activity)
                await sessionCache.updateOrAppendActivity(mappedActivity)
                return mappedActivity
            }
        }
    }

    static func makeDeleteActivity(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable (UUID) async throws -> Void {
        { activityId in
            try await withAuthorization {
                _ = try await api.deleteActivity(path: .init(activityId: activityId.uuidString)).ok
                await sessionCache.deleteActivity(activityId)
                return ()
            }
        }
    }

    static func makeCreateEvent(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable (SessionInput) async throws -> Event {
        { sessionInput in
            try await withAuthorization {
                let activity = try await api.createEvent(.init(body: .json(.init(sessionInput)))).ok.body.json
                guard let latestEvent = activity.events.max(by: { $0.date < $1.date }) else {
                    throw URLError(.cannotParseResponse)
                }
                let mappedActivity = Activity(activity)
                let mappedEvent = Event(latestEvent)
                await sessionCache.updateOrAppendActivity(mappedActivity)
                return mappedEvent
            }
        }
    }

    static func makeUpdateEvent(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable (SessionInput, UUID) async throws -> Event {
        { sessionInput, sessionId in
            try await withAuthorization {
                let activity = try await api.updateEvent(.init(
                    path: .init(eventId: sessionId.uuidString),
                    body: .json(.init(sessionInput))
                )).ok.body.json
                guard let updatedEvent = activity.events.first(where: { $0.id == sessionId.uuidString }) else {
                    throw URLError(.cannotParseResponse)
                }
                let mappedEvent = Event(updatedEvent)
                try await sessionCache.updateOrAppendEvent(mappedEvent)
                return mappedEvent
            }
        }
    }

    static func makeDeleteEvent(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable (UUID) async throws -> Void {
        { sessionId in
            try await withAuthorization {
                _ = try await api.deleteEvent(.init(path: .init(eventId: sessionId.uuidString))).ok
                let bootstrap = try await api.getBootstrap().ok.body.json
                await sessionCache.updateSession(Bootstrap(bootstrap))
                return ()
            }
        }
    }

    static func makeJoinEvent(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable (PinCode) async throws -> ParticipantEvent {
        { pinCode in
            try await withAuthorization {
                let response = try await api.joinEvent(.init(path: .init(pinCode: pinCode.value)))

                switch response {
                case .ok(let output):
                    let participantEvent = ParticipantEvent(try output.body.json)
                    await sessionCache.updateOrAppendParticipantEvent(participantEvent)
                    return participantEvent
                case .internalServerError(let internalError):
                    throw ApiError(try internalError.body.json)
                case .undocumented:
                    throw URLError(.unknown)
                }
            }
        }
    }

    static func makeMarkEventAsSeen(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable (UUID) async throws -> Void {
        { sessionId in
            try await withAuthorization {
                _ = try await api.markEventAsSeen(.init(path: .init(eventId: sessionId.uuidString))).ok
                try await sessionCache.markEventAsSeen(eventId: sessionId)
                return ()
            }
        }
    }

    static func makeResetDatabase(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable () async throws -> Void {
        {
            try await withAuthorization {
                _ = try await api.resetDatabase(.init()).ok
                let bootstrap = try await api.getBootstrap().ok.body.json
                await sessionCache.updateSession(Bootstrap(bootstrap))
                return ()
            }
        }
    }
}
