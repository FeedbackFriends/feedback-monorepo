import Foundation

public struct ActivityInput: Equatable, Sendable {
    public var title: String
    public var agenda: String?
    public var questions: [EventInput.QuestionInput]
    public var runMode: RunMode
    public var invitedEmails: [String]
    public var sendEmails: Bool

    public init(
        title: String,
        agenda: String? = nil,
        questions: [EventInput.QuestionInput] = [],
        runMode: RunMode = .manual,
        invitedEmails: [String] = [],
        sendEmails: Bool = false
    ) {
        self.title = title
        self.agenda = agenda
        self.questions = questions
        self.runMode = runMode
        self.invitedEmails = invitedEmails
        self.sendEmails = sendEmails
    }
}

public extension ActivityInput {
    init(_ eventInput: EventInput) {
        self.init(
            title: eventInput.title,
            agenda: eventInput.agenda,
            questions: eventInput.questions,
            runMode: .manual,
            invitedEmails: [],
            sendEmails: false
        )
    }

    enum RunMode: String, CaseIterable, Hashable, Sendable {
        case manual
        case automatic
    }
}
