import Domain
import OpenAPI

public extension FeedbackEventDto {
    init(_ dto: Components.Schemas.FeedbackEventDto, pinCode: PinCode) {
        self.init(
            questions: dto.questions.map(ParticipantQuestion.init),
            ownerInfo: .init(dto.ownerInfo),
            pinCode: pinCode,
            date: dto.date
        )
    }
}
