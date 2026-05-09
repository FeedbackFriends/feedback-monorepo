import Foundation
import Domain
import OpenAPI

public extension ParticipantSessionDto {
    init(_ dto: Components.Schemas.ParticipantSessionDto) {
        self.init(
            id: UUID(uuidString: dto.id) ?? UUID(),
            title: dto.title,
            agenda: dto.agenda,
            date: dto.date,
            pinCode: dto.pinCode.map { PinCode(value: $0) },
            location: dto.location,
            durationInMinutes: Int(dto.durationInMinutes),
            questions: dto.questions.map(ParticipantQuestion.init),
            feedbackSubmitted: dto.feedbackSubmited,
            ownerInfo: .init(dto.ownerInfo),
            recentlyJoined: dto.recentlyJoined
        )
    }
}
