#if !RELEASE
import Foundation

nonisolated(unsafe) private var globalMockUUIDIndex = 0

private func nextDeterministicUUID() -> UUID {
    let uuid = UUID.mockUUID(forIndex: globalMockUUIDIndex)
    globalMockUUIDIndex += 1
    return uuid
}

public let mockAgenda =
    """
    1. Opening Remarks (5 minutes)
    2. Team Member Updates (15 minutes)
        - Progress since last meeting
        - Roadblocks and challenges
    3. Review of Action Items (10 minutes)
        - Updates on assigned tasks
    """

public func generateAgenda() -> String? {
    // 30% chance the agenda is nil
    if Bool.random() && Bool.random() {
        return nil
    }
    
    // Generate a random agenda
    let agendaItems = [
        ("Opening Remarks", 5),
        ("Team Member Updates", 15),
        ("Review of Action Items", 10),
        ("Project Updates", 20),
        ("Brainstorming Session", 25),
        ("Problem-Solving Workshop", 15),
        ("Closing Remarks", 5)
    ]
    
    let numberOfItems = Int.random(in: 2...5) // Random number of agenda items
    let selectedItems = agendaItems.shuffled().prefix(numberOfItems)
    
    var agenda = ""
    for (index, item) in selectedItems.enumerated() {
        agenda += "\(index + 1). \(item.0) (\(item.1) minutes)\n"
    }
    
    return agenda.trimmingCharacters(in: .whitespacesAndNewlines)
}

public func generateRandomDurationInMinutes() -> Int {
    Int.random(in: 0...2400)
}

public func generateRandomQuestions() -> [ParticipantQuestion] {
    [
        .init(
            id: UUID(),
            questionText: "Was the agenda clear and easy to follow?",
            feedbackType: .thumpsUpThumpsDown
        ),
        .init(
            id: UUID(),
            questionText: "On a scale of 1-10, how satisfied are you with the meeting outcome?",
            feedbackType: .zeroToTen
        ),
        .init(
            id: UUID(),
            questionText: "This month I had work related stress symptoms.",
            feedbackType: .opinion
        ),
        .init(
            id: UUID(),
            questionText: "What went well, and what should we change next time?",
            feedbackType: .comment
        ),
        .init(
            id: UUID(),
            questionText: "How do you feel about the meeting overall?",
            feedbackType: .emoji
        ),
        .init(
            id: UUID(),
            questionText: "How do you feel about the meeting overall?",
            feedbackType: .emoji
        )
    ]
}

public extension FeedbackSession {
    static let mock = Self(
        title: generateFeedbackEventTitle(),
        agenda: generateAgenda(),
        questions: generateRandomQuestions(),
        ownerInfo: .init(
            name: "Nicolai",
            email: "nicolaidam@gmail.com",
            phoneNumber: "27639523"
        ),
        pinCode: .init(value: "1234"),
        date: Date()
    )
}

public extension ParticipantSession {
    static let mock = Self(
        participantEvents: .init(uniqueElements: (0...100).map { _ in .mock() }),
        accountInfo: .init(name: "Nicolai", email: "Nicolai@letsgrow.dk", phoneNumber: "88888888")
    )
}
//
//public extension AnonymousSession {
//    static let mock = Self(
//        participantEvents: .init(uniqueElements: (0...100).map { _ in .mock() })
//    )
//}

public extension ManagerSession {
    static let mock = Self(
        participantEvents: .init(uniqueElements: (0...100).map { _ in .mock() }),
        managerData: .init(
            managerEvents: .init(
                uniqueElements: [
                    ManagerEvent.mock()
                ]
            ),
            activity: .mock,
            recentlyUsedQuestions: [.init(questionText: "Hello world", feedbackType: .emoji, updatedAt: Date())],
            feedbackSessionHash: UUID()
        ),
        accountInfo: .init(name: "Nicolai", email: "Nicolai@letsgrow.dk", phoneNumber: "88888888")
    )
    static let empty = Self(
        participantEvents: .init(uniqueElements: []),
        managerData: .init(
            managerEvents: .init(
                uniqueElements: []
            ),
            activity: .mock,
            recentlyUsedQuestions: [],
            feedbackSessionHash: UUID()
        ),
        accountInfo: .init(name: "Nicolai", email: "Nicolai@letsgrow.dk", phoneNumber: "88888888")
    )
}

