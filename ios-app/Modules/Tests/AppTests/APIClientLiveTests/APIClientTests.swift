@testable import Domain
import Adapters
import ComposableArchitecture
import Foundation
import OpenAPI
import Testing

@MainActor
struct APIClientLiveTests {
    @Test
    func `Delete account delegates to generated client`() async throws {
        let deleteCalled = LockIsolated(false)
        let client = Self.makeClient(
            api: MockAPI(
                deleteAccountHandler: { _ in
                    deleteCalled.setValue(true)
                    return .ok
                }
            )
        )

        try await client.deleteAccount()

        #expect(deleteCalled.value)
    }

    @Test
    func `Update account normalizes empty fields and updates cache`() async throws {
        let input = LockIsolated<Operations.ModifyAccount.Input?>(nil)
        let cache = APIClientCache(bootstrap: Self.managerSession())
        let client = Self.makeClient(
            api: MockAPI(
                modifyAccountHandler: { request in
                    input.setValue(request)
                    return .ok
                }
            ),
            cache: cache
        )

        try await client.updateAccount("", "updated@example.com", "")

        guard let captured = input.value else {
            Issue.record("Expected modifyAccount request")
            return
        }
        guard case .json(let body) = captured.body else {
            Issue.record("Expected JSON modifyAccount body")
            return
        }
        let snapshot = await cache.getBootstrap()
        #expect(body.name == nil)
        #expect(body.email == "updated@example.com")
        #expect(body.phoneNumber == nil)
        #expect(snapshot?.accountInfo.name == nil)
        #expect(snapshot?.accountInfo.email == "updated@example.com")
        #expect(snapshot?.accountInfo.phoneNumber == nil)
    }

    @Test
    func `Account related generated inputs are forwarded correctly`() async throws {
        let fcmInput = LockIsolated<Operations.LinkFCMTokenToAccount.Input?>(nil)
        let roleInput = LockIsolated<Operations.UpdateRole.Input?>(nil)
        let loginInput = LockIsolated<Operations.Login.Input?>(nil)
        let client = Self.makeClient(
            api: MockAPI(
                linkFCMTokenToAccountHandler: { request in
                    fcmInput.setValue(request)
                    return .ok
                },
                updateRoleHandler: { request in
                    roleInput.setValue(request)
                    return .ok
                },
                loginHandler: { request in
                    loginInput.setValue(request)
                    return .ok(
                        .init(
                            body: .json(
                                .init(
                                    firebaseResponse: .init(idToken: "id", refreshToken: "refresh", expiresIn: "3600"),
                                    token: "mock-token"
                                )
                            )
                        )
                    )
                }
            )
        )

        try await client.linkFCMTokenToAccount("fcm-123")
        try await client.updateAccountRole(.manager)
        let token = try await client.login("mock_id")

        guard let capturedFCMInput = fcmInput.value, case .json(let fcmBody) = capturedFCMInput.body else {
            Issue.record("Expected linkFCMTokenToAccount JSON body")
            return
        }
        guard let capturedRoleInput = roleInput.value, case .json(let roleBody) = capturedRoleInput.body else {
            Issue.record("Expected updateRole JSON body")
            return
        }
        guard let capturedLoginInput = loginInput.value, case .json(let loginBody) = capturedLoginInput.body else {
            Issue.record("Expected login JSON body")
            return
        }

        #expect(fcmBody.fcmToken == "fcm-123")
        #expect(roleBody.role == "Manager")
        #expect(loginBody.id == "mock_id")
        #expect(token.token == "mock-token")
    }

    @Test
    func `Logout does not call API when FCM token is unavailable`() async throws {
        let logoutCalled = LockIsolated(false)
        let client = Self.makeClient(
            api: MockAPI(
                logoutHandler: { _ in
                    logoutCalled.setValue(true)
                    return .ok
                }
            ),
            provideFcmToken: { nil }
        )

        try await client.logout()

        #expect(logoutCalled.value == false)
    }

    @Test
    func `Logout forwards the current FCM token`() async throws {
        let input = LockIsolated<Operations.Logout.Input?>(nil)
        let client = Self.makeClient(
            api: MockAPI(
                logoutHandler: { request in
                    input.setValue(request)
                    return .ok
                }
            ),
            provideFcmToken: { "fcm-logout" }
        )

        try await client.logout()

        guard let captured = input.value, case .json(let body) = captured.body else {
            Issue.record("Expected logout JSON body")
            return
        }
        #expect(body.fcmToken == "fcm-logout")
    }

    @Test
    func `Session is returned and saved in cache after being fetched`() async throws {
        let bootstrap = Self.bootstrapDto(role: "Manager", managerData: Self.managerDataDto())
        let cache = APIClientCache(bootstrap: nil)
        let client = Self.makeClient(
            api: MockAPI(
                getBootstrapHandler: { _ in
                    .ok(.init(body: .json(bootstrap)))
                }
            ),
            cache: cache
        )

        let result = try await client.getBootstrap()
        let snapshot = await cache.getBootstrap()

        #expect(result == Bootstrap(bootstrap))
        #expect(snapshot == Bootstrap(bootstrap))
    }

