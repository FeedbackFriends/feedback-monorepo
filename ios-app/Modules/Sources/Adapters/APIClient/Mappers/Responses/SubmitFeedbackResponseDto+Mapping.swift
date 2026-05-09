import Domain
import OpenAPI

public extension SubmitFeedbackResponseDto {
    init(_ dto: Components.Schemas.SubmitFeedbackResponseDto) {
        self.init(
            shouldPresentRatingPrompt: dto.shouldPresentRatingPrompt,
            session: .init(dto.session),
            event: .init(dto.event)
        )
    }
}
