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
        let client = APIFixture.makeClient(
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
        let cache = APIClientCache(bootstrap: APIFixture.managerSession())
        let client = APIFixture.makeClient(
            api: MockAPI(
                modifyAccountHandler: { request in
                    input.setValue(request)
                    return .ok
                }
            ),
            cache: cache
        )

        try await client.modifyAccount("", "updated@example.com", "")

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
        let client = APIFixture.makeClient(
            api: MockAPI(
                updateRoleHandler: { request in
                    roleInput.setValue(request)
                    return .ok
                },
                linkFCMTokenToAccountHandler: { request in
                    fcmInput.setValue(request)
                    return .ok
                }
            )
        )

        try await client.linkFCMTokenToAccount("fcm-123")
        try await client.updateRole(.manager)

        guard let capturedFCMInput = fcmInput.value, case .json(let fcmBody) = capturedFCMInput.body else {
            Issue.record("Expected linkFCMTokenToAccount JSON body")
            return
        }
        guard let capturedRoleInput = roleInput.value, case .json(let roleBody) = capturedRoleInput.body else {
            Issue.record("Expected updateRole JSON body")
            return
        }

        #expect(fcmBody.fcmToken == "fcm-123")
        #expect(roleBody.role == "Manager")
    }

    @Test
    func `Logout does not call API when FCM token is unavailable`() async throws {
        let logoutCalled = LockIsolated(false)
        let client = APIFixture.makeClient(
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
        let client = APIFixture.makeClient(
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
        let bootstrap = APIFixture.bootstrapDto(role: "Manager", managerData: APIFixture.managerDataDto())
        let cache = APIClientCache(bootstrap: nil)
        let client = APIFixture.makeClient(
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
        let client = APIFixture.makeClient(
            api: MockAPI(
                startFeedbackEventHandler: { request in
                    input.setValue(request)
                    return .ok(.init(body: .json(APIFixture.feedbackEventDto())))
                }
            )
        )

        let session = try await client.startFeedbackEvent(pinCode)

        guard let captured = input.value, case .json(let body) = captured.body else {
            Issue.record("Expected startFeedbackEvent JSON body")
            return
        }
        #expect(body.pinCode == "456789")
        #expect(session == FeedbackEventDto(APIFixture.feedbackEventDto(), pinCode: pinCode))
    }

    @Test
    func `Submit feedback forwards mapped payload and updates participant cache`() async throws {
        let input = LockIsolated<Operations.SubmitFeedback.Input?>(nil)
        let cache = APIClientCache(bootstrap: APIFixture.participantSession())
        let feedback = FeedbackInput(
            type: .emoji(emoji: .veryHappy, comment: "Great"),
            questionId: APIFixture.questionId
        )
        let client = APIFixture.makeClient(
            api: MockAPI(
                submitFeedbackHandler: { request in
                    input.setValue(request)
                    return .ok(
                        .init(
                            body: .json(
                                .init(
                                    shouldPresentRatingPrompt: true,
                                    event: APIFixture.participantEventDto(feedbackSubmited: true)
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
        #expect(snapshot?.participantEvents[id: APIFixture.eventId]?.feedbackSubmited == true)
    }

    @Test
    func `Create and update event calls refresh the cached session in its activity`() async throws {
        let createInput = LockIsolated<Operations.CreateEvent.Input?>(nil)
        let updateInput = LockIsolated<Operations.UpdateEvent.Input?>(nil)
        let cache = APIClientCache(bootstrap: APIFixture.managerSession(events: [APIFixture.event(id: APIFixture.existingEventId)]))
        let client = APIFixture.makeClient(
            api: MockAPI(
                updateEventHandler: { request in
                    updateInput.setValue(request)
                    return .ok(.init(body: .json(APIFixture.createdEventDto(id: request.path.eventId))))
                },
                createEventHandler: { request in
                    createInput.setValue(request)
                    return .ok(.init(body: .json(APIFixture.createdEventDto())))
                }
            ), cache: cache
        )

        let created = try await client.createEvent(APIFixture.sessionInput(location: "Created room"))
        let updated = try await client.updateEvent(APIFixture.sessionInput(location: "Updated room"), APIFixture.createdSessionId)
        guard let capturedCreate = createInput.value, case .json(let createBody) = capturedCreate.body,
              let capturedUpdate = updateInput.value, case .json(let updateBody) = capturedUpdate.body else {
            Issue.record("Expected create and update JSON bodies")
            return
        }
        let snapshot = await cache.getBootstrap()
        let events = snapshot?.managerData?.activities[id: APIFixture.createdActivityId]?.events
        #expect(createBody.activityId == APIFixture.createdActivityId.uuidString)
        #expect(createBody.location == "Created room")
        #expect(updateBody.location == "Updated room")
        #expect(created == Event(APIFixture.createdEventDto()))
        #expect(updated == created)
        #expect(events?.count == 2)
        #expect(events?.first { $0.id == APIFixture.createdSessionId } == updated)
        #expect(events?.contains { $0.id == APIFixture.existingEventId } == true)
    }

    @Test
    func `Event deletion refreshes bootstrap and emits the updated cache`() async throws {
        let secondId = UUID(uuidString: "00000000-0000-0000-0000-000000000099")!
        var refreshedData = APIFixture.managerDataDto()
        refreshedData.activities[0].events = [APIFixture.createdEventDto(id: secondId.uuidString)]
        let response = APIFixture.bootstrapDto(role: "Manager", managerData: refreshedData)
        let cache = APIClientCache(bootstrap: APIFixture.managerSession(events: [APIFixture.event(), APIFixture.event(id: secondId)]))
        let client = APIFixture.makeClient(
            api: MockAPI(
                deleteEventHandler: { _ in .ok },
                getBootstrapHandler: { _ in .ok(.init(body: .json(response))) }
            ), cache: cache
        )
        var listener = await client.sessionChangedListener().makeAsyncIterator()
        try await client.deleteEvent(APIFixture.eventId)
        let snapshot = await cache.getBootstrap()
        let emitted = await listener.next()
        #expect(snapshot?.managerData?.activities.first?.events.map(\.id) == [secondId])
        #expect(emitted == snapshot)
    }

    @Test
    func `Create account forwards role and FCM token and caches the returned bootstrap`() async throws {
        let createInput = LockIsolated<Operations.CreateAccount.Input?>(nil)
        let bootstrapCalls = LockIsolated(0)
        let bootstrap = APIFixture.bootstrapDto(role: "Manager", managerData: APIFixture.managerDataDto())
        let cache = APIClientCache(bootstrap: nil)
        let client = APIFixture.makeClient(
            api: MockAPI(
                createAccountHandler: { request in
                    createInput.setValue(request)
                    return .ok(.init(body: .json(bootstrap)))
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
        #expect(bootstrapCalls.value == 0)
        #expect(session == Bootstrap(bootstrap))
        #expect(snapshot == Bootstrap(bootstrap))
    }

    @Test
    func `Join event appends the participant event to session`() async throws {
        let input = LockIsolated<Operations.JoinEvent.Input?>(nil)
        let cache = APIClientCache(bootstrap: APIFixture.participantSession())
        let client = APIFixture.makeClient(
            api: MockAPI(
                joinEventHandler: { request in
                    input.setValue(request)
                    return .ok(.init(body: .json(APIFixture.participantEventDto())))
                }
            ),
            cache: cache
        )

        try await client.joinEvent(PinCode(value: "456789"))

        let snapshot = await cache.getBootstrap()
        #expect(input.value?.path.pinCode == "456789")
        #expect(snapshot?.participantEvents[id: APIFixture.eventId] != nil)
    }

    @Test
    func `Manager event is marked as seen`() async throws {
        let cache = APIClientCache(bootstrap: APIFixture.managerSession(events: [APIFixture.event(unseenResponses: 1)], unseenTotal: 1))
        let client = APIFixture.makeClient(
            api: MockAPI(
                markEventAsSeenHandler: { _ in .ok }
            ),
            cache: cache
        )

        try await client.markEventAsSeen(APIFixture.eventId)

        let updated = await cache.getBootstrap()
        #expect(updated?.managerData?.activities[id: APIFixture.createdActivityId]?.events.first?.overallFeedbackSummary?.unseenResponses == 0)
        #expect(updated?.managerData?.notificationHistory.unseenTotal == 0)
        #expect(updated?.managerData?.notificationHistory.items.allSatisfy { $0.seenByManager } == true)
    }

    @Test
    func `Updated session returns nil without a cached hash`() async throws {
        let client = APIFixture.makeClient(api: MockAPI(), cache: APIClientCache(bootstrap: Bootstrap.mockParticipant()))

        let result = try await client.getBootstrapUpdate()

        #expect(result == nil)
    }

    @Test
    func `Updated session fetches bootstrap update and refreshes the cache`() async throws {
        let input = LockIsolated<Operations.GetBoostrapUpdate.Input?>(nil)
        let bootstrap = APIFixture.bootstrapDto(role: "Manager", managerData: APIFixture.managerDataDto())
        let cache = APIClientCache(bootstrap: APIFixture.managerSession())
        let client = APIFixture.makeClient(
            api: MockAPI(
                getBoostrapUpdateHandler: { request in
                    input.setValue(request)
                    return .ok(.init(body: .json(bootstrap)))
                }
            ),
            cache: cache
        )

        let result = try await client.getBootstrapUpdate()
        let snapshot = await cache.getBootstrap()

        #expect(input.value?.path.hash == APIFixture.sessionHash.uuidString)
        #expect(result == Bootstrap(bootstrap))
        #expect(snapshot == Bootstrap(bootstrap))
    }

    @Test
    func `Updated session keeps cache unchanged when bootstrap hash is unchanged`() async throws {
        let input = LockIsolated<Operations.GetBoostrapUpdate.Input?>(nil)
        let existingSession = APIFixture.managerSession()
        let cache = APIClientCache(bootstrap: existingSession)
        let client = APIFixture.makeClient(
            api: MockAPI(
                getBoostrapUpdateHandler: { request in
                    input.setValue(request)
                    return .noContent
                }
            ),
            cache: cache
        )

        let result = try await client.getBootstrapUpdate()
        let snapshot = await cache.getBootstrap()

        #expect(input.value?.path.hash == APIFixture.sessionHash.uuidString)
        #expect(result == nil)
        #expect(snapshot == existingSession)
    }

    @Test
    func `Manager notification history is marked as seen`() async throws {
        let cache = APIClientCache(bootstrap: APIFixture.managerSession(events: [APIFixture.event(unseenResponses: 1)], unseenTotal: 1))
        let client = APIFixture.makeClient(
            api: MockAPI(
                markNotificationHistoryAsSeenHandler: { _ in .ok }
            ),
            cache: cache
        )

        try await client.markNotificationHistoryAsSeen()

        let updated = await cache.getBootstrap()
        #expect(updated?.managerData?.notificationHistory.unseenTotal == 0)
        #expect(updated?.managerData?.notificationHistory.items.allSatisfy { $0.seenByManager } == true)
    }

    @Test
    func `Manager-only cache mutations throw when manager state is unavailable`() async throws {
        let cache = APIClientCache(bootstrap: APIFixture.participantSession())

        do {
            try await cache.markEventAsSeen(eventId: APIFixture.eventId)
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
        let cache = APIClientCache(bootstrap: APIFixture.managerSession())
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

        var session = APIFixture.managerSession(events: [APIFixture.event(unseenResponses: 1)], unseenTotal: 3)
        session.managerData?.notificationHistory = .init(
            items: [
                .init(
                    id: firstNotificationId,
                    date: APIFixture.referenceDate,
                    eventTitle: "Weekly retro",
                    eventId: APIFixture.eventId,
                    newFeedbackCount: 1,
                    seenByManager: false
                ),
                .init(
                    id: secondNotificationId,
                    date: APIFixture.referenceDate,
                    eventTitle: "Weekly retro",
                    eventId: otherEventId,
                    newFeedbackCount: 1,
                    seenByManager: false
                )
            ],
            unseenTotal: 3
        )
        let cache = APIClientCache(bootstrap: session)

        try await cache.markEventAsSeen(eventId: APIFixture.eventId)

        let updated = await cache.getBootstrap()
        #expect(updated?.managerData?.notificationHistory.unseenTotal == 2)
        #expect(updated?.managerData?.notificationHistory.items.first { $0.id == firstNotificationId }?.seenByManager == true)
        #expect(updated?.managerData?.notificationHistory.items.first { $0.id == secondNotificationId }?.seenByManager == false)
    }
}

private enum APIFixture {
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
        .init(id: questionId.uuidString, text: "How did it go?", feedbackType: .emoji, feedback: [])
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

    static func event(id: UUID = eventId, unseenResponses: Int = 0) -> Event {
        var event = Event(createdEventDto(id: id.uuidString))
        event.overallFeedbackSummary = .init(
            segmentationStats: .init(verySadPercentage: 0, sadPercentage: 0, happyPercentage: 100, veryHappyPercentage: 0),
            countStats: .init(verySadCount: 0, sadCount: 0, happyCount: 1, veryHappyCount: 0, commentsCount: 0),
            unseenResponses: unseenResponses, responses: 1
        )
        return event
    }

    static func managerSession(events: [Event] = [event()], unseenTotal: Int = 0) -> Bootstrap {
        var activity = Activity(createdActivityDto(title: "Weekly retro"))
        activity.events = events
        return .init(
            participantEvents: [],
            managerData: .init(
                activities: .init(uniqueElements: [activity]),
                notificationHistory: notificationHistory(unseenTotal: unseenTotal),
                questionAnalytics: [.mock()], bootstrapHash: sessionHash
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
            participantEvents: [],
            managerData: managerData
        )
    }



    static func createdActivityDto(title: String) -> Components.Schemas.ActivityDto {
        .init(
            id: createdActivityId.uuidString,
            title: title,
            activityEmail: "1234@letsgrow.dk",
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

    static func createdEventDto(id: String = createdSessionId.uuidString) -> Components.Schemas.EventDto {
        .init(
            id: id,
            date: referenceDate,
            durationInMinutes: 45,
            location: "Room Blue",
            pinCode: "456789",
            createdFromMailListener: false,
            questionsSnapshot: [questionDto()]
        )
    }

    static func sessionInput(location: String) -> SessionInput {
        .init(activityId: createdActivityId, date: referenceDate, durationInMinutes: 45, location: location)
    }
}

struct APIClientMappingTests {
    @Test
    func `Question input maps its identity text and format`() {
        let input = EventInput.QuestionInput(id: APIFixture.questionId, questionText: "How did it go?", feedbackType: .emoji)
        let dto = Components.Schemas.QuestionInput(input)
        #expect(dto.id == input.id.uuidString)
        #expect(dto.questionText == input.questionText)
        #expect(dto.feedbackType == .emoji)
    }

    @Test
    func `Legacy event input maps to activity configuration`() {
        let input = EventInput(title: "Weekly retro", agenda: "Agenda", questions: [
            .init(questionText: "How did it go?", feedbackType: .emoji),
            .init(questionText: "What should improve?", feedbackType: .comment)
        ])
        let dto = Components.Schemas.ActivityInput(legacyEvent: input)
        #expect(dto.title == input.title)
        #expect(dto.agenda == input.agenda)
        #expect(dto.invitedEmails.isEmpty)
        #expect(dto.questions.map(\.questionText) == input.questions.map(\.questionText))
        #expect(dto.questions[0].feedbackType == .emoji)
        #expect(dto.questions[1].feedbackType == .comment)
    }

    @Test
    func `Session input maps scheduling fields and owning activity`() {
        let input = APIFixture.sessionInput(location: "Room Blue")
        let dto = Components.Schemas.EventInput(input)
        #expect(dto.activityId == input.activityId.uuidString)
        #expect(dto.date == input.date)
        #expect(dto.durationInMinutes == 45)
        #expect(dto.location == input.location)
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
                .init(type: .emoji(emoji: .happy, comment: "Nice"), questionId: APIFixture.questionId),
                .init(comment: "Nice", emoji: .happy, questionId: APIFixture.questionId.uuidString, feedbackType: .emoji)
            ),
            (
                .init(type: .comment(comment: "Hello"), questionId: APIFixture.questionId),
                .init(comment: "Hello", questionId: APIFixture.questionId.uuidString, feedbackType: .comment)
            ),
            (
                .init(type: .thumpsUpThumpsDown(thumbsUpThumpsDown: .up, comment: "Works"), questionId: APIFixture.questionId),
                .init(comment: "Works", thumbsUpThumpsDown: .up, questionId: APIFixture.questionId.uuidString, feedbackType: .thumpsUpThumpsDown)
            ),
            (
                .init(type: .opinion(opinion: .neutral, comment: "Mixed"), questionId: APIFixture.questionId),
                .init(comment: "Mixed", opinion: .neutral, questionId: APIFixture.questionId.uuidString, feedbackType: .opinion)
            ),
            (
                .init(type: .zeroToTen(zeroToTen: 8, comment: "Solid"), questionId: APIFixture.questionId),
                .init(comment: "Solid", zeroToTen: 8, questionId: APIFixture.questionId.uuidString, feedbackType: .zeroToTen)
            )
        ]

        for (input, expected) in cases {
            #expect(Components.Schemas.FeedbackInput(input) == expected)
        }
    }

    @Test
    func `Owner and account DTOs map to domain models`() {
        let owner = OwnerInfo(APIFixture.ownerDto())
        let ownerInfo = OwnerInfo(APIFixture.ownerInfoDto())
        let account = AccountInfo(APIFixture.bootstrapDto(role: nil).accountInfo)
        #expect(owner.name == "Owner")
        #expect(owner.email == "owner@example.com")
        #expect(owner.phoneNumber == nil)
        #expect(ownerInfo.phoneNumber == "12345678")
        #expect(account.name == "Account")
        #expect(account.email == "account@example.com")
    }

    @Test
    func `Participant DTOs map to domain models`() {
        let question = ParticipantQuestion(APIFixture.participantQuestionDto())
        let event = ParticipantEvent(APIFixture.participantEventDto())
        #expect(question.id == APIFixture.questionId)
        #expect(question.feedbackType == .emoji)
        #expect(event.id == APIFixture.eventId)
        #expect(event.questions == [question])
        #expect(event.pinCode == .init(value: "456789"))
        #expect(!event.feedbackSubmited)
        #expect(event.recentlyJoined)
    }

    @Test
    func `Notification history maps independently from activities`() {
        let history = NotificationHistory(APIFixture.managerDataDto().notificationHistory)
        #expect(history.items.count == 1)
        #expect(history.items.first?.id == APIFixture.activityItemId)
        #expect(history.items.first?.eventId == APIFixture.eventId)
        #expect(history.unseenTotal == 2)
    }

    @Test
    func `Activity and event DTOs preserve the owning activity boundary`() {
        let analytics = ManagerQuestionAnalytics(APIFixture.questionAnalyticsDto())
        let dto = APIFixture.createdActivityDto(title: "Weekly retro")
        let activity = Activity(dto, questionAnalytics: [analytics])
        #expect(activity.id == APIFixture.createdActivityId)
        #expect(activity.title == dto.title)
        #expect(activity.events == [Event(APIFixture.createdEventDto())])
        #expect(activity.questions.count == 1)
        #expect(activity.questions.first?.id == analytics.questionId)
        #expect(activity.questions.first?.feedbackType == .emoji)
        #expect(analytics.eventCount == 1)
        #expect(analytics.responseCount == 1)
    }

    @Test
    func `Feedback event DTO maps questions owner and pin code`() {
        let pin = PinCode(value: "456789")
        let feedback = FeedbackEventDto(APIFixture.feedbackEventDto(), pinCode: pin)
        #expect(feedback.questions.count == 1)
        #expect(feedback.ownerInfo == OwnerInfo(APIFixture.ownerInfoDto()))
        #expect(feedback.pinCode == pin)
        #expect(feedback.date == APIFixture.referenceDate)
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
    func `Bootstrap maps manager participant and anonymous roles`() {
        let dto = APIFixture.managerDataDto()
        let manager = Bootstrap(APIFixture.bootstrapDto(role: "Manager", managerData: dto))
        let participant = Bootstrap(APIFixture.bootstrapDto(role: "Participant"))
        let anonymous = Bootstrap(APIFixture.bootstrapDto(role: nil))
        #expect(manager.role == .manager)
        #expect(manager.managerData == ManagerData(dto))
        #expect(manager.managerData?.bootstrapHash == APIFixture.sessionHash)
        #expect(participant.role == .participant)
        #expect(participant.managerData == nil)
        #expect(anonymous.role == nil)
        #expect(anonymous.participantEvents.isEmpty)
    }
}
