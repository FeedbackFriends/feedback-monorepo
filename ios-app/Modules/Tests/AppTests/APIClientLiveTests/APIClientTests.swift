@testable import Domain
import Testing
import ComposableArchitecture
import Foundation
import Adapters
import OpenAPI

@MainActor
struct APIClientLiveTests {
    
    @Test
    func `Session is returned and saved in cache after being fetched`() async throws {
        
        let apiResponse: Components.Schemas.SessionDto = .init(
            role: "Manager",
            accountInfo: .init(),
            participantEvents: [],
            managerData: .init(
                managerEvents: [],
                activity: .init(
                    items: [],
                    unseenTotal: 5
                ),
                recentlyUsedQuestions: [
                    .init(
                        questionText: "Hello world",
                        feedbackType: .emoji,
                        updatedAt: Date(timeIntervalSince1970: 0)
                    )
                ],
                feedbackSessionHash: UUID().uuidString
            )
        )
        let cache = SessionCache(session: nil)
        let client = APIClient.live(
            client: MockAPI(
                getSessionHandler: { _ in
                        .ok(
                            .init(
                                body: .json(
                                    apiResponse
                                )
                            )
                        )
                }
            ),
            provideFcmToken: { "" },
            sessionCache: cache
        )
        let result = try await client.getSession()
        let snapshot = await cache.getSession()
        #expect(result == Session(apiResponse))
        #expect(snapshot == Session(apiResponse))
    }
    
    @Test
    func `Event is removed from cache after deletion and stream is triggered with updated session`() async throws {
        
        let event1 = ManagerEvent.mock()
        let event2 = ManagerEvent.mock()
        
        let cache = SessionCache(
            session: .init(
                participantEvents: .init(),
                managerData: .init(
                    managerEvents: .init(arrayLiteral: event1, event2),
                    activity: .mock,
                    recentlyUsedQuestions: [],
                    feedbackSessionHash: UUID()
                ),
                accountInfo: .init(
                    name: nil,
                    email: nil,
                    phoneNumber: nil
                ),
                role: .manager
            )
        )
        
        let client = APIClient.live(
            client: MockAPI(
                deleteEventHandler: { _ in
                        .ok(.init())
                }
            ),
            provideFcmToken: { "" },
            sessionCache: cache
        )
        
        var sessionChangedListener = await cache.sessionChangedListener().makeAsyncIterator()
        try await client.deleteEvent(event1.id)
        let snapshot = await cache.getSession()
        #expect(snapshot?.managerData?.managerEvents.count == 1)
        #expect(snapshot?.managerData?.managerEvents.first?.id == event2.id)
        let updatedSession = await sessionChangedListener.next()
        #expect(updatedSession == snapshot)
        
        try await client.deleteEvent(id: event2.id)
        let snapshot2 = await cache.getSession()
        #expect(snapshot2?.managerData?.managerEvents.isEmpty == true)
        let updatedSession2 = await sessionChangedListener.next()
        #expect(updatedSession2 == snapshot2)
    }
    