public extension Session {
    static func mock(numberOfManagerEvents: Int = 99) -> Self {
        Self(
            participantEvents: .init(uniqueElements: (0...100).map { _ in .mock() }),
            managerData: .init(
                managerEvents: .init(
                    uniqueElements: [
                        ManagerEvent.mock()
                    ]
                ),
                activity: .mock,
                recentlyUsedQuestions: [],
                feedbackSessionHash: UUID()
            ),
            accountInfo: .init(name: "Nicolai", email: "Nicolai@letsgrow.dk", phoneNumber: "88888888"),
            role: .manager
        )
    }
    static func empty() -> Self {
        Self(
            participantEvents: .init(uniqueElements: []),
            managerData: .init(
                managerEvents: .init(
                    uniqueElements: []
                ),
                activity: .mock,
                recentlyUsedQuestions: [],
                feedbackSessionHash: UUID()
            ),
            accountInfo: .init(name: "Nicolai", email: "Nicolai@letsgrow.dk", phoneNumber: "88888888"),
            role: .manager
        )
    }
    static func mockAnonymous() -> Self {
        Self(
            participantEvents: .init(uniqueElements: []),
            accountInfo: .init(name: nil, email: nil, phoneNumber: nil), role: nil
        )
    }
    static func mockParticipant() -> Self {
        Self(
            participantEvents: .init(uniqueElements: []),
            accountInfo: .init(name: nil, email: nil, phoneNumber: nil),
            role: .participant
        )
    }
    
}

public extension ParticipantEvent {
    static func mock() -> Self {
        ParticipantEvent(
            id: nextDeterministicUUID(),
            title: generateFeedbackEventTitle(),
            agenda: generateAgenda(),
            date: .init(timeIntervalSince1970: 0),
            pinCode: generateRandomPin(),
            location: generateRandomLocation(),
            durationInMinutes: generateRandomDurationInMinutes(),
            questions: [
                ParticipantQuestion.init(
                    id: UUID(),
                    questionText: "How do you feel about the meeting duration?",
                    feedbackType: .emoji
                )
            ],
            feedbackSubmitted: Bool.random(),
            ownerInfo: .mock(),
            recentlyJoined: Bool.random()
        )
    }
}

public extension OwnerInfo {
    static func mock() -> Self {
        OwnerInfo(
            name: "Nicolai",
            email: "Nicolai@letsgrow.dk",
            phoneNumber: "88888888"
        )
    }
}

extension UUID {
    static func mockUUID(forIndex index: Int) -> UUID {
        let hex = String(format: "%012x", index)
        let uuidString = "00000000-0000-0000-0000-\(hex)"
        return UUID(uuidString: uuidString)!
    }
}

public extension ManagerEvent {
    static func mock() -> Self {
        
        let questions: [ManagerQuestion] = [
            generateQuestionWithType(feedbackType: FeedbackType.comment),
            generateQuestionWithType(feedbackType: FeedbackType.emoji),
            generateQuestionWithType(feedbackType: FeedbackType.zeroToTen),
            generateQuestionWithType(feedbackType: FeedbackType.opinion),
            generateQuestionWithType(feedbackType: FeedbackType.thumpsUpThumpsDown)
        ]
        let feedbackSummary: OverallFeedbackSummary = generateFeedbackSummary(total: 10)
        return Self.init(
            id: nextDeterministicUUID(),
            title: generateFeedbackEventTitle(),
            agenda: generateAgenda(),
            date: generateRandomDate(),
            pinCode: generateRandomPin(),
            durationInMinutes: Int.random(in: 0...2400),
            location: generateRandomLocation(),
            ownerInfo: .mock(),
            overallFeedbackSummary: feedbackSummary,
            questions: questions,
            isDraft: Bool.random(),
            invitedEmails: [],
            participants: [],
            calendarProvider: .APPLE
        )
    }
    
}

func generateRandomDate() -> Date {
    let today = Date()
    let daysOffset = Int.random(in: -365...365) // Range: -365 days to +365 days (1 year before to 1 year after)
    let randomDate = Calendar.current.date(byAdding: .day, value: daysOffset, to: today)
    return randomDate ?? today
}

func generateRandomLocation() -> String {
    let possibleLocations = [
        "Roskilde",
        "Copenhagen",
        "Aarhus",
        "Odense",
        "Stockholm",
        "Oslo",
        "Helsinki",
        "Berlin",
        "Amsterdam",
        "Paris",
        "London",
        "New York",
        "San Francisco",
        "Tokyo",
        "Sydney",
        "Barcelona",
        "Munich",
        "Dublin",
        "Toronto",
        "Singapore"
    ]
    
    return possibleLocations.randomElement() ?? "Unknown Location"
}

func generateRandomPin() -> PinCode {
    let pin = Int.random(in: 1000...9999)
    return PinCode(value: String(pin))
}