    @Test
    func `Start feedback event maps the generated DTO`() async throws {
        let input = LockIsolated<Operations.StartFeedbackEvent.Input?>(nil)
        let pinCode = PinCode(value: "456789")
        let client = Self.makeClient(
            api: MockAPI(
                startFeedbackEventHandler: { request in
                    input.setValue(request)
                    return .ok(.init(body: .json(Self.feedbackEventDto())))
                }
            )
        )

        let session = try await client.startFeedbackEvent(pinCode)

        guard let captured = input.value, case .json(let body) = captured.body else {
            Issue.record("Expected startFeedbackEvent JSON body")
            return
        }
        #expect(body.pinCode == "456789")
        #expect(session == FeedbackEventDto(Self.feedbackEventDto(), pinCode: pinCode))
    }

    @Test
    func `Submit feedback forwards mapped payload and updates participant cache`() async throws {
        let input = LockIsolated<Operations.SubmitFeedback.Input?>(nil)
        let cache = APIClientCache(bootstrap: Self.participantSession())
        let feedback = FeedbackInput(
            type: .emoji(emoji: .veryHappy, comment: "Great"),
            questionId: Self.questionId
        )
        let client = Self.makeClient(
            api: MockAPI(
                submitFeedbackHandler: { request in
                    input.setValue(request)
                    return .ok(
                        .init(
                            body: .json(
                                .init(
                                    shouldPresentRatingPrompt: true,
                                    event: Self.participantEventDto(feedbackSubmited: true)
                                )
                            )
                        )
                    )
                }
            ),
            cache: cache
        )

        let shouldPresentRatingPrompt = try await client.submitFeedback([feedback], PinCode(value: "456789"))

        guard let captured = input.value, case .json(let body) = captured.body else {
            Issue.record("Expected submitFeedback JSON body")
            return
        }
        let snapshot = await cache.getBootstrap()
        #expect(body.pinCode == "456789")
        #expect(body.feedback == [Components.Schemas.FeedbackInput(feedback)])
        #expect(shouldPresentRatingPrompt)
        #expect(snapshot?.participantEvents[id: Self.eventId]?.feedbackSubmited == true)
    }

    @Test
    func `Create and update event calls refresh the cached manager event`() async throws {
        let createInput = LockIsolated<Operations.CreateEvent.Input?>(nil)
        let updateInput = LockIsolated<Operations.UpdateEvent.Input?>(nil)
        let cache = APIClientCache(bootstrap: Self.managerSession(events: [Self.event(id: Self.existingEventId, title: "Original title")]))
        let client = Self.makeClient(
            api: MockAPI(
                createEventHandler: { request in
                    createInput.setValue(request)
                    return .ok(.init(body: .json(Self.createdActivityDto(title: "Created title"))))
                },
                updateEventHandler: { request in
                    updateInput.setValue(request)
                    return .ok(.init(body: .json(Self.feedbackFlowDto(title: "Updated title", id: request.path.eventId))))
                }
            ),
            cache: cache
        )

        let created = try await client.createEvent(Self.eventInput(title: "Created title"))
        let updated = try await client.updateEvent(Self.eventInput(title: "Updated title"), Self.eventId)

        guard let capturedCreateInput = createInput.value, case .json(let createBody) = capturedCreateInput.body else {
            Issue.record("Expected createEvent JSON body")
            return
        }
        guard let capturedUpdateInput = updateInput.value, case .json(let updateBody) = capturedUpdateInput.body else {
            Issue.record("Expected updateEvent JSON body")
            return
        }
        let snapshot = await cache.getBootstrap()
        #expect(createBody.title == "Created title")
        #expect(updateBody.title == "Updated title")
        #expect(created.title == "Created title")
        #expect(updated.title == "Updated title")
        #expect(snapshot?.managerData?.activities[id: Self.eventId]?.title == "Updated title")
        #expect(snapshot?.managerData?.activities[id: Self.createdActivityId]?.title == "Created title")
    }

    @Test
    func `Event is removed from cache after deletion and stream is triggered with updated session`() async throws {
        let first = Self.event(id: Self.eventId, title: "First")
        let secondId = UUID(uuidString: "00000000-0000-0000-0000-000000000099")!
        let second = Self.event(id: secondId, title: "Second")
        let cache = APIClientCache(bootstrap: Self.managerSession(events: [first, second]))
        let client = Self.makeClient(
            api: MockAPI(
                deleteEventHandler: { _ in .ok }
            ),
            cache: cache
        )

        var listener = await client.sessionChangedListener().makeAsyncIterator()
        try await client.deleteEvent(Self.eventId)
        let snapshot = await cache.getBootstrap()
        let updatedSession = await listener.next()

        #expect(snapshot?.managerData?.activities.count == 1)
        #expect(snapshot?.managerData?.activities.first?.id == secondId)
        #expect(updatedSession == snapshot)
    }

