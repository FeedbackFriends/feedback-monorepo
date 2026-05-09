import Foundation
import Domain
import OpenAPI

public extension ParticipantQuestion {
    init(_ dto: Components.Schemas.ParticipantQuestionDto) {
        self.init(
            id: UUID(uuidString: dto.id)!,
            questionText: dto.questionText,
            feedbackType: .init(dto.feedbackType.rawValue)
        )
    }
}
