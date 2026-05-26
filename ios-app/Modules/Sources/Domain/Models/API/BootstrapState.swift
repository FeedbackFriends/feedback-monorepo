import ComposableArchitecture
import Foundation
import Utility

public struct BootstrapState: Equatable, Sendable {
    public var participantEvents: IdentifiedArrayOf<ParticipantEvent>
    public var managerData: LocalManagerData?
    public var accountInfo: AccountInfo
    public var role: Role?

    public init(
        participantEvents: IdentifiedArrayOf<ParticipantEvent>,
        managerData: LocalManagerData? = nil,
        accountInfo: AccountInfo,
        role: Role?
    ) {
        self.participantEvents = participantEvents
        self.managerData = managerData
        self.accountInfo = accountInfo
        self.role = role
    }

    public init(_ bootstrap: Bootstrap) {
        self.init(
            participantEvents: bootstrap.participantEvents,
            managerData: bootstrap.managerData.map(LocalManagerData.init),
            accountInfo: bootstrap.accountInfo,
            role: bootstrap.role
        )
    }

    public var bootstrap: Bootstrap {
        .init(
            participantEvents: participantEvents,
            managerData: managerData?.managerData,
            accountInfo: accountInfo,
            role: role
        )
    }

    public var notificationHistoryBadgeCount: Int {
        managerData?.notificationHistory.unseenTotal ?? 0
    }

    public var managerUnseenResponses: Int {
        managerData?.events.reduce(0) { total, event in
            total + (event.overallFeedbackSummary?.unseenResponses ?? 0)
        } ?? 0
    }
}

public struct LocalManagerData: Equatable, Sendable {
    public var activities: IdentifiedArrayOf<LocalActivity>
    public var events: IdentifiedArrayOf<LocalEvent>
    public var notificationHistory: NotificationHistory
    public var questionAnalytics: [ManagerQuestionAnalytics]
    public var bootstrapHash: UUID

    public init(
        activities: IdentifiedArrayOf<LocalActivity>,
        events: IdentifiedArrayOf<LocalEvent>,
        notificationHistory: NotificationHistory,
        questionAnalytics: [ManagerQuestionAnalytics],
        bootstrapHash: UUID
    ) {
        self.activities = activities
        self.events = events
        self.notificationHistory = notificationHistory
        self.questionAnalytics = questionAnalytics
        self.bootstrapHash = bootstrapHash
    }

    public init(_ managerData: ManagerData) {
        self.init(
            activities: .init(uniqueElements: managerData.activities.elements.map(LocalActivity.init)),
            events: .init(uniqueElements: managerData.activities.elements.flatMap { activity in
                activity.events.map { LocalEvent($0, activityId: activity.id) }
            }),
            notificationHistory: managerData.notificationHistory,
            questionAnalytics: managerData.questionAnalytics,
            bootstrapHash: managerData.bootstrapHash
        )
    }

    public var managerData: ManagerData {
        .init(
            activities: .init(uniqueElements: activities.elements.map { localActivity in
                localActivity.activity(
                    events: events.elements
                        .filter { $0.activityId == localActivity.id }
                        .map(\.event)
                )
            }),
            notificationHistory: notificationHistory,
            questionAnalytics: questionAnalytics,
            bootstrapHash: bootstrapHash
        )
    }
}

