import Domain
import OpenAPI

public extension FeedbackSession {
    init(_ dto: Components.Schemas.FeedbackSessionDto, pinCode: PinCode) {
        self.init(
            title: dto.title,
            agenda: dto.agenda,
            questions: dto.questions.map(ParticipantQuestion.init),
            ownerInfo: .init(dto.ownerInfo),
            pinCode: pinCode,
            date: dto.date
        )
    }
}
