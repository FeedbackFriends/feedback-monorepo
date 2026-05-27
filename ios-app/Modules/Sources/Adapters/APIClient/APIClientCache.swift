import Foundation
import Domain
import Logger

public actor APIClientCache {
    public enum CacheMutationError: Error, LocalizedError, Equatable {
        case managerDataUnavailable
        case activityNotFound(UUID)
        case eventNotFound(UUID)

        public var errorDescription: String? {
            switch self {
            case .managerDataUnavailable:
                return "Could not update cache. Manager data is missing."
            case .activityNotFound(let id):
                return "Could not update activity in cache. Activity with id \(id) was not found."
            case .eventNotFound(let id):
                return "Could not update event in cache. Event with id \(id) was not found."
            }
        }
    }

    private var bootstrap: Bootstrap? {
        didSet {
            if let bootstrap, bootstrap != oldValue {
                bootstrapContinuation?.yield(bootstrap)
            }
        }
    }
    
    private var bootstrapContinuation: AsyncStream<Bootstrap>.Continuation?
    
    public init(
        bootstrap: Bootstrap? = nil,
        bootstrapContinuation: AsyncStream<Bootstrap>.Continuation? = nil,
    ) {
        self.bootstrap = bootstrap
        self.bootstrapContinuation = bootstrapContinuation
    }
    
    public func getBootstrap() -> Bootstrap? {
        return bootstrap
    }
    
    public func updateBootstrap(_ newBootstrap: Bootstrap) {
        if let cachedBootstrap = bootstrap, cachedBootstrap != newBootstrap {
            Logger.debug("Cached bootstrap overwritten with new bootstrap data")
        }
        bootstrap = newBootstrap
    }
    
    public func deleteActivity(_ activityId: UUID) throws {
        guard var bootstrap else {
            throw CacheMutationError.managerDataUnavailable
        }
        try bootstrap.deleteActivity(activityId)
        self.bootstrap = bootstrap
    }
    
    public func updateOrAppendActivity(_ activity: Activity) throws {
        guard var bootstrap else {
            throw CacheMutationError.managerDataUnavailable
        }
        try bootstrap.updateOrAppendActivity(activity)
        self.bootstrap = bootstrap
    }
    
    public func updateOrAppendEvent(_ event: Event) throws {
        guard var bootstrap else {
            throw CacheMutationError.managerDataUnavailable
        }
        try bootstrap.updateOrAppendEvent(event)
        self.bootstrap = bootstrap
    }

    public func appendEvent(_ event: Event, toActivityId activityId: UUID) throws {
        guard var bootstrap else {
            throw CacheMutationError.managerDataUnavailable
        }
        try bootstrap.appendEvent(event, toActivityId: activityId)
        self.bootstrap = bootstrap
    }

    public func markEventAsSeen(eventId: UUID) throws {
        guard var bootstrap else {
            throw CacheMutationError.managerDataUnavailable
        }
        try bootstrap.markEventAsSeen(eventId: eventId)
        self.bootstrap = bootstrap
    }
    
    public func bootstrapChangedListener() -> AsyncStream<Bootstrap> {
        AsyncStream { continuation in
            self.bootstrapContinuation = continuation
        }
    }
    
    public func updateOrAppendParticipantEvent(_ event: ParticipantEvent) {
        bootstrap?.updateOrAppendParticipantEvent(event)
    }
    
    public func updateAccount(name: String?, email: String?, phoneNumber: String?) {
        bootstrap?.updateAccount(name: name, email: email, phoneNumber: phoneNumber)
    }
    
    public func markActivityAsSeen(activityId: UUID) throws {
        guard var bootstrap else {
            throw CacheMutationError.managerDataUnavailable
        }
        try bootstrap.markActivityAsSeen(activityId: activityId)
        self.bootstrap = bootstrap
    }
    
    public func updateNotificationHistory(_ notificationHistory: NotificationHistory) throws {
        guard var bootstrap else {
            throw CacheMutationError.managerDataUnavailable
        }
        try bootstrap.updateNotificationHistory(notificationHistory)
        self.bootstrap = bootstrap
    }

    public func markNotificationHistoryAsSeen() throws {
        guard var bootstrap else {
            throw CacheMutationError.managerDataUnavailable
        }
        try bootstrap.markNotificationHistoryAsSeen()
        self.bootstrap = bootstrap
    }
    
    public func reset() {
        self.bootstrap = nil
    }
    
    public var bootstrapHash: UUID? {
        self.bootstrap?.managerData?.bootstrapHash
    }
}

public extension Bootstrap {

    mutating func updateOrAppendActivity(_ activity: Activity) throws {
        var managerData = try requiredManagerData()
        managerData.activities.updateOrAppend(activity)
        self.managerData = managerData
    }

    mutating func updateOrAppendEvent(_ event: Event) throws {
        var managerData = try requiredManagerData()
        _ = try managerData.setEvent(event)
        self.managerData = managerData
    }

    mutating func appendEvent(_ event: Event, toActivityId activityId: UUID) throws {
        var managerData = try requiredManagerData()
        try managerData.appendEvent(event, toActivityId: activityId)
        self.managerData = managerData
    }
    
    mutating func updateOrAppendParticipantEvent(_ event: ParticipantEvent) {
        participantEvents.updateOrAppend(event)
    }
    