    @Test
    func `Create account forwards role and FCM token then refreshes bootstrap`() async throws {
        let createInput = LockIsolated<Operations.CreateAccount.Input?>(nil)
        let bootstrapCalls = LockIsolated(0)
        let bootstrap = Self.bootstrapDto(role: "Manager", managerData: Self.managerDataDto())
        let cache = APIClientCache(bootstrap: nil)
        let client = Self.makeClient(
            api: MockAPI(
                createAccountHandler: { request in
                    createInput.setValue(request)
                    return .ok(.init(body: .json(Self.sessionDto())))
                },
                getBootstrapHandler: { _ in
                    bootstrapCalls.setValue(bootstrapCalls.value + 1)
                    return .ok(.init(body: .json(bootstrap)))
                }
            ),
            cache: cache,
            provideFcmToken: { "fcm-create" }
        )

        let session = try await client.createAccount(.manager)

        guard let captured = createInput.value, case .json(let body) = captured.body else {
            Issue.record("Expected createAccount JSON body")
            return
        }
        let snapshot = await cache.getBootstrap()
        #expect(body.requestedRole == "Manager")
        #expect(body.fcmToken == "fcm-create")
        #expect(bootstrapCalls.value == 1)
        #expect(session == Bootstrap(bootstrap))
        #expect(snapshot == Bootstrap(bootstrap))
    }

    @Test
    func `Join event appends the participant event to session`() async throws {
        let input = LockIsolated<Operations.JoinEvent.Input?>(nil)
        let cache = APIClientCache(bootstrap: Self.participantSession())
        let client = Self.makeClient(
            api: MockAPI(
                joinEventHandler: { request in
                    input.setValue(request)
                    return .ok(.init(body: .json(Self.participantEventDto())))
                }
            ),
            cache: cache
        )

        try await client.joinEvent(PinCode(value: "456789"))

        let snapshot = await cache.getBootstrap()
        #expect(input.value?.path.pinCode == "456789")
        #expect(snapshot?.participantEvents[id: Self.eventId] != nil)
    }

    @Test
    func `Manager event is marked as seen`() async throws {
        let cache = APIClientCache(bootstrap: Self.managerSession(events: [Self.event(unseenResponses: 1)], unseenTotal: 1))
        let client = Self.makeClient(
            api: MockAPI(
                markEventAsSeenHandler: { _ in .ok }
            ),
            cache: cache
        )

        try await client.markEventAsSeen(Self.eventId)

        let updated = await cache.getBootstrap()
        #expect(updated?.managerData?.activities[id: Self.eventId]?.overallFeedbackSummary?.unseenResponses == 0)
        #expect(updated?.managerData?.notificationHistory.unseenTotal == 0)
        #expect(updated?.managerData?.notificationHistory.items.allSatisfy { $0.seenByManager } == true)
    }

    @Test
    func `Updated session returns nil without a cached hash`() async throws {
        let client = Self.makeClient(api: MockAPI(), cache: APIClientCache(bootstrap: Bootstrap.mockParticipant()))

        let result = try await client.getUpdatedSession()

        #expect(result == nil)
    }

    @Test
    func `Updated session fetches bootstrap update and refreshes the cache`() async throws {
        let input = LockIsolated<Operations.GetBoostrapUpdate.Input?>(nil)
        let bootstrap = Self.bootstrapDto(role: "Manager", managerData: Self.managerDataDto())
        let cache = APIClientCache(bootstrap: Self.managerSession())
        let client = Self.makeClient(
            api: MockAPI(
                getBoostrapUpdateHandler: { request in
                    input.setValue(request)
                    return .ok(.init(body: .json(bootstrap)))
                }
            ),
            cache: cache
        )

        let result = try await client.getUpdatedSession()
        let snapshot = await cache.getBootstrap()

        #expect(input.value?.path.hash == Self.sessionHash.uuidString)
        #expect(result == Bootstrap(bootstrap))
        #expect(snapshot == Bootstrap(bootstrap))
    }

    @Test
    func `Updated session keeps cache unchanged when bootstrap hash is unchanged`() async throws {
        let input = LockIsolated<Operations.GetBoostrapUpdate.Input?>(nil)
        let existingSession = Self.managerSession()
        let cache = APIClientCache(bootstrap: existingSession)
        let client = Self.makeClient(
            api: MockAPI(
                getBoostrapUpdateHandler: { request in
                    input.setValue(request)
                    return .noContent
                }
            ),
            cache: cache
        )

        let result = try await client.getUpdatedSession()
        let snapshot = await cache.getBootstrap()

        #expect(input.value?.path.hash == Self.sessionHash.uuidString)
        #expect(result == nil)
        #expect(snapshot == existingSession)
    }

