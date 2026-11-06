#if !RELEASE
import Foundation

nonisolated(unsafe) private var globalMockUUIDIndex = 0

private func nextDeterministicUUID() -> UUID {
    let uuid = UUID.mockUUID(forIndex: globalMockUUIDIndex)
    globalMockUUIDIndex += 1
    return uuid
}

public func generateRandomDurationInMinutes() -> Int {
    Int.random(in: 0...2400)
}

public func generateRandomQuestions() -> [ParticipantQuestion] {
    [
        .init(
            id: UUID(),
            questionText: "Var dagsordenen tydelig og nem at følge?",
            feedbackType: .thumpsUpThumpsDown
        ),
        .init(
            id: UUID(),
            questionText: "Hvor tilfreds er du med mødets resultat på en skala fra 0 til 10?",
            feedbackType: .zeroToTen
        ),
        .init(
            id: UUID(),
            questionText: "Vi fik afklaret de vigtigste spørgsmål på mødet.",
            feedbackType: .opinion
        ),
        .init(
            id: UUID(),
            questionText: "Hvad gik godt, og hvad skal vi ændre næste gang?",
            feedbackType: .comment
        ),
        .init(
            id: UUID(),
            questionText: "Hvordan var mødet samlet set?",
            feedbackType: .emoji
        ),
        .init(
            id: UUID(),
            questionText: "Hvordan var mødet samlet set?",
            feedbackType: .emoji
        )
    ]
}