    mutating func updateParticipantEvent(_ event: ParticipantEvent) {
        if let index = participantEvents.firstIndex(of: event) {
            participantEvents[index] = event
        }
    }
    
    mutating func deleteActivity(_ id: UUID) throws {
        var managerData = try requiredManagerData()
        guard managerData.activities.remove(id: id) != nil else {
            throw APIClientCache.CacheMutationError.activityNotFound(id)
        }
        self.managerData = managerData
    }

    mutating func markActivityAsSeen(activityId: UUID) throws {
        var managerData = try requiredManagerData()
        let updatedActivity = try managerData.activityMarkedAsSeen(id: activityId)
        try managerData.setActivity(updatedActivity)
        _ = managerData.markNotificationItemsSeen(eventId: nil)
        self.managerData = managerData
    }

    mutating func markEventAsSeen(eventId: UUID) throws {
        var managerData = try requiredManagerData()
        let updatedEvent = try managerData.eventMarkedAsSeen(id: eventId)
        _ = try managerData.setEvent(updatedEvent)
        _ = managerData.markNotificationItemsSeen(eventId: eventId)
        self.managerData = managerData
    }
    
    mutating func updateAccount(name: String?, email: String?, phoneNumber: String?) {
        let updatedAccountInfo: AccountInfo = AccountInfo(
            name: name,
            email: email,
            phoneNumber: phoneNumber
        )
        self.accountInfo = updatedAccountInfo
    }
    
    mutating func updateNotificationHistory(_ updatedNotificationHistory: NotificationHistory) throws {
        var managerData = try requiredManagerData()
        managerData.notificationHistory = updatedNotificationHistory
        self.managerData = managerData
    }

    mutating func markNotificationHistoryAsSeen() throws {
        var managerData = try requiredManagerData()
        _ = managerData.markNotificationItemsSeen(eventId: nil)
        self.managerData = managerData
    }

    mutating func updateActivity(id: UUID, _ updatedActivity: Activity) throws {
        var managerData = try requiredManagerData()
        guard updatedActivity.id == id else {
            throw APIClientCache.CacheMutationError.activityNotFound(id)
        }
        try managerData.setActivity(updatedActivity)
        self.managerData = managerData
    }

    mutating func updateEvent(id: UUID, _ updatedEvent: Event) throws {
        var managerData = try requiredManagerData()
        guard updatedEvent.id == id else {
            throw APIClientCache.CacheMutationError.eventNotFound(id)
        }
        _ = try managerData.setEvent(updatedEvent)
        self.managerData = managerData
    }

    private func requiredManagerData() throws -> ManagerData {
        guard let managerData else {
            throw APIClientCache.CacheMutationError.managerDataUnavailable
        }
        return managerData
    }
}

private extension ManagerData {
    func activityMarkedAsSeen(id: UUID) throws -> Activity {
        guard var activity = activities[id: id] else {
            throw APIClientCache.CacheMutationError.activityNotFound(id)
        }
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
        return activity
    }

    func eventMarkedAsSeen(id: UUID) throws -> Event {
        let event = try self.event(id: id)
        var updatedEvent = event
        updatedEvent.overallFeedbackSummary?.unseenResponses = 0
        updatedEvent.questions = updatedEvent.questions.map { question in
            var updatedQuestion = question
            updatedQuestion.feedback = updatedQuestion.feedback.map { feedback in
                var updatedFeedback = feedback
                updatedFeedback.seenByManager = true
                return updatedFeedback
            }
            return updatedQuestion
        }
        return updatedEvent
    }

    func event(id: UUID) throws -> Event {
        for activityId in activities.ids {
            guard let activity = activities[id: activityId] else {
                continue
            }
            guard let event = activity.events.first(where: { $0.id == id }) else {
                continue
            }
            return event
        }
        throw APIClientCache.CacheMutationError.eventNotFound(id)
    }

    mutating func setActivity(_ activity: Activity) throws {
        guard activities[id: activity.id] != nil else {
            throw APIClientCache.CacheMutationError.activityNotFound(activity.id)
        }
        activities[id: activity.id] = activity
    }

    mutating func setEvent(_ event: Event) throws -> UUID {
        for activityId in activities.ids {
            guard var activity = activities[id: activityId] else {
                continue
            }
            guard let eventIndex = activity.events.firstIndex(where: { $0.id == event.id }) else {
                continue
            }
            activity.events[eventIndex] = event
            activities[id: activityId] = activity
            return activityId
        }
        throw APIClientCache.CacheMutationError.eventNotFound(event.id)
    }

    mutating func appendEvent(_ event: Event, toActivityId activityId: UUID) throws {
        guard var activity = activities[id: activityId] else {
            throw APIClientCache.CacheMutationError.activityNotFound(activityId)
        }
        activity.events.append(event)
        activities[id: activityId] = activity
    }

    mutating func markNotificationItemsSeen(eventId: UUID?) -> Int {
        let newlySeenItems = notificationHistory.items.indices.reduce(0) { total, index in
            let shouldMatchEvent = eventId == nil || notificationHistory.items[index].eventId == eventId
            guard shouldMatchEvent, !notificationHistory.items[index].seenByManager else {
                return total
            }
            notificationHistory.items[index].seenByManager = true
            return total + 1
        }
        notificationHistory.unseenTotal = max(0, notificationHistory.unseenTotal - newlySeenItems)
        return newlySeenItems
    }
}
