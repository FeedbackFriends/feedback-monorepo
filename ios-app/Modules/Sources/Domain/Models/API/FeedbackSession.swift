import Foundation

public struct FeedbackSession: Equatable, Sendable {
    public let title: String
    public let agenda: String?
    public let questions: [ParticipantQuestion]
    public let ownerInfo: OwnerInfo
    public let pinCode: PinCode
    public let date: Date
    public init(
        title: String,
        agenda: String?,
        questions: [ParticipantQuestion],
        ownerInfo: OwnerInfo,
        pinCode: PinCode,
        date: Date
    ) {
        self.title = title
        self.agenda = agenda
        self.questions = questions
        self.ownerInfo = ownerInfo
        self.pinCode = pinCode
        self.date = date
    }
}
