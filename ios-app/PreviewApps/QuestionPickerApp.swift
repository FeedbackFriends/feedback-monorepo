import ComposableArchitecture
import SwiftUI
import FeedbackFlowFeature
import EventsFeature

@main
struct QuestionPickerApp: App {
    var body: some Scene {
        WindowGroup {
            QuestionPickerView(
                existingQuestionIndex: nil,
                feedbackTypeSelected: .emoji,
                questionTextField: "",
                questionSelected: { _, _ in }
            )
        }
    }
}
