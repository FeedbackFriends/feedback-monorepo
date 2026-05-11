import Foundation

public struct FeedbackEventDto: Equatable, Sendable {
    public let questions: [ParticipantQuestion]
    public let ownerInfo: OwnerInfo
    public let pinCode: PinCode
    public let date: Date
    public var title: String { "Event" }
    public var agenda: String? { nil }
    public init(
        questions: [ParticipantQuestion],
        ownerInfo: OwnerInfo,
        pinCode: PinCode,
        date: Date
    ) {
        self.questions = questions
        self.ownerInfo = ownerInfo
        self.pinCode = pinCode
        self.date = date
    }
}
