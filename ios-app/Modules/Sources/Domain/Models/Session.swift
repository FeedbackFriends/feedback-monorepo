import Foundation
import ComposableArchitecture
import Utility

public struct ManagerSession: Equatable, Sendable {
    public var participantEvents: IdentifiedArrayOf<ParticipantEvent>
    public var managerData: ManagerData
    public var accountInfo: AccountInfo
    public init(
        participantEvents: IdentifiedArrayOf<ParticipantEvent>,
        managerData: ManagerData,
        accountInfo: AccountInfo
    ) {
        self.participantEvents = participantEvents
        self.managerData = managerData
        self.accountInfo = accountInfo
    }
}

public struct ParticipantSession: Equatable, Sendable {
    public var participantEvents: IdentifiedArrayOf<ParticipantEvent>
    public var accountInfo: AccountInfo
    public init(
        participantEvents: IdentifiedArrayOf<ParticipantEvent>,
        accountInfo: AccountInfo
    ) {
        self.participantEvents = participantEvents
        self.accountInfo = accountInfo
    }
}


public struct Session: Equatable, Sendable {
    
    public var participantEvents: IdentifiedArrayOf<ParticipantEvent>
    public var managerData: ManagerData?
    public var accountInfo: AccountInfo
    public var role: Role
    
    public init(
        participantEvents: IdentifiedArrayOf<ParticipantEvent>,
        managerData: ManagerData? = nil,
        accountInfo: AccountInfo,
        role: Role
    ) {
        self.participantEvents = participantEvents
        self.managerData = managerData
        self.accountInfo = accountInfo
        self.role = role
    }
    
    public enum Account: Equatable, Sendable {
        case manager(ManagerSession)
        case participant(ParticipantSession)
    }
    
    public var account: Account {
        switch role {
        case .participant:
            return .participant(
                .init(
                    participantEvents: self.participantEvents,
                    accountInfo: accountInfo
                )
            )
        case .manager:
            return .manager(
                .init(
                    participantEvents: self.participantEvents,
                    managerData: managerData!,
                    accountInfo: accountInfo
                )
            )
        }
    }
    
    public var activity: Activity {
        switch self.account {
        case .manager(let managerSession):
            return managerSession.managerData.activity
        case .participant:
            return .init(items: [], unseenTotal: 0)
        }
    }
    public var unwrappedManagerSession: ManagerSession {
        if case .manager(let session) = self.account {
            return session
        }
        fatalError("Could not unwrap manager session")
    }
    
    public var activityBadgeCount: Int {
        if case .manager(let managerSession) = self.account {
            return managerSession.managerData.activity.unseenTotal
        }
        return 0
    }
}

public enum UserType: Equatable, Sendable {
    case manager(managerData: ManagerData, accountInfo: AccountInfo)
    case participant(accountInfo: AccountInfo)
    public var role: Role? {
        switch self {
        case .manager:
            return Role.manager
        case .participant:
            return Role.participant
        }
    }
}

public struct AccountInfo: Equatable, Sendable {
    public let name: String?
    public let email: String?
    public let phoneNumber: String?
    public init(name: String?, email: String?, phoneNumber: String?) {
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
    }
}

public struct ParticipantEvent: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let agenda: String?
    public let date: Date
    public let pinCode: PinCode?
    public let location: String?
    public let durationInMinutes: Int
    public let questions: [ParticipantQuestion]
    public let feedbackSubmitted: Bool
    public let ownerInfo: OwnerInfo
    public let recentlyJoined: Bool
    
    public init(
        id: UUID,
        title: String,
        agenda: String?,
        date: Date,
        pinCode: PinCode?,
        location: String?,
        durationInMinutes: Int,
        questions: [ParticipantQuestion],
        feedbackSubmitted: Bool,
        ownerInfo: OwnerInfo,
        recentlyJoined: Bool
    ) {
        self.id = id
        self.title = title
        self.agenda = agenda
        self.date = date
        self.pinCode = pinCode
        self.location = location
        self.durationInMinutes = durationInMinutes
        self.questions = questions
        self.feedbackSubmitted = feedbackSubmitted
        self.ownerInfo = ownerInfo
        self.recentlyJoined = recentlyJoined
    }
}

public struct OwnerInfo: Equatable, Sendable {
    public let name: String?
    public let email: String?
    public let phoneNumber: String?
    public init(name: String?, email: String?, phoneNumber: String?) {
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
    }
}