    @Test
    func `Manager activity is marked as seen`() async throws {
        let cache = APIClientCache(bootstrap: Self.managerSession(events: [Self.event(unseenResponses: 1)], unseenTotal: 2))
        let client = Self.makeClient(
            api: MockAPI(
                markActivityAsSeenHandler: { _ in .ok }
            ),
            cache: cache
        )

        try await client.markActivityAsSeen()

        let updated = await cache.getBootstrap()
        #expect(updated?.managerData?.notificationHistory.unseenTotal == 0)
        #expect(updated?.managerData?.notificationHistory.items.allSatisfy { $0.seenByManager } == true)
    }

    @Test
    func `Manager-only cache mutations throw when manager state is unavailable`() async throws {
        let cache = APIClientCache(bootstrap: Self.participantSession())

        do {
            try await cache.markEventAsSeen(eventId: Self.eventId)
            Issue.record("Expected managerDataUnavailable error")
        } catch let error as APIClientCache.CacheMutationError {
            #expect(error == .managerDataUnavailable)
        }

        do {
            try await cache.markNotificationHistoryAsSeen()
            Issue.record("Expected managerDataUnavailable error")
        } catch let error as APIClientCache.CacheMutationError {
            #expect(error == .managerDataUnavailable)
        }
    }

    @Test
    func `Cache mutation throws when entity does not exist`() async throws {
        let cache = APIClientCache(bootstrap: Self.managerSession())
        let unknownEventId = UUID(uuidString: "00000000-0000-0000-0000-000000000099")!
        let unknownActivityId = UUID(uuidString: "00000000-0000-0000-0000-000000000098")!

        do {
            try await cache.markEventAsSeen(eventId: unknownEventId)
            Issue.record("Expected eventNotFound error")
        } catch let error as APIClientCache.CacheMutationError {
            #expect(error == .eventNotFound(unknownEventId))
        }

        do {
            try await cache.deleteActivity(unknownActivityId)
            Issue.record("Expected activityNotFound error")
        } catch let error as APIClientCache.CacheMutationError {
            #expect(error == .activityNotFound(unknownActivityId))
        }
    }

    @Test
    func `Notification unseen counter decreases by the number of newly seen event items`() async throws {
        let firstNotificationId = UUID(uuidString: "00000000-0000-0000-0000-000000000090")!
        let secondNotificationId = UUID(uuidString: "00000000-0000-0000-0000-000000000091")!
        let otherEventId = UUID(uuidString: "00000000-0000-0000-0000-000000000092")!

        var session = Self.managerSession(events: [Self.event(unseenResponses: 1)], unseenTotal: 3)
        session.managerData?.notificationHistory = .init(
            items: [
                .init(
                    id: firstNotificationId,
                    date: Self.referenceDate,
                    eventTitle: "Weekly retro",
                    eventId: Self.eventId,
                    newFeedbackCount: 1,
                    seenByManager: false
                ),
                .init(
                    id: secondNotificationId,
                    date: Self.referenceDate,
                    eventTitle: "Weekly retro",
                    eventId: otherEventId,
                    newFeedbackCount: 1,
                    seenByManager: false
                )
            ],
            unseenTotal: 3
        )
        let cache = APIClientCache(bootstrap: session)

        try await cache.markEventAsSeen(eventId: Self.eventId)

        let updated = await cache.getBootstrap()
        #expect(updated?.managerData?.notificationHistory.unseenTotal == 2)
        #expect(updated?.managerData?.notificationHistory.items.first { $0.id == firstNotificationId }?.seenByManager == true)
        #expect(updated?.managerData?.notificationHistory.items.first { $0.id == secondNotificationId }?.seenByManager == false)
    }
}

private extension APIClientLiveTests {
    static let referenceDate = Date(timeIntervalSince1970: 1_710_000_000)
    static let eventId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let questionId = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let activityItemId = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    static let sessionHash = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
    static let existingEventId = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!
    static let createdActivityId = UUID(uuidString: "00000000-0000-0000-0000-000000000006")!
    static let createdSessionId = UUID(uuidString: "00000000-0000-0000-0000-000000000007")!

    static func makeClient(
        api: MockAPI,
        cache: APIClientCache = APIClientCache(),
        provideFcmToken: @escaping @Sendable () async -> String? = { "fcm-default" }
    ) -> APIClient {
        APIClient.live(client: api, provideFcmToken: provideFcmToken, sessionCache: cache)
    }

    static func ownerDto() -> Components.Schemas.OwnerDto {
        .init(id: UUID().uuidString, name: "Owner", email: "owner@example.com")
    }

    static func ownerInfoDto() -> Components.Schemas.OwnerInfoDto {
        .init(name: "Owner", email: "owner@example.com", phoneNumber: "12345678")
    }

    static func questionDto() -> Components.Schemas.QuestionDto {
        .init(id: questionId.uuidString, text: "How did it go?")
    }

    static func participantQuestionDto() -> Components.Schemas.ParticipantQuestionDto {
        .init(id: questionId.uuidString, questionText: "How did it go?", feedbackType: .emoji)
    }

