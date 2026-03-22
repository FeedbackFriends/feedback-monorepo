import Foundation
import OpenAPIURLSession
import OpenAPIRuntime
import Domain
import OpenAPI

public extension APIClient {
    static func live(
        client api: APIProtocol,
        provideFcmToken: @escaping @Sendable () async -> String?,
        sessionCache: SessionCache = SessionCache()
    ) -> APIClient {
        return APIClient(
            deleteAccount: {
                try await withAuthorization {
                    _ = try await api.deleteAccount(.init())
                    return ()
                }
            },
            updateAccount: { name, email, phoneNumber in
                
                try await withAuthorization {
                    _ = try await api.modifyAccount(
                        .init(
                            body: .json(
                                .init(
                                    name: name.nilIfEmpty,
                                    email: email.nilIfEmpty,
                                    phoneNumber: phoneNumber.nilIfEmpty
                                )
                            )
                        )
                    ).ok
                    await sessionCache.updateAccount(
                        name: name.nilIfEmpty,
                        email: email.nilIfEmpty,
                        phoneNumber: phoneNumber.nilIfEmpty
                    )
                    return ()
                }
            },
            linkFCMTokenToAccount: { fcmToken in
                try await withAuthorization {
                    _ = try await api.linkFCMTokenToAccount(body: .json(.init(fcmToken: fcmToken)))
                    return ()
                }
            },
            logout: {
                guard let fcmToken = await provideFcmToken() else { return }
                try await withAuthorization {
                    _ = try await api.logout(body: .json(.init(fcmToken: fcmToken)))
                    return ()
                }
            },
            getSession: {
                try await withAuthorization {
                    let sessionDto = try await api.getSession().ok.body.json
                    let newSession = Session(sessionDto)
                    await sessionCache.updateSession(newSession)
                    return newSession
                }
            },
            startFeedbackSession: { pinCode in
                try await withAuthorization {
                    let response = try await api.startFeedbackSession(.init(body: .json(.init(pinCode: pinCode.value))))
                    switch response {
                    case .ok(let output):
                        return .init(try output.body.json, pinCode: pinCode)
                    case .internalServerError(let internalError):
                        let apiErrorDto = try internalError.body.json
                        throw ApiError(apiErrorDto: apiErrorDto)
                    case .undocumented:
                        throw URLError(.unknown)
                    }
                }
            },
            submitFeedback: { feedback, pinCode in
                try await withAuthorization {
                    let response = try await api.submitFeedback(
                        .init(
                            body: .json(
                                .init(
                                    feedback: feedback.map { .init($0) },
                                    pinCode: pinCode.value
                                )
                            )
                        )
                    ).ok.body.json
                    await sessionCache.updateOrAppendParticipantEvent(ParticipantEvent(response.event))
                    return response.shouldPresentRatingPrompt
                }
            },
            createEvent: { eventInput in
                try await withAuthorization {
                    let eventWrapper = EventWrapper(try await api.createEvent(body: .json(.init(eventInput))).ok.body.json)
                    await sessionCache.updateOrAppendManagerEvent(
                        event: eventWrapper.event
                    )
                    await sessionCache.updateRecentlyUsedQuestions(recentlyUsedQuestions: eventWrapper.recentlyUsedQuestions)
                    return eventWrapper.event
                }
            },
            updateEvent: { eventInput, eventId in
                try await withAuthorization {
                    let eventWrapper = EventWrapper(try await api.updateEvent(path: .init(eventId: eventId.uuidString), body: .json(.init(eventInput))).ok.body.json)
                    await sessionCache.updateOrAppendManagerEvent(
                        event: eventWrapper.event
                    )
                    await sessionCache.updateRecentlyUsedQuestions(recentlyUsedQuestions: eventWrapper.recentlyUsedQuestions)
                    return eventWrapper.event
                }
            },
            deleteEvent: { eventId in
                try await withAuthorization {
                    _ = try await api.deleteEvent(path: .init(eventId: eventId.uuidString)).ok
                    await sessionCache.deleteEvent(eventId)
                    return ()
                }
            },
            createAccount: { optionalRole in
                return try await withAuthorization(forceRefreshAfter: true) {
                    let sessionDto = try await api.createAccount(
                        .init(
                            body: .json(
                                .init(
                                    requestedRole: optionalRole?.rawValue.uppercasingFirst(),
                                    fcmToken: provideFcmToken()
                                )
                            )
                        )
                    ).ok.body.json
                    let session = Session(sessionDto)
                    await sessionCache.updateSession(session)
                    return session
                }
            },
            sessionChangedListener: {
                await sessionCache.sessionChangedListener()
                
            },
            joinEvent: { pinCode in
                try await withAuthorization {
                    
                    let response = try await api.joinEvent(.init(path: .init(pinCode: pinCode.value)))
                    
                    switch response {
                    case .ok(let output):
                        let participantEvent = try output.body.json
                        await sessionCache.updateOrAppendParticipantEvent(ParticipantEvent(participantEvent))
                    case .internalServerError(let internalError):
                        let apiErrorDto = try internalError.body.json
                        throw ApiError(apiErrorDto: apiErrorDto)
                    case .undocumented:
                        throw URLError(.unknown)
                    }
                }
            },
            markEventAsSeen: { eventId in
                try await withAuthorization {
                    _ = try await api.markEventAsSeen(.init(path: .init(eventId: eventId.uuidString)))
                    await sessionCache.markEventAsSeen(eventId: eventId)
                    return ()
                }
                return ()
            },
            updateAccountRole: { role in
                try await withAuthorization(forceRefreshAfter: true) {
                    _ = try await api.updateRole(.init(body: .json(.init(role: role.rawValue.uppercasingFirst()))))
                    return ()
                }
            },
            getMockToken: {
                return try await api.mockIdToken(body: .json(.init(role: "Manager", id: "mock_id"))).ok.body.json.token
            },
            getUpdatedSession: {
                guard let feedbackSessionHash = await sessionCache.feedbackSessionHash else { return .none }
                let optionalSessionDto = try await withAuthorization {
                    try await api.getUpdatedSession(
                        .init(
                            path: .init(feedbackSessionHash: feedbackSessionHash.uuidString)
                        )
                    ).ok.body.json.session
                }
                guard let sessionDto = optionalSessionDto else {
                    return .none
                }
                let session = Session(sessionDto)
                await sessionCache.updateSession(session)
                return session
            },
            markActivityAsSeen: {
                try await withAuthorization {
                    _ = try await api.markActivityAsSeen().ok
                    await sessionCache.markActivityAsSeen()
                    return ()
                }
            }
        )
    }
}
