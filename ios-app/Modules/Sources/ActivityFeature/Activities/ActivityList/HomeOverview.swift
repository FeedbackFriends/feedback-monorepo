import Domain
import Foundation

struct HomeOverview {
    struct Session: Identifiable {
        let activity: Activity
        let event: Event
        var id: UUID { event.id }
        var responseCount: Int { event.overallFeedbackSummary?.responses ?? 0 }
        var unseenResponses: Int { event.overallFeedbackSummary?.unseenResponses ?? 0 }
        var latestFeedbackAt: Date? {
            event.questionsSnapshot.flatMap(\.feedback).map(\.createdAt).max()
        }
    }

    let unreadSessions: [Session]
    let latestFeedbackSession: Session?
    let recentSessionCount: Int
    let recentFeedbackSessionCount: Int
    let nextSession: Session?
    let developments: [Activity]

    init(activities: [Activity], now: Date) {
        let sessions = activities.flatMap { activity in
            activity.events.map { Session(activity: activity, event: $0) }
        }
        unreadSessions = sessions.filter { $0.unseenResponses > 0 }.sorted {
            if $0.latestFeedbackAt != $1.latestFeedbackAt {
                return ($0.latestFeedbackAt ?? .distantPast) > ($1.latestFeedbackAt ?? .distantPast)
            }
            return $0.id.uuidString < $1.id.uuidString
        }
        latestFeedbackSession = unreadSessions.isEmpty ? sessions.filter {
            $0.responseCount > 0 && $0.event.date <= now
        }.sorted {
            if $0.latestFeedbackAt != $1.latestFeedbackAt {
                return ($0.latestFeedbackAt ?? .distantPast) > ($1.latestFeedbackAt ?? .distantPast)
            }
            if $0.event.date != $1.event.date { return $0.event.date > $1.event.date }
            return $0.id.uuidString < $1.id.uuidString
        }.first : nil
        nextSession = sessions.filter { $0.event.date >= now }.min {
            if $0.event.date != $1.event.date { return $0.event.date < $1.event.date }
            return $0.id.uuidString < $1.id.uuidString
        }
        let recentCutoff = now.addingTimeInterval(-30 * 24 * 60 * 60)
        let recentSessions = sessions.filter {
            $0.event.date >= recentCutoff &&
                $0.event.date.addingTimeInterval(Double($0.event.durationInMinutes) * 60) <= now
        }
        recentSessionCount = recentSessions.count
        recentFeedbackSessionCount = recentSessions.filter { $0.responseCount > 0 }.count
        developments = ActivityInsightData.sorted(activities).filter { activity in
            guard activity.trend.direction == .improving || activity.trend.direction == .declining,
                  let date = ActivityInsightData(activity: activity).latestFeedbackAt else { return false }
            return date >= recentCutoff && date <= now
        }
    }
}