func generateFeedbackEventTitle() -> String {
    let possibleTitles = [
        "Standup Meeting",
        "Team Retrospective",
        "Project Kickoff",
        "Weekly Sync-Up",
        "Brainstorming Session",
        "Quarterly Planning",
        "All-Hands Meeting",
        "Leadership Roundtable",
        "Product Demo Day",
        "Design Review",
        "Code Review Session",
        "Customer Feedback Workshop",
        "Stakeholder Alignment Meeting",
        "Sprint Planning",
        "Daily Standup",
        "Town Hall Meeting",
        "End-of-Year Review",
        "Problem-Solving Workshop",
        "Company Update",
        "Strategy Session"
    ]
    
    return possibleTitles.randomElement() ?? "Meeting"
}

private func generateFeedbackSummary(total: Int) -> OverallFeedbackSummary {
    // Generate random weights ensuring percentages sum to 100
    let verySadWeight = Int.random(in: 0...50)
    let sadWeight = Int.random(in: 0...(100 - verySadWeight))
    let happyWeight = Int.random(in: 0...(100 - verySadWeight - sadWeight))
    let veryHappyWeight = 100 - (verySadWeight + sadWeight + happyWeight)
    
    // Convert weights to percentages
    let verySadPercentage = Double(verySadWeight)
    let sadPercentage = Double(sadWeight)
    let happyPercentage = Double(happyWeight)
    let veryHappyPercentage = Double(veryHappyWeight)
    
    let verySadCount = Int.random(in: 0...total / 2)
    let sadCount = Int.random(in: 0...(total - verySadCount) / 3)
    let happyCount = Int.random(in: 0...(total - verySadCount - sadCount) / 2)
    let veryHappyCount = total - (verySadCount + sadCount + happyCount)
    
    return OverallFeedbackSummary(
        segmentationStats: FeedbackSegmentationStats(
            verySadPercentage: verySadPercentage,
            sadPercentage: sadPercentage,
            happyPercentage: happyPercentage,
            veryHappyPercentage: veryHappyPercentage
        ),
        countStats: FeedbackCountStats(
            verySadCount: verySadCount,
            sadCount: sadCount,
            happyCount: happyCount,
            veryHappyCount: veryHappyCount,
            commentsCount: Int.random(in: 0...10)
        ),
        unseenResponses: Int.random(in: 0...10),
        responses: Int.random(in: 0...10)
    )
}

public extension ManagerEvent {
    static let mockEmpty = Self.init(
        id: nextDeterministicUUID(),
        title: "Standup Meeting",
        agenda: mockAgenda,
        date: .init(timeIntervalSince1970: 0),
        pinCode: PinCode(value: "1234"),
        durationInMinutes: 30,
        location: "Roskilde",
        ownerInfo: .mock(),
        overallFeedbackSummary: nil,
        questions: [
            .init(
                id: nextDeterministicUUID(),
                questionText: "What do you think about this aspect of the experience?",
                feedbackType: .emoji,
                feedback: [],
                feedbackSummary: nil
            ),
            .init(
                id: nextDeterministicUUID(),
                questionText: "What do you think about this aspect of the experience?",
                feedbackType: .emoji,
                feedback: [],
                feedbackSummary: nil
            )
        ],
        isDraft: Bool.random(),
        invitedEmails: [],
        participants: [],
        calendarProvider: .GOOGLE
    )
}