public extension FeedbackEventDto {
    static let mock = Self(
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

public extension AnonymousSession {
    static let mock = Self(
        participantEvents: .init(uniqueElements: (0...100).map { _ in .mock() }),
        accountInfo: .init(name: "Nicolai", email: "Nicolai@letsgrow.dk", phoneNumber: "88888888")
    )
}
//
// public extension AnonymousSession {
//     static let mock = Self(
//         participantEvents: .init(uniqueElements: (0...100).map { _ in .mock() })
//     )
// }

public extension ManagerSession {
    static let mock = Self(
        participantEvents: .init(uniqueElements: (0...100).map { _ in .mock() }),
        managerData: .init(
            activities: .init(
                uniqueElements: [
                    Activity.mock()
                ]
            ),
            notificationHistory: .mock,
            questionAnalytics: [.mock()],
            bootstrapHash: UUID()
        ),
        accountInfo: .init(name: "Nicolai", email: "Nicolai@letsgrow.dk", phoneNumber: "88888888")
    )
    static let empty = Self(
        participantEvents: .init(uniqueElements: []),
        managerData: .init(
            activities: .init(
                uniqueElements: []
            ),
            notificationHistory: .mock,
            questionAnalytics: [],
            bootstrapHash: UUID()
        ),
        accountInfo: .init(name: "Nicolai", email: "Nicolai@letsgrow.dk", phoneNumber: "88888888")
    )
}

public extension Bootstrap {
    static func mock(numberOfManagerEvents: Int = 99) -> Self {
        Self(
            participantEvents: .init(uniqueElements: (0...100).map { _ in .mock() }),
            managerData: .init(
                activities: .init(
                    uniqueElements: [
                        Activity.mock()
                    ]
                ),
                notificationHistory: .mock,
                questionAnalytics: [],
                bootstrapHash: UUID()
            ),
            accountInfo: .init(name: "Nicolai", email: "Nicolai@letsgrow.dk", phoneNumber: "88888888"),
            role: .manager
        )
    }
    static func empty() -> Self {
        Self(
            participantEvents: .init(uniqueElements: []),
            managerData: .init(
                activities: .init(
                    uniqueElements: []
                ),
                notificationHistory: .mock,
                questionAnalytics: [],
                bootstrapHash: UUID()
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
}

public extension ParticipantEvent {
    static func mock() -> Self {
        ParticipantEvent(
            id: nextDeterministicUUID(),
            date: .init(timeIntervalSince1970: 0),
            pinCode: generateRandomPin(),
            location: generateRandomLocation(),
            durationInMinutes: generateRandomDurationInMinutes(),
            questions: [
                ParticipantQuestion.init(
                    id: UUID(),
                    questionText: "Hvordan passede mødets varighed?",
                    feedbackType: .emoji
                )
            ],
            feedbackSubmited: Bool.random(),
            ownerInfo: .mock(),
            recentlyJoined: Bool.random()
        )
    }
}

public extension ManagerQuestionAnalytics {
    static func mock() -> Self {
        .init(
            questionId: UUID(),
            questionText: "Hvordan passede mødets varighed?",
            feedbackType: .emoji,
            eventCount: 1,
            responseCount: 1,
            latestAskedAt: Date(),
            overallSummary: nil,
            timeline: []
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

public extension Activity {
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
            activityEmail: "1234@letsgrow.dk",
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

public extension Event {
    static func mock() -> Self {
        Self.init(
            id: UUID(),
            date: Date(),
            pinCode: nil,
            durationInMinutes: 30,
            overallFeedbackSummary: nil,
            questionsSnapshot: [],
            calendarProvider: nil
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
        "København",
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
        "München",
        "Dublin",
        "Toronto",
        "Singapore"
    ]
    
    return possibleLocations.randomElement() ?? "Ukendt sted"
}

func generateRandomPin() -> PinCode {
    let pin = Int.random(in: 1000...9999)
    return PinCode(value: String(pin))
}

func generateFeedbackEventTitle() -> String {
    let possibleTitles = [
        "Dagligt teammøde",
        "Teamets retrospektiv",
        "Projektopstart",
        "Ugentlig opfølgning",
        "Idémøde",
        "Kvartalsplanlægning",
        "Fællesmøde",
        "Ledermøde",
        "Produktdemonstration",
        "Designgennemgang",
        "Kodegennemgang",
        "Workshop om kundefeedback",
        "Afstemning med interessenter",
        "Sprintplanlægning",
        "Daglig status",
        "Fælles orientering",
        "Årsopsamling",
        "Workshop om problemløsning",
        "Nyt fra virksomheden",
        "Strategimøde"
    ]
    
    return possibleTitles.randomElement() ?? "Møde"
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

public extension Activity {
    static let mockEmpty = Self.init(
        id: nextDeterministicUUID(),
        title: "Dagligt teammøde",
        activityEmail: "1234@letsgrow.dk",
        date: .init(timeIntervalSince1970: 0),
        pinCode: PinCode(value: "1234"),
        durationInMinutes: 30,
        location: "Roskilde",
        ownerInfo: .mock(),
        overallFeedbackSummary: nil,
        questions: [
            .init(
                id: nextDeterministicUUID(),
                questionText: "Hvordan var denne del af mødet?",
                feedbackType: .emoji,
                feedback: [],
                feedbackSummary: nil
            ),
            .init(
                id: nextDeterministicUUID(),
                questionText: "Hvordan var denne del af mødet?",
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
                type: FeedbackTypeWithData.emoji(emoji: Emoji.happy, comment: "God session")
            ),
            .mock(
                type: FeedbackTypeWithData.emoji(emoji: Emoji.sad, comment: "Der er plads til forbedring")
            ),
            .mock(
                type: FeedbackTypeWithData.emoji(emoji: Emoji.sad, comment: "Mødet kunne være mere relevant")
            ),
            .mock(
                type: FeedbackTypeWithData.emoji(emoji: Emoji.verySad, comment: "Resultatet levede ikke op til forventningerne")
            ),
            .mock(
                type: FeedbackTypeWithData.emoji(emoji: Emoji.veryHappy, comment: "Det var rigtig godt")
            ),
            .mock(
                type: FeedbackTypeWithData.emoji(emoji: Emoji.verySad, comment: "Mødet varede for længe")
            ),
            .mock(
                type: FeedbackTypeWithData.emoji(emoji: Emoji.happy, comment: "Mødet var produktivt og godt organiseret")
            ),
            .mock(
                type: FeedbackTypeWithData.emoji(emoji: Emoji.sad, comment: nil)
            )
        ]
        return ManagerQuestion(
            id: nextDeterministicUUID(),
            questionText: "Hvordan var mødet?",
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
                type: FeedbackTypeWithData.comment(comment: "Det gik godt")
            )
        ]
        return ManagerQuestion(
            id: nextDeterministicUUID(),
            questionText: "Hvordan var denne del af mødet?",
            feedbackType: .comment,
            feedback: feedback,
            feedbackSummary: nil
        )
    case .thumpsUpThumpsDown:
        let feedback: [Feedback] = [
            .mock(
                type: FeedbackTypeWithData.thumpsUpThumpsDown(thumbsUpThumpsDown: ThumbsUpThumpsDown.down, comment: "Ikke godt")
            ),
            .mock(
                type: FeedbackTypeWithData.thumpsUpThumpsDown(thumbsUpThumpsDown: ThumbsUpThumpsDown.up, comment: "Godt!")
            )
        ]
        return ManagerQuestion(
            id: nextDeterministicUUID(),
            questionText: "Var denne session nyttig for dig?",
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
            .mock(type: .opinion(opinion: .stronglyAgree, comment: "Jeg får den feedback, jeg har brug for.")),
            .mock(type: .opinion(opinion: .disagree, comment: nil))
        ]
        return ManagerQuestion(
            id: nextDeterministicUUID(),
            questionText: "Jeg får den feedback, jeg har brug for på mødet.",
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
            .mock(type: .zeroToTen(zeroToTen: 10, comment: "Det gik godt")),
            .mock(type: .zeroToTen(zeroToTen: 2, comment: nil))
        ]
        return ManagerQuestion(
            id: nextDeterministicUUID(),
            questionText: "Hvordan var mødet i dag?",
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
        "Det var virkelig godt",
        "Rigtig god session!",
        "Et godt møde med god dialog.",
        "Der er plads til forbedring.",
        "Mødet levede ikke op til forventningerne.",
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

public extension NotificationHistory {
    static let mock = Self.init(
        items: [],
        unseenTotal: 5
    )
}
#endif
