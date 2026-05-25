import Foundation
import Domain
import OpenAPI

public extension ParticipantEvent {
    init(_ dto: Components.Schemas.ParticipantEventDto) {
        self.init(
            id: UUID(uuidString: dto.id)!,
            date: dto.date,
            pinCode: dto.pinCode.map { PinCode(value: $0) },
            location: dto.location,
            durationInMinutes: Int(dto.durationInMinutes),
            questions: dto.questions.map(ParticipantQuestion.init),
            feedbackSubmited: dto.feedbackSubmited,
            ownerInfo: .init(dto.ownerInfo),
            recentlyJoined: dto.recentlyJoined
        )
    }
}
