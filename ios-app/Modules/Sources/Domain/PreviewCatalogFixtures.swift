#if DEBUG
import ComposableArchitecture
import Foundation

public enum PreviewCatalogFixtures {
    // 27 October 2026, 10:00 Copenhagen. No production account or random preview models.
    public static let now = Date(timeIntervalSince1970: 1_793_091_600)
    public static let owner = OwnerInfo(name: "Anna Jensen", email: "anna@example.com", phoneNumber: "+45 12 34 56 78")
    public static let account = AccountInfo(name: "Anna Jensen", email: "anna@example.com", phoneNumber: "+45 12 34 56 78")

    public static func id(_ value: Int) -> UUID {
        UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", value))!
    }

    public static let questionText = "Hvor nyttigt var mødet for dig?"
    public static let question = ManagerQuestion(
        id: id(10), questionText: questionText, feedbackType: .zeroToTen,
        feedback: [
            Feedback(
                id: id(11), type: .zeroToTen(zeroToTen: 8, comment: "God dialog og tydelige næste skridt."),
                questionId: id(10), seenByManager: false, createdAt: now.addingTimeInterval(-3_600)
            ),
            Feedback(
                id: id(12), type: .zeroToTen(zeroToTen: 6, comment: "Lidt mere tid til spørgsmål ville være godt."),
                questionId: id(10), seenByManager: true, createdAt: now.addingTimeInterval(-7_200)
            )
        ], feedbackSummary: nil, activityQuestionId: id(10)
    )

    public static let summary = OverallFeedbackSummary(
        segmentationStats: .init(verySadPercentage: 0, sadPercentage: 0, happyPercentage: 50, veryHappyPercentage: 50),
        countStats: .init(verySadCount: 0, sadCount: 0, happyCount: 1, veryHappyCount: 1, commentsCount: 2),
        unseenResponses: 1, responses: 2
    )

    public static let previousEvent = Event(
        id: id(20), date: now.addingTimeInterval(-86_400), pinCode: .init(value: "1234"),
        durationInMinutes: 30, location: "Mødelokale 2", averageRating: 3.5,
        overallFeedbackSummary: summary, questionsSnapshot: [question], calendarProvider: .GOOGLE
    )
    public static let upcomingEvent = Event(
        id: id(21), date: now.addingTimeInterval(86_400), pinCode: .init(value: "5678"),
        durationInMinutes: 30, location: "Mødelokale 2",
        overallFeedbackSummary: nil, questionsSnapshot: [], calendarProvider: .GOOGLE
    )

    public static let activity = Activity(
        id: id(1), title: "Ugentligt teammøde", activityEmail: "teammoede@example.com",
        date: now,
        pinCode: nil, durationInMinutes: 30, location: "Mødelokale 2", ownerInfo: owner,
        trend: .init(
            direction: .improving, indicator: .positive, metric: .averageRating,
            latestValue: 3.5, previousValue: 3, delta: 0.5, comparedEventCount: 2
        ),
        overallFeedbackSummary: summary, questions: [question], events: [previousEvent, upcomingEvent],
        isDraft: false, invitedEmails: ["kollega@example.com"], participants: [], calendarProvider: .GOOGLE
    )

    public static var emptyActivity: Activity {
        var value = activity
        value.events = []
        value.overallFeedbackSummary = nil
        return value
    }

    public static let notification = NotificationHistoryItem(
        id: id(30), date: now.addingTimeInterval(-3_600), eventTitle: activity.title,
        eventId: previousEvent.id, newFeedbackCount: 2, seenByManager: false
    )

    public static func bootstrap(empty: Bool = false, role: Role? = .manager) -> Shared<Bootstrap> {
        Shared(value: Bootstrap(
            participantEvents: [],
            managerData: role == .manager ? .init(
                activities: IdentifiedArray(uniqueElements: empty ? [] : [activity]),
                notificationHistory: .init(items: empty ? [] : [notification], unseenTotal: empty ? 0 : 1),
                questionAnalytics: [], bootstrapHash: id(40)
            ) : nil,
            accountInfo: account, role: role
        ))
    }

