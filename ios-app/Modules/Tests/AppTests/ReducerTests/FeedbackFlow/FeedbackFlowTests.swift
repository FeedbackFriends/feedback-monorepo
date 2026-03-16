@testable import FeedbackFlowFeature
import ComposableArchitecture
import Testing
import Foundation
import Domain

@MainActor
struct FeedbackFlowTests {
    
    @Test
    func `Initial state is set up correctly with feedback session data`() async throws {
        let store = TestStore(initialState: .initialState(feedbackSession: session)) {
            FeedbackFlowCoordinator()
        }
        #expect(store.state.path.count == 1)
        #expect(store.state.questions.count == session.questions.count)
        #expect(store.state.title == session.title)
        #expect(store.state.date == session.date)
        #expect(store.state.ownerInfo == session.ownerInfo)
        #expect(store.state.questionIndex == 0)
        #expect(store.state.agenda == session.agenda)
    }
    
    @Test
    func `Info button shows event info screen and dismisses correctly`() async {
        let store = TestStore(initialState: .initialState(feedbackSession: session)) {
            FeedbackFlowCoordinator()
        }
        
        await store.send(.infoButtonTap) {
            $0.destination = .showEventInfo
        }
        await store.send(.destination(.dismiss)) {
            $0.destination = nil
        }
    }
    
    @Test
    func `Cancel button triggers view dismissal`() async {
        let didDismiss = LockIsolated(false)
        
        let store = TestStore(initialState: .initialState(feedbackSession: session)) {
            FeedbackFlowCoordinator()
        } withDependencies: {
            $0.dismiss = .init { didDismiss.setValue(true) }
        }
        
        await store.send(.dismissButtonTap)
        #expect(didDismiss.value)
    }
    
    @Test
    func `Full feedback flow runs successfully with rating prompt and dismissal`() async {
        let didDismiss = LockIsolated(false)
        let clock = TestClock()
        
        let store = TestStore(initialState: .initialState(feedbackSession: session)) {
            FeedbackFlowCoordinator()
        } withDependencies: {
            $0.apiClient.submitFeedback = { _, _ in true }
            $0.continuousClock = clock
            $0.dismiss = .init { didDismiss.setValue(true) }
        }
        
        #expect(store.state.path.count == 1)
        #expect(store.state.questionText == session.questions[0].questionText)
        #expect(store.state.questionIndex == 0)
        
        // Tap smiley
        await store.send(.path(.element(id: 0, action: .emoji(.onSmileyTapped(.happy))))) {
            $0.path[id: 0, case: \.emoji]?.selectedEmoji = .happy
        }
        await store.receive(\.path[id: 0].emoji.delegate, .setCommentTextfieldFocus(true)) {
            $0.commentTextfieldFocused = true
        }
        // Tap next (expecting delay since keyboard is open)
        await store.send(.nextQuestionButtonTap) {
            $0.commentTextfieldFocused = false
        }
        await clock.advance(by: .seconds(0.5))
        await store.withExhaustivity(.off) {
            await store.receive(\.navigateToNextQuestion)
        }
        #expect(store.state.path.count == 2)
        #expect(store.state.questionText == session.questions[1].questionText)
        #expect(store.state.questionIndex == 1)
        // Tap smiley
        await store.send(.path(.element(id: 1, action: .emoji(.onSmileyTapped(.sad))))) {
            $0.path[id: 1, case: \.emoji]?.selectedEmoji = .sad
        }
        await store.receive(\.path[id: 1].emoji.delegate, .setCommentTextfieldFocus(true)) {
            $0.commentTextfieldFocused = true
        }
        
        // Tap previous (expecting delay since keyboard is open)
        await store.send(.previousQuestionButtonTap) {
            $0.commentTextfieldFocused = false
        }
        await clock.advance(by: .seconds(0.5))
        await store.withExhaustivity(.off) {
            await store.receive(\.navigateToPreviousQuestion)
        }
        #expect(store.state.path.count == 1)
        #expect(store.state.questionText == session.questions[0].questionText)
        #expect(store.state.questionIndex == 0)
        #expect(store.state.path[0].emoji?.selectedEmoji == .happy)
        
        // Tap next (expecting no delay)
        await store.send(.nextQuestionButtonTap)
        await store.withExhaustivity(.off) {
            await store.receive(\.navigateToNextQuestion)
        }
        #expect(store.state.path.count == 2)
        #expect(store.state.questionText == session.questions[1].questionText)
        #expect(store.state.questionIndex == 1)
        #expect(store.state.path[1].emoji?.selectedEmoji == .sad)
        
        // Tap submit
        await store.send(.submitButtonTap) {
            $0.commentTextfieldFocused = false
            $0.submitFeedbackInFlight = true
        }
        
        await store.receive(\.submitFeedbackResponse) {
            $0.presentSuccessOverlay = true
            $0.submitFeedbackInFlight = false
        }
        
        // 2 Sec delay while success is shown
        await clock.advance(by: .seconds(2))
        // Rating presented
        await store.receive(\.presentRatingPrompt) {
            $0.destination = .ratingPrompt
        }
        #expect(didDismiss.value == false)
        // Flow closed after rating is dismissed
        await store.send(.ratingPromptDismissed)
        await clock.advance(by: .seconds(1))
        #expect(didDismiss.value == true)
    }
    