    static func participantEventDto(feedbackSubmited: Bool = false) -> Components.Schemas.ParticipantEventDto {
        .init(
            id: eventId.uuidString,
            date: referenceDate,
            pinCode: "456789",
            durationInMinutes: 45,
            location: "Room Blue",
            createdFromMailListener: false,
            ownerInfo: ownerInfoDto(),
            questions: [participantQuestionDto()],
            feedbackSubmited: feedbackSubmited,
            recentlyJoined: true
        )
    }

    static func feedbackEventDto() -> Components.Schemas.FeedbackEventDto {
        .init(
            questions: [participantQuestionDto()],
            ownerInfo: ownerInfoDto(),
            date: referenceDate
        )
    }

    static func feedbackFlowDto(title: String, id: String = eventId.uuidString) -> Components.Schemas.FeedbackFlowDto {
        .init(
            id: id,
            title: title,
            owner: ownerDto(),
            newFeedback: true,
            analytics: .init(averageRating: 4.2, trendStatus: .stable, lastSessionAt: referenceDate, ratingTrend: []),
            insights: .init(summary: "Talk through wins and blockers"),
            sessions: [],
            sessionSettings: .init(source: .manual),
            currentQuestions: [questionDto()]
        )
    }

    static func notificationHistory(unseenTotal: Int) -> NotificationHistory {
        .init(
            items: [
                .init(
                    id: activityItemId,
                    date: referenceDate,
                    eventTitle: "Weekly retro",
                    eventId: eventId,
                    newFeedbackCount: 2,
                    seenByManager: false
                )
            ],
            unseenTotal: unseenTotal
        )
    }

    static func event(
        id: UUID = eventId,
        title: String = "Weekly retro",
        unseenResponses: Int = 0
    ) -> Event {
        .init(
            id: id,
            title: title,
            agenda: "Talk through wins and blockers",
            date: referenceDate,
            pinCode: .init(value: "456789"),
            durationInMinutes: 45,
            location: "Room Blue",
            ownerInfo: .init(name: "Owner", email: "owner@example.com", phoneNumber: "12345678"),
            overallFeedbackSummary: .init(
                segmentationStats: .init(verySadPercentage: 0, sadPercentage: 0, happyPercentage: 100, veryHappyPercentage: 0),
                countStats: .init(verySadCount: 0, sadCount: 0, happyCount: 1, veryHappyCount: 0, commentsCount: 0),
                unseenResponses: unseenResponses,
                responses: 1
            ),
            questions: [
                .init(
                    id: questionId,
                    questionText: "How did it go?",
                    feedbackType: .emoji,
                    feedback: [],
                    feedbackSummary: nil
                )
            ],
            isDraft: false,
            invitedEmails: [],
            participants: [],
            calendarProvider: nil
        )
    }

    static func managerSession(events: [Event] = [event()], unseenTotal: Int = 0) -> Bootstrap {
        .init(
            participantEvents: [],
            managerData: .init(
                activities: .init(uniqueElements: events),
                notificationHistory: notificationHistory(unseenTotal: unseenTotal),
                questionAnalytics: [.mock()],
                bootstrapHash: sessionHash
            ),
            accountInfo: .init(name: "Account", email: "account@example.com", phoneNumber: "12345678"),
            role: .manager
        )
    }

    static func participantSession() -> Bootstrap {
        .init(
            participantEvents: [],
            managerData: nil,
            accountInfo: .init(name: "Participant", email: "participant@example.com", phoneNumber: nil),
            role: .participant
        )
    }

    static func managerDataDto() -> Components.Schemas.ManagerDataDto {
        .init(
            activities: [createdActivityDto(title: "Weekly retro")],
            notificationHistory: .init(
                items: [
                    .init(
                        id: activityItemId.uuidString,
                        date: referenceDate,
                        eventTitle: "Weekly retro",
                        eventId: eventId.uuidString,
                        newFeedbackCount: 2,
                        seenByManager: false
                    )
                ],
                unseenTotal: 2
            ),
            bootstrapHash: sessionHash.uuidString,
            questionAnalytics: [questionAnalyticsDto()]
        )
    }

    static func questionAnalyticsDto() -> Components.Schemas.ManagerQuestionAnalyticsDto {
        .init(
            questionId: questionId.uuidString,
            questionText: "How did it go?",
            feedbackType: .emoji,
            eventCount: 1,
            responseCount: 1,
            latestAskedAt: referenceDate,
            overallSummary: nil,
            timeline: []
        )
    }

    static func bootstrapDto(role: String?, managerData: Components.Schemas.ManagerDataDto? = nil) -> Components.Schemas.BootstrapDto {
        .init(
            role: role,
            accountInfo: .init(name: "Account", email: "account@example.com", phoneNumber: "12345678"),
            managerData: managerData
        )
    }

    static func sessionDto() -> Components.Schemas.SessionDto {
        .init(
            id: UUID().uuidString,
            averageRating: 3.5,
            ratingDelta: 0.4,
            summary: "Summary",
            questionSummary: .init(positives: ["Good"], improvements: ["Faster"]),
            questionsSnapshot: [questionDto()]
        )
    }

