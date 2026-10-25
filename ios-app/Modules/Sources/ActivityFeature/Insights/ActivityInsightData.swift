import Domain
import Foundation

/// Uses session snapshots exclusively: account-wide question analytics can span other activities.
struct ActivityInsightData {
    let activity: Activity

    var feedbackEvents: [Event] {
        activity.events.filter { ($0.overallFeedbackSummary?.responses ?? 0) > 0 }
            .sorted { lhs, rhs in
                lhs.date == rhs.date ? lhs.id.uuidString < rhs.id.uuidString : lhs.date > rhs.date
            }
    }

    var latestFeedbackAt: Date? {
        activity.events.flatMap(\.questionsSnapshot).flatMap(\.feedback).map(\.createdAt).max()
    }

    var responseCount: Int {
        feedbackEvents.reduce(0) { $0 + ($1.overallFeedbackSummary?.responses ?? 0) }
    }

    var comparisonResponseCount: Int {
        let events = activity.events.sorted { $0.date > $1.date }.filter { $0.averageRating != nil }
            .prefix(activity.trend.comparedEventCount)
        return events.flatMap(\.questionsSnapshot).flatMap(\.feedback).filter {
            if case .zeroToTen = $0.type { return true }
            return false
        }.count
    }

    var questions: [InsightQuestionHistory] {
        var histories: [InsightQuestionHistory] = []
        for event in feedbackEvents.reversed() {
            for question in event.questionsSnapshot {
                let key = InsightQuestionHistory.Key(
                    questionId: question.activityQuestionId ?? question.id, text: question.questionText, type: question.feedbackType
                )
                let session = InsightQuestionHistory.Session(event: event, question: question)
                if let index = histories.firstIndex(where: { $0.id == key }) {
                    histories[index].sessions.append(session)
                } else {
                    histories.append(.init(id: key, sessions: [session]))
                }
            }
        }
        return histories
    }

    static func sorted(_ activities: [Activity]) -> [Activity] {
        activities.sorted { lhs, rhs in
            let left = Self(activity: lhs)
            let right = Self(activity: rhs)
            if left.feedbackEvents.isEmpty != right.feedbackEvents.isEmpty {
                return !left.feedbackEvents.isEmpty
            }
            if left.latestFeedbackAt != right.latestFeedbackAt {
                return (left.latestFeedbackAt ?? .distantPast) > (right.latestFeedbackAt ?? .distantPast)
            }
            return lhs.id.uuidString < rhs.id.uuidString
        }
    }
}

struct InsightQuestionHistory: Identifiable {
    struct Key: Hashable {
        let questionId: UUID
        let text: String
        let type: FeedbackType
    }

    struct Session: Identifiable {
        let event: Event
        let question: ManagerQuestion
        var id: UUID { event.id }
    }

    let id: Key
    var sessions: [Session]
}

extension ActivityTrend {
    var insightTitle: String {
        switch direction {
        case .improving: "Feedbacken går frem"
        case .stable: "Feedbacken er stabil"
        case .declining: "Feedbacken går tilbage"
        case .insufficientData: "Afventer flere sessioner med rating"
        }
    }

    var insightSymbol: String {
        switch direction {
        case .improving: "arrow.up.right"
        case .stable: "arrow.right"
        case .declining: "arrow.down.right"
        case .insufficientData: "chart.line.uptrend.xyaxis"
        }
    }
}
