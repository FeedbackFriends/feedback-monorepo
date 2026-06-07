import Domain
import Foundation

struct ActivityDetailSessionGrouping: Equatable {
    let sections: [EventListSection]
    let activeSections: [EventListSection]
    let comingUpSections: [EventListSection]
    let previousSections: [EventListSection]

    var hasSessionsOutsideActive: Bool {
        !comingUpSections.isEmpty || !previousSections.isEmpty
    }

    init(
        events: [Event],
        now: Date = Date(),
        calendar: Calendar = .current
    ) {
        let active = events
            .sorted { Self.closestSort($0, $1, now: now) }
            .prefix(3)
            .sorted { Self.activeSort($0, $1, now: now) }
        let activeIds = Set(active.map(\.id))
        let comingUp = events
            .filter { !activeIds.contains($0.id) && $0.date > now }
            .sorted { $0.date < $1.date }
        let previous = events
            .filter { !activeIds.contains($0.id) && $0.date <= now }
            .sorted { $0.date > $1.date }

        self.sections = [
            EventListSection(title: "Aktuelt", events: active),
            EventListSection(title: "Kommende", events: comingUp),
            EventListSection(title: "Tidligere", events: previous)
        ]
        .filter { !$0.events.isEmpty }
        self.activeSections = [
            EventListSection(title: "Aktuelt", events: active)
        ]
        .filter { !$0.events.isEmpty }
        self.comingUpSections = [
            EventListSection(title: "Kommende", events: comingUp)
        ]
        .filter { !$0.events.isEmpty }
        self.previousSections = [
            EventListSection(title: "Tidligere", events: previous)
        ]
        .filter { !$0.events.isEmpty }
    }

    private static func closestSort(_ lhs: Event, _ rhs: Event, now: Date) -> Bool {
        let lhsDistance = abs(lhs.date.timeIntervalSince(now))
        let rhsDistance = abs(rhs.date.timeIntervalSince(now))

        if lhsDistance != rhsDistance {
            return lhsDistance < rhsDistance
        }

        return lhs.date > rhs.date
    }

    private static func activeSort(_ lhs: Event, _ rhs: Event, now: Date) -> Bool {
        let lhsHasUnseenResponses = (lhs.overallFeedbackSummary?.unseenResponses ?? 0) > 0
        let rhsHasUnseenResponses = (rhs.overallFeedbackSummary?.unseenResponses ?? 0) > 0

        if lhsHasUnseenResponses != rhsHasUnseenResponses {
            return lhsHasUnseenResponses
        }

        let lhsDistance = abs(lhs.date.timeIntervalSince(now))
        let rhsDistance = abs(rhs.date.timeIntervalSince(now))

        if lhsDistance != rhsDistance {
            return lhsDistance < rhsDistance
        }

        return lhs.date > rhs.date
    }
}