    static func createdActivityDto(title: String) -> Components.Schemas.ActivityDto {
        .init(
            id: createdActivityId.uuidString,
            title: title,
            owner: ownerDto(),
            runMode: .manual,
            sendEmails: false,
            invitedEmails: [],
            events: [createdEventDto()],
            currentQuestions: [questionDto()],
            trend: .init(
                direction: .stable,
                indicator: .neutral,
                metric: .averageRating,
                comparedEventCount: 1
            )
        )
    }

    static func createdEventDto() -> Components.Schemas.EventDto {
        .init(
            id: createdSessionId.uuidString,
            date: referenceDate,
            durationInMinutes: 45,
            location: "Room Blue",
            pinCode: "456789",
            createdFromMailListener: false,
            questionsSnapshot: [questionDto()]
        )
    }

    static func eventInput(title: String) -> EventInput {
        .init(
            title: title,
            agenda: "Talk through wins and blockers",
            date: referenceDate,
            durationInMinutes: 45,
            location: "Room Blue",
            questions: [
                .init(id: questionId, questionText: "How did it go?", feedbackType: .emoji)
            ]
        )
    }
}

struct APIClientMappingTests {
    @Test
    func `Event input question maps to generated question input`() {
        let question = EventInput.QuestionInput(
            id: Self.questionId,
            questionText: "How did it go?",
            feedbackType: .emoji
        )

        let feedbackTypePayload = Components.Schemas.QuestionInput.FeedbackTypePayload(.emoji)
        let dto = Components.Schemas.QuestionInput(question)

        #expect(feedbackTypePayload == .emoji)
        #expect(dto.questionText == question.questionText)
        #expect(dto.feedbackType == .emoji)
    }

    @Test
    func `Event input maps to generated DTO`() {
        let event = EventInput(
            title: "Weekly retro",
            agenda: "Talk through wins and blockers",
            date: Self.referenceDate,
            durationInMinutes: 45,
            location: "Room Blue",
            questions: [
                .init(id: Self.questionId, questionText: "How did it go?", feedbackType: .emoji),
                .init(id: Self.secondQuestionId, questionText: "What should improve?", feedbackType: .comment)
            ]
        )

        let dto = Components.Schemas.EventInput(event)

        #expect(dto.title == event.title)
        #expect(dto.agenda == event.agenda)
        #expect(dto.date == event.date)
        #expect(dto.durationInMinutes == 45)
        #expect(dto.location == event.location)
        #expect(dto.invitedEmails.isEmpty)
        #expect(dto.questions.count == 2)
        #expect(dto.questions[0].feedbackType == .emoji)
        #expect(dto.questions[1].feedbackType == .comment)
    }

    @Test
    func `Feedback enum payloads map from domain enums`() {
        #expect(Components.Schemas.FeedbackInput.ThumbsUpThumpsDownPayload(input: .down) == .down)
        #expect(Components.Schemas.FeedbackInput.EmojiPayload(input: .veryHappy) == .veryHappy)
        #expect(Components.Schemas.FeedbackInput.OpinionPayload(input: .stronglyAgree) == .stronglyAgree)
    }

    @Test
    func `Feedback inputs map to generated DTOs for every type`() {
        let cases: [(FeedbackInput, Components.Schemas.FeedbackInput)] = [
            (
                .init(type: .emoji(emoji: .happy, comment: "Nice"), questionId: Self.questionId),
                .init(comment: "Nice", emoji: .happy, questionId: Self.questionId.uuidString, feedbackType: .emoji)
            ),
            (
                .init(type: .comment(comment: "Hello"), questionId: Self.questionId),
                .init(comment: "Hello", questionId: Self.questionId.uuidString, feedbackType: .comment)
            ),
            (
                .init(type: .thumpsUpThumpsDown(thumbsUpThumpsDown: .up, comment: "Works"), questionId: Self.questionId),
                .init(comment: "Works", thumbsUpThumpsDown: .up, questionId: Self.questionId.uuidString, feedbackType: .thumpsUpThumpsDown)
            ),
            (
                .init(type: .opinion(opinion: .neutral, comment: "Mixed"), questionId: Self.questionId),
                .init(comment: "Mixed", opinion: .neutral, questionId: Self.questionId.uuidString, feedbackType: .opinion)
            ),
            (
                .init(type: .zeroToTen(zeroToTen: 8, comment: "Solid"), questionId: Self.questionId),
                .init(comment: "Solid", zeroToTen: 8, questionId: Self.questionId.uuidString, feedbackType: .zeroToTen)
            )
        ]

        for (input, expected) in cases {
            #expect(Components.Schemas.FeedbackInput(input) == expected)
        }
    }