public struct ParticipantQuestion: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let questionText: String
    public let feedbackType: FeedbackType
    public init(id: UUID, questionText: String, feedbackType: FeedbackType) {
        self.id = id
        self.questionText = questionText
        self.feedbackType = feedbackType
    }
}

public struct OverallFeedbackSummary: Equatable, Sendable {
    public let segmentationStats: FeedbackSegmentationStats
    public let countStats: FeedbackCountStats
    public var unseenResponses: Int
    public var responses: Int
    public init(segmentationStats: FeedbackSegmentationStats, countStats: FeedbackCountStats, unseenResponses: Int, responses: Int) {
        self.segmentationStats = segmentationStats
        self.countStats = countStats
        self.unseenResponses = unseenResponses
        self.responses = responses
    }
}

public struct FeedbackSegmentationStats: Equatable, Sendable {
    public let verySadPercentage: Double
    public let sadPercentage: Double
    public let happyPercentage: Double
    public let veryHappyPercentage: Double
    
    public init(
        verySadPercentage: Double,
        sadPercentage: Double,
        happyPercentage: Double,
        veryHappyPercentage: Double
    ) {
        self.verySadPercentage = verySadPercentage
        self.sadPercentage = sadPercentage
        self.happyPercentage = happyPercentage
        self.veryHappyPercentage = veryHappyPercentage
    }
}

public struct FeedbackCountStats: Equatable, Sendable {
    public let verySadCount: Int
    public let sadCount: Int
    public let happyCount: Int
    public let veryHappyCount: Int
    public let commentsCount: Int
    public init(verySadCount: Int, sadCount: Int, happyCount: Int, veryHappyCount: Int, commentsCount: Int) {
        self.verySadCount = verySadCount
        self.sadCount = sadCount
        self.happyCount = happyCount
        self.veryHappyCount = veryHappyCount
        self.commentsCount = commentsCount
    }
}

public struct ParticipantSummary: Equatable, Hashable, Sendable {
    public let name: String?
    public let email: String?
    public let phoneNumber: String?
    public init(name: String?, email: String?, phoneNumber: String?) {
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
    }
}

public struct ManagerQuestion: Equatable, Hashable, Sendable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public let id: UUID
    public let questionText: String
    public let feedbackType: FeedbackType
    public var feedback: [Feedback]
    public var feedbackSummary: QuestionFeedbackSummary?
    
    public init(
        id: UUID,
        questionText: String,
        feedbackType: FeedbackType,
        feedback: [Feedback],
        feedbackSummary: QuestionFeedbackSummary?
    ) {
        self.id = id
        self.questionText = questionText
        self.feedbackType = feedbackType
        self.feedback = feedback
        self.feedbackSummary = feedbackSummary
    }
}

public struct EventWrapper: Equatable, Sendable {
    public let event: ManagerEvent
    public let recentlyUsedQuestions: Set<RecentlyUsedQuestions>
    public init(
        event: ManagerEvent,
        recentlyUsedQuestions: Set<RecentlyUsedQuestions>
    ) {
        self.event = event
        self.recentlyUsedQuestions = recentlyUsedQuestions
    }
}