    public static var error: PresentableError { PresentableError(
        title: "Kunne ikke hente data", message: "Prøv igen om lidt. Dine ændringer er ikke gemt."
    ) }

    public static func bootstrap(activity: Activity) -> Shared<Bootstrap> {
        let value = bootstrap()
        value.withLock { $0.managerData?.activities = [activity] }
        return value
    }

    public static func participantEvent(
        index: Int, submitted: Bool = false, expired: Bool = false, recentlyJoined: Bool = false
    ) -> ParticipantEvent {
        ParticipantEvent(
            id: id(100 + index), date: now.addingTimeInterval(Double(index) * 86_400),
            pinCode: expired ? nil : .init(value: "1234"), location: "Mødelokale 2", durationInMinutes: 30,
            questions: [.init(id: id(10), questionText: questionText, feedbackType: .zeroToTen)],
            feedbackSubmited: submitted, ownerInfo: owner, recentlyJoined: recentlyJoined
        )
    }

    public static func feedbackSession(type: FeedbackType) -> FeedbackEventDto {
        FeedbackEventDto(
            questions: [.init(id: id(10), questionText: questionText, feedbackType: type)],
            ownerInfo: owner, pinCode: .init(value: "1234"), date: now
        )
    }

    public static func resultQuestion(type: FeedbackType, answered: Bool = true) -> ManagerQuestion {
        let data: FeedbackTypeWithData
        let result: QuestionFeedbackSummary?
        switch type {
        case .emoji:
            data = .emoji(emoji: .happy, comment: "God dialog og tydelige næste skridt.")
            result = .init(emojiQuestionFeedbackSummary: .init(
                countVerySad: 0, countSad: 0, countHappy: 1, countVeryHappy: 0,
                percentageVerySad: 0, percentageSad: 0, percentageHappy: 100, percentageVeryHappy: 0
            ))
        case .thumpsUpThumpsDown:
            data = .thumpsUpThumpsDown(thumbsUpThumpsDown: .up, comment: "God dialog og tydelige næste skridt.")
            result = .init(thumpsQuestionFeedbackSummary: .init(countUp: 1, countDown: 0, percentageUp: 100, percentageDown: 0))
        case .opinion:
            data = .opinion(opinion: .agree, comment: "God dialog og tydelige næste skridt.")
            result = .init(opinionQuestionFeedbackSummary: .init(
                countStronglyAgree: 0, countAgree: 1, countStronglyDisagree: 0, countDisagree: 0,
                percentageStronglyAgree: 0, percentageAgree: 100, percentageStronglyDisagree: 0, percentageDisagree: 0
            ))
        case .zeroToTen:
            data = .zeroToTen(zeroToTen: 8, comment: "God dialog og tydelige næste skridt.")
            result = .init(zeroToTenQuestionFeedbackSummary: .init(
                percentageValue0: 0, percentageValue1: 0, percentageValue2: 0, percentageValue3: 0,
                percentageValue4: 0, percentageValue5: 0, percentageValue6: 0, percentageValue7: 0,
                percentageValue8: 100, percentageValue9: 0, percentageValue10: 0,
                countValue0: 0, countValue1: 0, countValue2: 0, countValue3: 0,
                countValue4: 0, countValue5: 0, countValue6: 0, countValue7: 0,
                countValue8: 1, countValue9: 0, countValue10: 0
            ))
        case .comment:
            data = .comment(comment: "Behold dialogen, men giv mere tid til spørgsmål næste gang.")
            result = nil
        }
        return ManagerQuestion(
            id: id(10), questionText: questionText, feedbackType: type,
            feedback: answered ? [.init(
                id: id(11), type: data, questionId: id(10), seenByManager: false, createdAt: now
            )] : [], feedbackSummary: answered ? result : nil, activityQuestionId: id(10)
        )
    }

}
#endif