public func generateQuestionWithType(feedbackType: FeedbackType) -> ManagerQuestion {
    switch feedbackType {
    case .emoji:
        let feedback: [Feedback] = [
            .mock(
                type: FeedbackTypeWithData.emoji(emoji: Emoji.happy, comment: "Great session")
            ),
            .mock(
                type: FeedbackTypeWithData.emoji(emoji: Emoji.sad, comment: "Could be better")
            ),
            .mock(
                type: FeedbackTypeWithData.emoji(emoji: Emoji.sad, comment: "Not my favorite meeting")
            ),
            .mock(
                type: FeedbackTypeWithData.emoji(emoji: Emoji.verySad, comment: "Disappointed in the outcome")
            ),
            .mock(
                type: FeedbackTypeWithData.emoji(emoji: Emoji.veryHappy, comment: "Loved it")
            ),
            .mock(
                type: FeedbackTypeWithData.emoji(emoji: Emoji.verySad, comment: "The meeting ran too long")
            ),
            .mock(
                type: FeedbackTypeWithData.emoji(emoji: Emoji.happy, comment: "Felt productive and well-organized")
            ),
            .mock(
                type: FeedbackTypeWithData.emoji(emoji: Emoji.sad, comment: nil)
            )
        ]
        return ManagerQuestion(
            id: nextDeterministicUUID(),
            questionText: "How do you feel about the meeting?",
            feedbackType: .emoji,
            feedback: feedback,
            feedbackSummary: QuestionFeedbackSummary(
                emojiQuestionFeedbackSummary: EmojiQuestionFeedbackSummary(
                    countVerySad: 10,
                    countSad: 60,
                    countHappy: 30,
                    countVeryHappy: 0,
                    percentageVerySad: 10,
                    percentageSad: 60,
                    percentageHappy: 30,
                    percentageVeryHappy: 0
                )
            )
        )
    case .comment:
        let feedback: [Feedback] = [
            .mock(
                type: FeedbackTypeWithData.comment(comment: "I was good")
            )
        ]
        return ManagerQuestion(
            id: nextDeterministicUUID(),
            questionText: "How do you feel about this aspect of the experience?",
            feedbackType: .comment,
            feedback: feedback,
            feedbackSummary: nil
        )
    case .thumpsUpThumpsDown:
        let feedback: [Feedback] = [
            .mock(
                type: FeedbackTypeWithData.thumpsUpThumpsDown(thumbsUpThumpsDown: ThumbsUpThumpsDown.down, comment: "Not good")
            ),
            .mock(
                type: FeedbackTypeWithData.thumpsUpThumpsDown(thumbsUpThumpsDown: ThumbsUpThumpsDown.up, comment: "GOOD!")
            )
        ]
        return ManagerQuestion(
            id: nextDeterministicUUID(),
            questionText: "Have you enjoyed this feedback session?",
            feedbackType: .thumpsUpThumpsDown,
            feedback: feedback,
            feedbackSummary: QuestionFeedbackSummary(
                thumpsQuestionFeedbackSummary: ThumpsQuestionFeedbackSummary(
                    countUp: 35,
                    countDown: 15,
                    percentageUp: 70,
                    percentageDown: 30
                )
            )
        )
    case .opinion:
        let feedback: [Feedback] = [
            .mock(type: .opinion(opinion: .stronglyAgree, comment: "Not much to say. I get the feedback i need.")),
            .mock(type: .opinion(opinion: .disagree, comment: nil))
        ]
        return ManagerQuestion(
            id: nextDeterministicUUID(),
            questionText: "I feel i get the feedback i need from my boss.",
            feedbackType: .opinion,
            feedback: feedback,
            feedbackSummary: .init(
                opinionQuestionFeedbackSummary: OpinionQuestionFeedbackSummary(
                    countStronglyAgree: 25,
                    countAgree: 15,
                    countStronglyDisagree: 5,
                    countDisagree: 10,
                    percentageStronglyAgree: 40,
                    percentageAgree: 24,
                    percentageStronglyDisagree: 8,
                    percentageDisagree: 16
                )
            )
        )
    case .zeroToTen:
        let feedback: [Feedback] = [
            .mock(type: .zeroToTen(zeroToTen: 10, comment: "I FEEL good")),
            .mock(type: .zeroToTen(zeroToTen: 2, comment: nil))
        ]
        return ManagerQuestion(
            id: nextDeterministicUUID(),
            questionText: "How are you feeling today?",
            feedbackType: .zeroToTen,
            feedback: feedback,
            feedbackSummary: .init(
                zeroToTenQuestionFeedbackSummary: ZeroToTenQuestionFeedbackSummary(
                    percentageValue0: 2,
                    percentageValue1: 3,
                    percentageValue2: 5,
                    percentageValue3: 7,
                    percentageValue4: 8,
                    percentageValue5: 10,
                    percentageValue6: 12,
                    percentageValue7: 14,
                    percentageValue8: 15,
                    percentageValue9: 10,
                    percentageValue10: 14,
                    countValue0: 1,
                    countValue1: 2,
                    countValue2: 3,
                    countValue3: 4,
                    countValue4: 5,
                    countValue5: 6,
                    countValue6: 7,
                    countValue7: 8,
                    countValue8: 9,
                    countValue9: 6,
                    countValue10: 10
                )
            )
        )
    }
}

public func generateFeedback(amount: Int) -> [Feedback] {
    let possibleEmojis: [Emoji] = [.veryHappy, .happy, .sad, .verySad]
    let possibleComments = [
        "Wow it was amazing",
        "Absolutely fantastic!",
        "Quite good, had a great time.",
        "Could have been better.",
        "Really disappointing.",
        nil
    ]
    
    var feedbackArray: [Feedback] = []
    
    for _ in 0..<amount {
        let randomEmoji = possibleEmojis.randomElement()!
        let randomComment = possibleComments.randomElement()!
        let feedback = Feedback(
            type: .emoji(emoji: randomEmoji, comment: randomComment),
            questionId: nextDeterministicUUID(),
            seenByManager: Bool.random(),
            createdAt: Date()
        )
        feedbackArray.append(feedback)
    }
    
    return feedbackArray
}

extension Feedback {
    static func mock(type: FeedbackTypeWithData) -> Self {
        Feedback(
            type: type,
            questionId: UUID(),
            seenByManager: Bool.random(),
            createdAt: Date()
        )
    }
}

public extension Activity {
    static let mock = Self.init(
        items: [],
        unseenTotal: 5
    )
}
#endif