    @Test
    func `Owner and account DTOs map to domain models`() {
        let owner = OwnerInfo(Self.ownerDto())
        let ownerInfo = OwnerInfo(Self.ownerInfoDto())
        let accountInfo = AccountInfo(Self.accountInfoDto())

        #expect(owner.name == "Owner")
        #expect(owner.email == "owner@example.com")
        #expect(owner.phoneNumber == nil)
        #expect(ownerInfo.phoneNumber == "12345678")
        #expect(accountInfo.name == "Account")
        #expect(accountInfo.email == "account@example.com")
        #expect(accountInfo.phoneNumber == "87654321")
    }

    @Test
    func `Participant DTOs map to domain models`() {
        let question = ParticipantQuestion(Self.participantQuestionDto())
        let event = ParticipantEvent(Self.participantEventDto())

        #expect(question.id == Self.questionId)
        #expect(question.questionText == "How did it go?")
        #expect(question.feedbackType == .emoji)
        #expect(event.id == Self.eventId)
        #expect(event.pinCode == .init(value: "456789"))
        #expect(event.questions == [question])
        #expect(event.ownerInfo == .init(name: "Owner", email: "owner@example.com", phoneNumber: "12345678"))
        #expect(event.feedbackSubmited == false)
        #expect(event.recentlyJoined == true)
    }

    @Test
    func `Activity DTOs map to domain models`() {
        let item = ActivityItems(Self.activityItemDto())
        let activity = Activity(Self.activityDto())

        #expect(item.id == Self.activityItemId)
        #expect(item.eventId == Self.eventId)
        #expect(item.newFeedbackCount == 3)
        #expect(activity.items == [item])
        #expect(activity.unseenTotal == 4)
    }

    @Test
    func `Feedback flow DTOs map to manager models`() {
        let question = ManagerQuestion(Self.questionDto())
        let analytics = ManagerQuestionAnalytics(Self.questionAnalyticsDto())
        let activity = Activity(Self.createdActivityDto(title: "Weekly retro"), questionAnalytics: [analytics])

        #expect(question.id == Self.questionId)
        #expect(question.questionText == "How did it go?")
        #expect(question.feedbackType == .comment)
        #expect(question.feedback.isEmpty)
        #expect(question.feedbackSummary == nil)
        #expect(analytics.questionId == Self.questionId)
        #expect(analytics.questionText == "How did it go?")
        #expect(analytics.feedbackType == .emoji)
        #expect(analytics.eventCount == 1)
        #expect(analytics.responseCount == 1)
        #expect(activity.id == Self.createdActivityId)
        #expect(activity.title == "Weekly retro")
        #expect(activity.agenda == "Talk through wins and blockers")
        #expect(activity.events.count == 1)
        #expect(activity.questions.count == 1)
        #expect(activity.questions[0].feedbackSummary == nil)
    }

    @Test
    func `Feedback event DTO maps to feedback event`() {
        let pinCode = PinCode(value: "456789")
        let session = FeedbackEventDto(Self.feedbackEventDto(), pinCode: pinCode)

        #expect(session.title == "Event")
        #expect(session.agenda == nil)
        #expect(session.questions.count == 1)
        #expect(session.ownerInfo == .init(name: "Owner", email: "owner@example.com", phoneNumber: "12345678"))
        #expect(session.pinCode == pinCode)
        #expect(session.date == Self.referenceDate)
    }

    @Test
    func `Domain codes and API error map from generated error DTOs`() {
        let domainCodeCases: [(Components.Schemas.ApiError.DomainCodePayload, DomainCode)] = [
            (.feedbackAlreadySubmitted, .feedbackAlreadySubmitted),
            (.eventAlreadyJoined, .eventAlreadyJoined),
            (.cannotJoinOwnEvent, .cannotJoinOwnEvent),
            (.cannotGiveFeedbackToSelf, .cannotGiveFeedbackToSelf),
            (.pincodeNotFound, .pincodeNotFound)
        ]

        for (dto, expected) in domainCodeCases {
            let actual = DomainCode(domainCodeDto: dto)
            switch (actual, expected) {
            case (.feedbackAlreadySubmitted, .feedbackAlreadySubmitted),
                (.eventAlreadyJoined, .eventAlreadyJoined),
                (.cannotJoinOwnEvent, .cannotJoinOwnEvent),
                (.cannotGiveFeedbackToSelf, .cannotGiveFeedbackToSelf),
                (.pincodeNotFound, .pincodeNotFound):
                #expect(true)
            default:
                Issue.record("Unexpected domain code mapping for \(dto)")
            }
        }

        let error = ApiError(
            apiErrorDto: .init(
                timestamp: "2026-03-22T10:00:00Z",
                message: "No such event",
                domainCode: .pincodeNotFound,
                exceptionType: "IllegalStateException",
                path: "/event/join"
            )
        )

        #expect(error.timestamp == "2026-03-22T10:00:00Z")
        #expect(error.message == "No such event")
        #expect(error.exceptionType == "IllegalStateException")
        #expect(error.path == "/event/join")
        switch error.domainCode {
        case .some(.pincodeNotFound):
            #expect(true)
        default:
            Issue.record("Expected pincodeNotFound domain code")
        }
    }