    @Test
    func `Updating an event apicall also updates the cache and stream is triggered with updated session`() async throws {
        
        let originalEvent = ManagerEvent(
            id: UUID(),
            title: "Original Title",
            agenda: nil,
            date: .now,
            pinCode: PinCode(value: "123456"),
            durationInMinutes: 30,
            location: "Room 1",
            ownerInfo: .init(name: nil, email: nil, phoneNumber: nil),
            overallFeedbackSummary: nil,
            questions: [],
            isDraft: false,
            invitedEmails: [],
            participants: [],
            calendarProvider: nil
        )
        let now: Date = .now
        
        let cache = SessionCache(
            session: .init(
                participantEvents: [],
                managerData: .init(
                    managerEvents: [originalEvent],
                    activity: .mock,
                    recentlyUsedQuestions: [],
                    feedbackSessionHash: UUID()
                ),
                accountInfo: .init(name: nil, email: nil, phoneNumber: nil),
                role: .manager
            )
        )
        
        let client = APIClient.live(
            client: MockAPI(
                updateEventHandler: { input in
                    switch input.body {
                    case .json(let body):
                        return .ok(
                            .init(
                                body: .json(
                                    .init(
                                        event: .init(
                                            id: input.path.eventId,
                                            title: input.path.eventId,
                                            agenda: body.agenda,
                                            date: body.date,
                                            pinCode: originalEvent.pinCode!.value,
                                            durationInMinutes: body.durationInMinutes,
                                            location: body.location,
                                            calendarProvider: nil,
                                            isDraft: false,
                                            ownerInfo: .init(
                                                name: originalEvent.ownerInfo.name,
                                                email: originalEvent.ownerInfo.email,
                                                phoneNumber: originalEvent.ownerInfo.phoneNumber
                                            ),
                                            overallFeedbackSummary: nil,
                                            invitedEmails: [],
                                            participants: [],
                                            questions: []
                                            
                                        ),
                                        recentlyUsedQuestions: [
                                            .init(
                                                questionText: "What you think?",
                                                feedbackType: .emoji,
                                                updatedAt: now
                                            )
                                        ]
                                    )
                                )
                            )
                        )
                    }
                }
            ),
            provideFcmToken: { ""
            },
            sessionCache: cache
        )
        
        var sessionChangedListener = await cache.sessionChangedListener().makeAsyncIterator()
        let response = try await client.updateEvent(
            eventInput: EventInput(
                title: "New title",
                agenda: "New agenda",
                date: Date(timeIntervalSince1970: 0),
                durationInMinutes: 1000,
                location: "New location",
                questions: [
                    EventInput.QuestionInput(
                        questionText: "New question",
                        feedbackType: FeedbackType.emoji
                    )
                ]
            ),
            id: originalEvent.id
        )
        let snapshot = await cache.getSession()
        #expect(snapshot?.managerData?.managerEvents.first == response)
        #expect(snapshot?.managerData?.managerEvents.count == 1)
        let onChangeSession = await sessionChangedListener.next()
        #expect(onChangeSession?.managerData?.managerEvents.first == snapshot?.managerData?.managerEvents.first)
    }
    
    @Test
    func `Recently used questions are updated in cache`() async {
        let initialQuestions: Set<RecentlyUsedQuestions> = [
            .init(questionText: "Old question", feedbackType: .emoji, updatedAt: .distantPast)
        ]
        let newQuestions: Set<RecentlyUsedQuestions> = [
            .init(questionText: "New question", feedbackType: .emoji, updatedAt: .now)
        ]
        
        let session = Session(
            participantEvents: [],
            managerData: .init(
                managerEvents: [],
                activity: .init(items: [], unseenTotal: 0),
                recentlyUsedQuestions: initialQuestions,
                feedbackSessionHash: UUID()
            ),
            accountInfo: .init(name: nil, email: nil, phoneNumber: nil),
            role: .manager
        )
        
        let cache = SessionCache(session: session)
        await cache.updateRecentlyUsedQuestions(recentlyUsedQuestions: newQuestions)
        
        let updatedSession = await cache.getSession()
        #expect(updatedSession?.managerData?.recentlyUsedQuestions == newQuestions)
    }
    
    @Test
    func `Participant event is appended to session`() async {
        let event = ParticipantEvent(
            id: UUID(),
            title: "Title",
            agenda: nil,
            date: .now,
            pinCode: PinCode(value: "000000"),
            location: nil,
            durationInMinutes: 30,
            questions: [],
            feedbackSubmitted: false,
            ownerInfo: .init(name: "Owner", email: nil, phoneNumber: nil),
            recentlyJoined: false
        )
        
        let session = Session(
            participantEvents: [],
            managerData: nil,
            accountInfo: .init(name: nil, email: nil, phoneNumber: nil),
            role: .participant
        )
        
        let cache = SessionCache(session: session)
        await cache.updateOrAppendParticipantEvent(event)
        
        let updated = await cache.getSession()
        #expect(updated?.participantEvents.contains(where: { $0.id == event.id }) == true)
    }
    
    @Test
    func `Account information is updated in cache`() async {
        let session = Session.mock()
        let cache = SessionCache(session: session)
        
        await cache.updateAccount(name: "Jane", email: "jane@ai.dk", phoneNumber: "42424242")
        let updated = await cache.getSession()
        
        #expect(updated?.accountInfo.name == "Jane")
        #expect(updated?.accountInfo.email == "jane@ai.dk")
        #expect(updated?.accountInfo.phoneNumber == "42424242")
    }
    