    @Test
    func `Feedback submission without rating prompt dismisses automatically`() async {
        let didDismiss = LockIsolated(false)
        
        let store = TestStore(initialState: readyForSubmissionState) {
            FeedbackFlowCoordinator()
        } withDependencies: {
            $0.apiClient.submitFeedback = { _, _ in false }
            $0.continuousClock = ImmediateClock()
            $0.dismiss = .init { didDismiss.setValue(true) }
        }
        await store.send(.submitButtonTap) {
            $0.submitFeedbackInFlight = true
        }
        await store.receive(\.submitFeedbackResponse) {
            $0.presentSuccessOverlay = true
            $0.submitFeedbackInFlight = false
        }
        #expect(didDismiss.value)
    }
    
    @Test
    func `Feedback submission failure shows error alert`() async {
        let error = URLError(.badURL)
        
        let store = TestStore(initialState: readyForSubmissionState) {
            FeedbackFlowCoordinator()
        } withDependencies: {
            $0.apiClient.submitFeedback = { _, _ in throw error }
            $0.continuousClock = ImmediateClock()
        }
        await store.send(.submitButtonTap) {
            $0.submitFeedbackInFlight = true
        }
        await store.receive(\.presentError) {
            $0.destination = .alert(.init(error: error))
            $0.submitFeedbackInFlight = false
        }
    }
    
    @Test
    func `Feedback input correctly converts from emoji path to model`() async throws {
        let id = UUID()
        let withComment = FeedbackInput(
            .emoji(
                .init(
                    questionId: id,
                    questionText: "How are you?",
                    selectedEmoji: Emoji.happy,
                    commentTextField: "So good!"
                )
            )
        )
        #expect(withComment.type == .emoji(emoji: .happy, comment: "So good!"))
        #expect(withComment.questionId == id)
        
        let withoutComment = FeedbackInput(
            .emoji(
                .init(
                    questionId: id,
                    questionText: "How are you?",
                    selectedEmoji: Emoji.happy,
                    commentTextField: ""
                )
            )
        )
        #expect(withoutComment.type == .emoji(emoji: .happy, comment: nil))
        #expect(withoutComment.questionId == id)
    }
}

private extension FeedbackFlowTests {
    var session: FeedbackSession {
        .init(
            title: "Design Review",
            agenda: "Discuss new UI components",
            questions: [
                .init(
                    id: question1.questionId,
                    questionText: question1.questionText,
                    feedbackType: .emoji
                ),
                .init(
                    id: question2.questionId,
                    questionText: question2.questionText,
                    feedbackType: .emoji
                )
            ],
            ownerInfo: .init(name: "Romain", email: "romain@example.com", phoneNumber: "88888888"),
            pinCode: .init(value: "1234"),
            date: .init(timeIntervalSince1970: 0)
        )
    }
    
    var question1: EmojiFeedback.State {
        .init(
            questionId: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            questionText: "How do you feel?",
            selectedEmoji: .happy,
            commentTextField: "So good!"
        )
    }
    var question2: EmojiFeedback.State {
        .init(
            questionId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            questionText: "How would you rate this session?",
            selectedEmoji: .sad,
            commentTextField: ""
        )
    }
    
    var readyForSubmissionState: FeedbackFlowCoordinator.State {
        return .init(
            path: .init(
                [
                    .emoji(question1),
                    .emoji(question2)
                    
                ]
            ),
            submitFeedbackInFlight: false,
            presentSuccessOverlay: false,
            questions: IdentifiedArrayOf<FeedbackFlowCoordinator.Path.State>.init(
                arrayLiteral: .emoji(question1), .emoji(question2)
            ),
            feedbackSession: session,
            commentTextfieldFocused: false
        )
    }
}