    @Test
    func `Bootstrap, manager data and session DTOs map to sessions`() {
        let managerData = ManagerData(Self.managerDataDto())
        let managerBootstrap = Bootstrap(Self.bootstrapDto(role: "Manager", managerData: Self.managerDataDto()))
        let participantBootstrap = Bootstrap(Self.bootstrapDto(role: "Participant"))
        let anonymousBootstrap = Bootstrap(Self.bootstrapDto(role: nil))
        let sessionDto = Bootstrap(Self.sessionDto())

        #expect(managerData.activities.count == 1)
        #expect(managerData.notificationHistory == Self.notificationHistory(unseenTotal: 4))
        #expect(managerData.bootstrapHash == Self.sessionHash)
        #expect(managerData.questionAnalytics.count == 1)
        #expect(managerBootstrap.role == .manager)
        #expect(managerBootstrap.managerData == managerData)
        #expect(managerBootstrap.accountInfo == AccountInfo(Self.accountInfoDto()))
        #expect(participantBootstrap.role == .participant)
        #expect(participantBootstrap.managerData == nil)
        #expect(anonymousBootstrap.role == nil)
        #expect(sessionDto.participantEvents.isEmpty)
        #expect(sessionDto.managerData == nil)
        #expect(sessionDto.accountInfo == .init(name: nil, email: nil, phoneNumber: nil))
        #expect(sessionDto.role == nil)
    }
}

private extension APIClientMappingTests {
    static let referenceDate = Date(timeIntervalSince1970: 1_710_000_000)
    static let eventId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let questionId = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let secondQuestionId = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    static let activityItemId = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
    static let sessionHash = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!

    static func ownerDto() -> Components.Schemas.OwnerDto {
        .init(
            id: UUID().uuidString,
            name: "Owner",
            email: "owner@example.com"
        )
    }

    static func ownerInfoDto() -> Components.Schemas.OwnerInfoDto {
        .init(
            name: "Owner",
            email: "owner@example.com",
            phoneNumber: "12345678"
        )
    }

    static func accountInfoDto() -> Components.Schemas.AccountInfoDto {
        .init(
            name: "Account",
            email: "account@example.com",
            phoneNumber: "87654321"
        )
    }

    static func questionDto() -> Components.Schemas.QuestionDto {
        .init(
            id: questionId.uuidString,
            text: "How did it go?"
        )
    }

    static func participantQuestionDto() -> Components.Schemas.ParticipantQuestionDto {
        .init(
            id: questionId.uuidString,
            questionText: "How did it go?",
            feedbackType: .emoji
        )
    }

    static func participantEventDto() -> Components.Schemas.ParticipantEventDto {
        .init(
            id: eventId.uuidString,
            date: referenceDate,
            pinCode: "456789",
            durationInMinutes: 45,
            location: "Room Blue",
            createdFromMailListener: false,
            ownerInfo: ownerInfoDto(),
            questions: [participantQuestionDto()],
            feedbackSubmited: false,
            recentlyJoined: true
        )
    }

    static func activityItemDto() -> Components.Schemas.ActivityItem {
        .init(
            id: activityItemId.uuidString,
            date: referenceDate,
            eventTitle: "Weekly retro",
            eventId: eventId.uuidString,
            newFeedbackCount: 3,
            seenByManager: false
        )
    }

    static func activityDto() -> Components.Schemas.ActivityDto {
        .init(
            items: [activityItemDto()],
            unseenTotal: 4
        )
    }

    static func feedbackFlowDto() -> Components.Schemas.FeedbackFlowDto {
        .init(
            id: eventId.uuidString,
            title: "Weekly retro",
            owner: ownerDto(),
            newFeedback: true,
            analytics: .init(
                averageRating: 4.2,
                trendStatus: .stable,
                lastSessionAt: referenceDate,
                ratingTrend: []
            ),
            insights: .init(summary: "Talk through wins and blockers"),
            sessions: [],
            sessionSettings: .init(source: .manual),
            currentQuestions: [questionDto()]
        )
    }

    static func feedbackEventDto() -> Components.Schemas.FeedbackEventDto {
        .init(
            questions: [participantQuestionDto()],
            ownerInfo: ownerInfoDto(),
            date: referenceDate
        )
    }

    static func managerDataDto() -> Components.Schemas.ManagerDataDto {
        .init(
            feedbackFlows: [feedbackFlowDto()],
            activity: activityDto(),
            sessionHash: sessionHash.uuidString
        )
    }

    static func bootstrapDto(role: String?, managerData: Components.Schemas.ManagerDataDto? = nil) -> Components.Schemas.BootstrapDto {
        .init(
            role: role,
            accountInfo: accountInfoDto(),
            managerData: managerData
        )
    }

    static func sessionDto() -> Components.Schemas.SessionDto {
        .init(
            id: UUID().uuidString,
            averageRating: 3.5,
            ratingDelta: 0.5,
            summary: "Summary",
            questionSummary: .init(positives: ["Good"], improvements: ["Faster"]),
            questionsSnapshot: [questionDto()]
        )
    }
}