    @Test
    func `Manager event is marked as seen`() async {
        let eventId = UUID()
        let emojiFeedbackSummary = EmojiQuestionFeedbackSummary(
            countVerySad: 0,
            countSad: 0,
            countHappy: 0,
            countVeryHappy: 0,
            percentageVerySad: 0,
            percentageSad: 0,
            percentageHappy: 0,
            percentageVeryHappy: 0
        )
        let questionFeedbackSummary = QuestionFeedbackSummary(
            emojiQuestionFeedbackSummary: emojiFeedbackSummary
        )
        
        let question = ManagerQuestion(
            id: UUID(),
            questionText: "Q",
            feedbackType: .emoji,
            feedback: [],
            feedbackSummary: questionFeedbackSummary
        )
        let overallFeedbackSummary: OverallFeedbackSummary = .init(
            segmentationStats: FeedbackSegmentationStats(
                verySadPercentage: 0,
                sadPercentage: 0,
                happyPercentage: 0,
                veryHappyPercentage: 0
            ),
            countStats: FeedbackCountStats(
                verySadCount: 0,
                sadCount: 0,
                happyCount: 0,
                veryHappyCount: 0,
                commentsCount: 0
            ),
            unseenResponses: 0,
            responses: 0
        )
        let event = ManagerEvent(
            id: eventId,
            title: "Event",
            agenda: nil,
            date: .now,
            pinCode: PinCode(value: "111111"),
            durationInMinutes: 60,
            location: nil,
            ownerInfo: .init(name: nil, email: nil, phoneNumber: nil),
            overallFeedbackSummary: overallFeedbackSummary,
            questions: [question],
            isDraft: false,
            invitedEmails: [],
            participants: [],
            calendarProvider: nil
        )
        let activityItem = ActivityItems(
            id: UUID(),
            date: .now,
            eventTitle: "Event",
            eventId: eventId,
            newFeedbackCount: 1,
            seenByManager: false
        )
        let activity = Activity(items: [activityItem], unseenTotal: 1)
        let managerData = ManagerData(
            managerEvents: [event],
            activity: activity,
            recentlyUsedQuestions: [],
            feedbackSessionHash: UUID()
        )
        let session = Session(participantEvents: [], managerData: managerData, accountInfo: .init(name: nil, email: nil, phoneNumber: nil), role: .manager)
        let cache = SessionCache(session: session)
        
        await cache.markEventAsSeen(eventId: eventId)
        let updated = await cache.getSession()
        
        #expect(updated?.managerData?.managerEvents[id: eventId]?.overallFeedbackSummary?.unseenResponses == 0)
        #expect(updated?.managerData?.activity.unseenTotal == 0)
        #expect(updated?.managerData?.activity.items.allSatisfy { $0.seenByManager } == true)
    }
    
    @Test
    func `Activity is updated in cache`() async {
        let eventId = UUID()
        let activityItem = ActivityItems(
            id: UUID(),
            date: .now,
            eventTitle: "Event",
            eventId: eventId,
            newFeedbackCount: 1,
            seenByManager: false
        )
        let activity = Activity(items: [activityItem], unseenTotal: 1)
        let managerData = ManagerData(
            managerEvents: [],
            activity: .init(items: [], unseenTotal: 0),
            recentlyUsedQuestions: [],
            feedbackSessionHash: UUID()
        )
        let session = Session(participantEvents: [], managerData: managerData, accountInfo: .init(name: nil, email: nil, phoneNumber: nil), role: .manager)
        let cache = SessionCache(session: session)
        
        await cache.updateActivity(activity)
        let updated = await cache.getSession()
        
        #expect(updated?.managerData?.activity == activity)
    }
    
    @Test
    func `Manager activity is marked as seen`() async {
        let eventId = UUID()
        let activityItem = ActivityItems(
            id: UUID(),
            date: .now,
            eventTitle: "Event",
            eventId: eventId,
            newFeedbackCount: 1,
            seenByManager: false
        )
        let unseenActivity = Activity(items: [activityItem], unseenTotal: 1)
        let session = Session(
            participantEvents: [],
            managerData: .init(
                managerEvents: [],
                activity: unseenActivity,
                recentlyUsedQuestions: [],
                feedbackSessionHash: UUID()
            ),
            accountInfo: .init(name: nil, email: nil, phoneNumber: nil),
            role: .manager
        )
        let cache = SessionCache(session: session)
        
        await cache.markActivityAsSeen()
        let updated = await cache.getSession()
        
        #expect(updated?.managerData?.activity.unseenTotal == 0)
        #expect(updated?.managerData?.activity.items.allSatisfy { $0.seenByManager } == true)
    }
    
    @Test
    func `Session cache is reset correctly`() async {
        let session = Session.mock()
        let cache = SessionCache(session: session)
        
        await cache.reset()
        let result = await cache.getSession()
        
        #expect(result == nil)
    }
}
