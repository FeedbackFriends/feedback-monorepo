import Foundation
import Domain
import Logger

public actor SessionCache {
    private var session: Session? {
        didSet {
            if let session, session != oldValue {
                sessionContinuation?.yield(session)
            }
        }
    }
    
    private var sessionContinuation: AsyncStream<Session>.Continuation?
    
    public init(
        session: Session? = nil,
        sessionContinuation: AsyncStream<Session>.Continuation? = nil,
    ) {
        self.session = session
        self.sessionContinuation = sessionContinuation
    }
    
    public func getSession() -> Session? {
        return session
    }
    
    public func updateSession(_ newSession: Session) {
        session = newSession
    }
    
    public func deleteEvent(_ eventId: UUID) {
        session?.deleteEvent(eventId)
    }
    
    public func updateOrAppendManagerEvent(event: ManagerEvent) {
        session?.updateOrAppendManagerEvent(event)
    }
    
    public func updateRecentlyUsedQuestions(recentlyUsedQuestions: Set<RecentlyUsedQuestions>) {
        session?.updateRecentlyUsedQuestions(recentlyUsedQuestions)
    }
    
    public func sessionChangedListener() -> AsyncStream<Session> {
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
    
    public func markEventAsSeen(eventId: UUID) {
        session?.markEventAsSeen(eventId: eventId)
    }
    
    public func updateActivity(_ activity: Activity) {
        session?.updateActivity(activity)
    }
    
    public func markActivityAsSeen() {
        session?.markActivityAsSeen()
    }
    
    public func reset() {
        self.session = nil
    }
    
    public var feedbackSessionHash: UUID? {
        self.session?.managerData?.feedbackSessionHash
    }
}

public extension Session {
    
    mutating func updateOrAppendManagerEvent(_ event: ManagerEvent) {
        self.managerData?.managerEvents.updateOrAppend(event)
    }
    
    mutating func updateOrAppendParticipantEvent(_ event: ParticipantEvent) {
        participantEvents.updateOrAppend(event)
    }
    
    mutating func updateParticipantEvent(_ event: ParticipantEvent) {
        if let index = participantEvents.firstIndex(of: event) {
            participantEvents[index] = event
        }
    }
    
    mutating func deleteEvent(_ id: UUID) {
        self.managerData?.managerEvents.remove(id: id)
    }
    
    func getManagerEventId(_ id: UUID) -> ManagerEvent {
        return self.managerData!.managerEvents[id: id]!
    }
    
    func recentlyUsedQuestions() -> Set<RecentlyUsedQuestions> {
        return self.managerData!.recentlyUsedQuestions
    }
    
    mutating func markEventAsSeen(eventId: UUID) {
        guard var event = self.managerData?.managerEvents[id: eventId] else { return }
        event.overallFeedbackSummary?.unseenResponses = 0
        event.questions = event.questions.map { question in
            var updatedQuestion = question
            updatedQuestion.feedback = updatedQuestion.feedback.map { feedback in
                var updatedFeedback = feedback
                updatedFeedback.seenByManager = true
                return updatedFeedback
            }
            
            return updatedQuestion
        }
        
        self.managerData?.managerEvents[id: eventId] = event
        guard let activity = self.managerData?.activity, activity.unseenTotal > 0 else { return }
        Logger.debug("Unseen er over 0, så ør fjerne")
        var mutableActivity = activity
        mutableActivity.unseenTotal -= 1
        for index in mutableActivity.items.indices {
            mutableActivity.items[index].seenByManager = true
        }
        self.managerData!.activity = mutableActivity
    }
    
    mutating func updateAccount(name: String?, email: String?, phoneNumber: String?) {
        let updatedAccountInfo: AccountInfo = AccountInfo(
            name: name,
            email: email,
            phoneNumber: phoneNumber
        )
        self.accountInfo = updatedAccountInfo
    }
    
    mutating func updateActivity(_ updatedActivity: Activity) {
        self.managerData?.activity = updatedActivity
    }
    
    mutating func markActivityAsSeen() {
        var mutableActivity = self.managerData!.activity
        mutableActivity.unseenTotal = 0
        for index in mutableActivity.items.indices {
            mutableActivity.items[index].seenByManager = true
        }
        
        self.managerData?.activity = mutableActivity
    }
    
    mutating func updateRecentlyUsedQuestions(_ questions: Set<RecentlyUsedQuestions>) {
        self.managerData?.recentlyUsedQuestions = questions
    }
}