public struct LocalActivity: Equatable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var agenda: String?
    public var date: Date
    public let pinCode: PinCode?
    public var durationInMinutes: Int
    public var location: String?
    public let ownerInfo: OwnerInfo
    public let trend: ActivityTrend
    public var overallFeedbackSummary: OverallFeedbackSummary?
    public var questions: [ManagerQuestion]
    public var invitedEmails: [String]
    public var participants: [ParticipantSummary]
    public let isDraft: Bool
    public let calendarProvider: CalendarProvider?

    public init(
        id: UUID,
        title: String,
        agenda: String?,
        date: Date,
        pinCode: PinCode?,
        durationInMinutes: Int,
        location: String?,
        ownerInfo: OwnerInfo,
        trend: ActivityTrend,
        overallFeedbackSummary: OverallFeedbackSummary?,
        questions: [ManagerQuestion],
        invitedEmails: [String],
        participants: [ParticipantSummary],
        isDraft: Bool,
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
        self.trend = trend
        self.overallFeedbackSummary = overallFeedbackSummary
        self.questions = questions
        self.invitedEmails = invitedEmails
        self.participants = participants
        self.isDraft = isDraft
        self.calendarProvider = calendarProvider
    }

    public init(_ activity: Activity) {
        self.init(
            id: activity.id,
            title: activity.title,
            agenda: activity.agenda,
            date: activity.date,
            pinCode: activity.pinCode,
            durationInMinutes: activity.durationInMinutes,
            location: activity.location,
            ownerInfo: activity.ownerInfo,
            trend: activity.trend,
            overallFeedbackSummary: activity.overallFeedbackSummary,
            questions: activity.questions,
            invitedEmails: activity.invitedEmails,
            participants: activity.participants,
            isDraft: activity.isDraft,
            calendarProvider: activity.calendarProvider
        )
    }

    public func activity(events: [Event]) -> Activity {
        .init(
            id: id,
            title: title,
            agenda: agenda,
            date: date,
            pinCode: pinCode,
            durationInMinutes: durationInMinutes,
            location: location,
            ownerInfo: ownerInfo,
            trend: trend,
            overallFeedbackSummary: overallFeedbackSummary,
            questions: questions,
            events: events,
            isDraft: isDraft,
            invitedEmails: invitedEmails,
            participants: participants,
            calendarProvider: calendarProvider
        )
    }
}

public struct LocalEvent: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let activityId: UUID
    public var date: Date
    public let pinCode: PinCode?
    public let createdFromMailListener: Bool
    public var durationInMinutes: Int
    public var location: String?
    public let calendarEventId: String?
    public let averageRating: Double?
    public var overallFeedbackSummary: OverallFeedbackSummary?
    public var questionsSnapshot: [ManagerQuestion]
    public let calendarProvider: CalendarProvider?

    public init(
        id: UUID,
        activityId: UUID,
        date: Date,
        pinCode: PinCode?,
        createdFromMailListener: Bool = false,
        durationInMinutes: Int,
        location: String? = nil,
        calendarEventId: String? = nil,
        averageRating: Double? = nil,
        overallFeedbackSummary: OverallFeedbackSummary?,
        questionsSnapshot: [ManagerQuestion],
        calendarProvider: CalendarProvider?
    ) {
        self.id = id
        self.activityId = activityId
        self.date = date
        self.pinCode = pinCode
        self.createdFromMailListener = createdFromMailListener
        self.durationInMinutes = durationInMinutes
        self.location = location
        self.calendarEventId = calendarEventId
        self.averageRating = averageRating
        self.overallFeedbackSummary = overallFeedbackSummary
        self.questionsSnapshot = questionsSnapshot
        self.calendarProvider = calendarProvider
    }

    public init(_ event: Event, activityId: UUID) {
        self.init(
            id: event.id,
            activityId: activityId,
            date: event.date,
            pinCode: event.pinCode,
            createdFromMailListener: event.createdFromMailListener,
            durationInMinutes: event.durationInMinutes,
            location: event.location,
            calendarEventId: event.calendarEventId,
            averageRating: event.averageRating,
            overallFeedbackSummary: event.overallFeedbackSummary,
            questionsSnapshot: event.questionsSnapshot,
            calendarProvider: event.calendarProvider
        )
    }

    public var event: Event {
        .init(
            id: id,
            date: date,
            pinCode: pinCode,
            createdFromMailListener: createdFromMailListener,
            durationInMinutes: durationInMinutes,
            location: location,
            calendarEventId: calendarEventId,
            averageRating: averageRating,
            overallFeedbackSummary: overallFeedbackSummary,
            questionsSnapshot: questionsSnapshot,
            calendarProvider: calendarProvider
        )
    }
}