public struct ManagerEvent: Equatable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var agenda: String?
    public var date: Date
    public let pinCode: PinCode?
    public var durationInMinutes: Int
    public var location: String?
    public let ownerInfo: OwnerInfo
    public var overallFeedbackSummary: OverallFeedbackSummary?
    public var questions: [ManagerQuestion]
    public var invitedEmails: [String]
    public var participants: [ParticipantSummary]
    public let isDraft: Bool
    public let calendarProvider: CalendarProvider?
    public func inviteUrl(webBaseUrl: URL) -> String {
        guard let pinCode = self.pinCode?.value else { return "PINCODE_NOT_FOUND" }
        return AppWebURLProvider.invite(forPinCode: pinCode, baseUrl: webBaseUrl)?.absoluteString ?? "COULD_NOT_GENERATE_INVITE_LINK"
    }
    public var shareText: String {
    """
    You’re invited to \(self.title)!   
    Use pin code \(self.pinCode?.value ?? "PINCODE_NOT_FOUND") to join.
    
    👇🏼 Tap the link to join:  
    \(String(describing: inviteUrl))
    """
    }
    public var end: Date {
        date + TimeInterval(durationInMinutes * 60)
    }
    public var formattedDate: String {
        if Calendar.current.dateComponents([.minute], from: date, to: end).minute == 1440 {
            return "\(date.dateAndYear()) - All day"
        } else if Calendar.current.isDate(date, inSameDayAs: end) {
            return "\(date.dateAndYear()) at \(date.timeFormatted())-\(end.timeFormatted())"
        } else {
            return "\(date.dateAndYear()) \(end.timeFormatted()) to \(end.formatted(.dateTime.day())) \(end.formatted(.dateTime.month())) \(end.timeFormatted())"
        }
    }
    
    public init(
        id: UUID,
        title: String,
        agenda: String? = nil,
        date: Date,
        pinCode: PinCode?,
        durationInMinutes: Int,
        location: String? = nil,
        ownerInfo: OwnerInfo,
        overallFeedbackSummary: OverallFeedbackSummary?,
        questions: [ManagerQuestion],
        isDraft: Bool,
        invitedEmails: [String],
        participants: [ParticipantSummary],
        calendarProvider: CalendarProvider?
    ) {
        self.id = id
        self.title = title
        self.agenda = agenda
        self.date = date
        self.pinCode = pinCode
        self.durationInMinutes = durationInMinutes
        self.location = location
        self.ownerInfo = ownerInfo
        self.overallFeedbackSummary = overallFeedbackSummary
        self.questions = questions
        self.isDraft = isDraft
        self.invitedEmails = invitedEmails
        self.participants = participants
        self.calendarProvider = calendarProvider
    }
}

public struct ManagerData: Equatable, Sendable {
    public var managerEvents: IdentifiedArrayOf<ManagerEvent>
    public var activity: Activity
    public var recentlyUsedQuestions: Set<RecentlyUsedQuestions>
    public var feedbackSessionHash: UUID
    public var draftEvents: [ManagerEvent]
    public init(
        managerEvents: IdentifiedArrayOf<ManagerEvent>,
        activity: Activity,
        recentlyUsedQuestions: Set<RecentlyUsedQuestions>,
        feedbackSessionHash: UUID
    ) {
        self.managerEvents = managerEvents.filter { !$0.isDraft }
        self.activity = activity
        self.recentlyUsedQuestions = recentlyUsedQuestions
        self.feedbackSessionHash = feedbackSessionHash
        self.draftEvents = managerEvents.filter(\.isDraft)
    }
}

public struct RecentlyUsedQuestions: Equatable, Sendable, Hashable {
    public let questionText: String
    public let feedbackType: FeedbackType
    public let updatedAt: Date
    
    public init(
        questionText: String,
        feedbackType: FeedbackType,
        updatedAt: Date
    ) {
        self.questionText = questionText
        self.feedbackType = feedbackType
        self.updatedAt = updatedAt
    }
}

public struct QuestionFeedbackSummary: Equatable, Sendable {
    public let emojiQuestionFeedbackSummary: EmojiQuestionFeedbackSummary?
    public let thumpsQuestionFeedbackSummary: ThumpsQuestionFeedbackSummary?
    public let opinionQuestionFeedbackSummary: OpinionQuestionFeedbackSummary?
    public let zeroToTenQuestionFeedbackSummary: ZeroToTenQuestionFeedbackSummary?
    
    public init(
        emojiQuestionFeedbackSummary: EmojiQuestionFeedbackSummary? = nil,
        thumpsQuestionFeedbackSummary: ThumpsQuestionFeedbackSummary? = nil,
        opinionQuestionFeedbackSummary: OpinionQuestionFeedbackSummary? = nil,
        zeroToTenQuestionFeedbackSummary: ZeroToTenQuestionFeedbackSummary? = nil
    ) {
        self.emojiQuestionFeedbackSummary = emojiQuestionFeedbackSummary
        self.thumpsQuestionFeedbackSummary = thumpsQuestionFeedbackSummary
        self.opinionQuestionFeedbackSummary = opinionQuestionFeedbackSummary
        self.zeroToTenQuestionFeedbackSummary = zeroToTenQuestionFeedbackSummary
    }
}

public struct ZeroToTenQuestionFeedbackSummary: Equatable, Sendable {
    public let percentageValue0: Double
    public let percentageValue1: Double
    public let percentageValue2: Double
    public let percentageValue3: Double
    public let percentageValue4: Double
    public let percentageValue5: Double
    public let percentageValue6: Double
    public let percentageValue7: Double
    public let percentageValue8: Double
    public let percentageValue9: Double
    public let percentageValue10: Double
    public let countValue0: Int
    public let countValue1: Int
    public let countValue2: Int
    public let countValue3: Int
    public let countValue4: Int
    public let countValue5: Int
    public let countValue6: Int
    public let countValue7: Int
    public let countValue8: Int
    public let countValue9: Int
    public let countValue10: Int
    
