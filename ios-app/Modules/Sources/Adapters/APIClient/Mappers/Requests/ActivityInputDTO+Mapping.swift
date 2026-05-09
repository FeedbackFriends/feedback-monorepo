import Domain
import Foundation
import OpenAPI

public extension Components.Schemas.ActivityInput.RunModePayload {
    init(_ runMode: ActivityInput.RunMode) {
        guard let payload = Self(rawValue: runMode.rawValue.uppercased()) else {
            fatalError("Could not create ActivityInput.RunModePayload for \(runMode.rawValue)")
        }
        self = payload
    }
}

public extension Components.Schemas.ActivityInput {
    init(_ activity: ActivityInput) {
        self.init(
            title: activity.title,
            agenda: activity.agenda,
            questions: activity.questions.map(Components.Schemas.QuestionInput.init),
            runMode: .init(activity.runMode),
            invitedEmails: activity.invitedEmails,
            sendEmails: activity.sendEmails
        )
    }

    init(forCreate activity: ActivityInput) {
        self.init(
            title: activity.title,
            agenda: activity.agenda,
            questions: activity.questions.map {
                .init(
                    id: nil,
                    questionText: $0.questionText,
                    feedbackType: .init($0.feedbackType)
                )
            },
            runMode: .init(activity.runMode),
            invitedEmails: activity.invitedEmails,
            sendEmails: activity.sendEmails
        )
    }
}
