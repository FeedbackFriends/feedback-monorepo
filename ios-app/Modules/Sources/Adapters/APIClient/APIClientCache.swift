import Foundation
import Domain
import Logger

public actor APIClientCache {
    private var session: Bootstrap? {
        didSet {
            if let session, session != oldValue {
                sessionContinuation?.yield(session)
            }
        }
    }
    
    private var sessionContinuation: AsyncStream<Bootstrap>.Continuation?
    
    public init(
        session: Bootstrap? = nil,
        sessionContinuation: AsyncStream<Bootstrap>.Continuation? = nil,
    ) {
        self.session = session
        self.sessionContinuation = sessionContinuation
    }
    
    public func getSession() -> Bootstrap? {
        return session
    }
    
    public func updateSession(_ newSession: Bootstrap) {
        if let cachedSession = session, cachedSession != newSession {
            Logger.debug("Cached session overwritten with new session data")
        }
        session = newSession
    }
    
    public func deleteActivity(_ activityId: UUID) {
        session?.deleteActivity(activityId)
    }
    
    public func updateOrAppendActivity(_ activity: Activity) {
        session?.updateOrAppendActivity(activity)
    }
    
    public func updateRecentlyUsedQuestions(recentlyUsedQuestions: Set<RecentlyUsedQuestions>) {
        session?.updateRecentlyUsedQuestions(recentlyUsedQuestions)
    }
    
    public func sessionChangedListener() -> AsyncStream<Bootstrap> {
        AsyncStream { continuation in
            self.sessionContinuation = continuation
        }
    }
    
    public func updateOrAppendParticipantEvent(_ event: ParticipantEvent) {
        session?.updateOrAppendParticipantEvent(event)
    }
    
    public func updateAccount(name: String?, email: String?, phoneNumber: String?) {
        session?.updateAccount(name: name, email: email, phoneNumber: phoneNumber)
    }
    
    public func markActivityAsSeen(activityId: UUID) {
        session?.markActivityAsSeen(activityId: activityId)
    }
    
    public func updateNotificationHistory(_ notificationHistory: NotificationHistory) {
        session?.updateNotificationHistory(notificationHistory)
    }

    public func markNotificationHistoryAsSeen() {
        session?.markNotificationHistoryAsSeen()
    }
    
    public func reset() {
        self.session = nil
    }
    
    public var feedbackSessionHash: UUID? {
        self.session?.managerData?.feedbackSessionHash
    }
}

public extension Bootstrap {
    
    mutating func updateOrAppendActivity(_ activity: Activity) {
        self.managerData?.activities.updateOrAppend(activity)
    }
    
    mutating func updateOrAppendParticipantEvent(_ event: ParticipantEvent) {
        participantEvents.updateOrAppend(event)
    }
    
    mutating func updateParticipantEvent(_ event: ParticipantEvent) {
        if let index = participantEvents.firstIndex(of: event) {
            participantEvents[index] = event
        }
    }
    
    mutating func deleteActivity(_ id: UUID) {
        self.managerData?.activities.remove(id: id)
    }
    
    func getActivityId(_ id: UUID) -> Activity {
        return self.managerData!.activities[id: id]!
    }
    
    func recentlyUsedQuestions() -> Set<RecentlyUsedQuestions> {
        return self.managerData!.recentlyUsedQuestions
    }
    
    mutating func markActivityAsSeen(activityId: UUID) {
        guard var activity = self.managerData?.activities[id: activityId] else { return }
        activity.overallFeedbackSummary?.unseenResponses = 0
        activity.questions = activity.questions.map { question in
            var updatedQuestion = question
            updatedQuestion.feedback = updatedQuestion.feedback.map { feedback in
                var updatedFeedback = feedback
                updatedFeedback.seenByManager = true
                return updatedFeedback
            }
            
            return updatedQuestion
        }
        
        self.managerData?.activities[id: activityId] = activity
        guard let notificationHistory = self.managerData?.notificationHistory, notificationHistory.unseenTotal > 0 else { return }
        Logger.debug("Unseen er over 0, så ør fjerne")
        var mutableNotificationHistory = notificationHistory
        mutableNotificationHistory.unseenTotal -= 1
        for index in mutableNotificationHistory.items.indices {
            mutableNotificationHistory.items[index].seenByManager = true
        }
        self.managerData!.notificationHistory = mutableNotificationHistory
    }
    
    mutating func updateAccount(name: String?, email: String?, phoneNumber: String?) {
        let updatedAccountInfo: AccountInfo = AccountInfo(
            name: name,
            email: email,
            phoneNumber: phoneNumber
        )
        self.accountInfo = updatedAccountInfo
    }
    
    mutating func updateNotificationHistory(_ updatedNotificationHistory: NotificationHistory) {
        self.managerData?.notificationHistory = updatedNotificationHistory
    }

    mutating func markNotificationHistoryAsSeen() {
        var mutableNotificationHistory = self.managerData!.notificationHistory
        mutableNotificationHistory.unseenTotal = 0
        for index in mutableNotificationHistory.items.indices {
            mutableNotificationHistory.items[index].seenByManager = true
        }
        
        self.managerData?.notificationHistory = mutableNotificationHistory
    }
    
    mutating func updateRecentlyUsedQuestions(_ questions: Set<RecentlyUsedQuestions>) {
        self.managerData?.recentlyUsedQuestions = questions
    }
}