    public init(
        percentageValue0: Double,
        percentageValue1: Double,
        percentageValue2: Double,
        percentageValue3: Double,
        percentageValue4: Double,
        percentageValue5: Double,
        percentageValue6: Double,
        percentageValue7: Double,
        percentageValue8: Double,
        percentageValue9: Double,
        percentageValue10: Double,
        countValue0: Int,
        countValue1: Int,
        countValue2: Int,
        countValue3: Int,
        countValue4: Int,
        countValue5: Int,
        countValue6: Int,
        countValue7: Int,
        countValue8: Int,
        countValue9: Int,
        countValue10: Int
    ) {
        self.percentageValue0 = percentageValue0
        self.percentageValue1 = percentageValue1
        self.percentageValue2 = percentageValue2
        self.percentageValue3 = percentageValue3
        self.percentageValue4 = percentageValue4
        self.percentageValue5 = percentageValue5
        self.percentageValue6 = percentageValue6
        self.percentageValue7 = percentageValue7
        self.percentageValue8 = percentageValue8
        self.percentageValue9 = percentageValue9
        self.percentageValue10 = percentageValue10
        self.countValue0 = countValue0
        self.countValue1 = countValue1
        self.countValue2 = countValue2
        self.countValue3 = countValue3
        self.countValue4 = countValue4
        self.countValue5 = countValue5
        self.countValue6 = countValue6
        self.countValue7 = countValue7
        self.countValue8 = countValue8
        self.countValue9 = countValue9
        self.countValue10 = countValue10
    }
}

public struct OpinionQuestionFeedbackSummary: Equatable, Sendable {
    public let countStronglyAgree: Int
    public let countAgree: Int
    public let countStronglyDisagree: Int
    public let countDisagree: Int
    public let percentageStronglyAgree: Double
    public let percentageAgree: Double
    public let percentageStronglyDisagree: Double
    public let percentageDisagree: Double
    
    public init(
        countStronglyAgree: Int,
        countAgree: Int,
        countStronglyDisagree: Int,
        countDisagree: Int,
        percentageStronglyAgree: Double,
        percentageAgree: Double,
        percentageStronglyDisagree: Double,
        percentageDisagree: Double
    ) {
        self.countStronglyAgree = countStronglyAgree
        self.countAgree = countAgree
        self.countStronglyDisagree = countStronglyDisagree
        self.countDisagree = countDisagree
        self.percentageStronglyAgree = percentageStronglyAgree
        self.percentageAgree = percentageAgree
        self.percentageStronglyDisagree = percentageStronglyDisagree
        self.percentageDisagree = percentageDisagree
    }
}

public struct ThumpsQuestionFeedbackSummary: Equatable, Sendable {
    public let countUp: Int
    public let countDown: Int
    public let percentageUp: Double
    public let percentageDown: Double
    
    public init(
        countUp: Int,
        countDown: Int,
        percentageUp: Double,
        percentageDown: Double
    ) {
        self.countUp = countUp
        self.countDown = countDown
        self.percentageUp = percentageUp
        self.percentageDown = percentageDown
    }
}

public struct EmojiQuestionFeedbackSummary: Equatable, Sendable {
    public let countVerySad: Int
    public let countSad: Int
    public let countHappy: Int
    public let countVeryHappy: Int
    public let percentageVerySad: Double
    public let percentageSad: Double
    public let percentageHappy: Double
    public let percentageVeryHappy: Double
    
    public init(
        countVerySad: Int,
        countSad: Int,
        countHappy: Int,
        countVeryHappy: Int,
        percentageVerySad: Double,
        percentageSad: Double,
        percentageHappy: Double,
        percentageVeryHappy: Double
    ) {
        self.countVerySad = countVerySad
        self.countSad = countSad
        self.countHappy = countHappy
        self.countVeryHappy = countVeryHappy
        self.percentageVerySad = percentageVerySad
        self.percentageSad = percentageSad
        self.percentageHappy = percentageHappy
        self.percentageVeryHappy = percentageVeryHappy
    }
}
