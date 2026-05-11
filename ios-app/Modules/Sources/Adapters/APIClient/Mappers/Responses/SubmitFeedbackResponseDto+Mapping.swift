import Domain
import OpenAPI

public extension SubmitFeedbackResponseDto {
    init(_ dto: Components.Schemas.SubmitFeedbackResponseDto) {
        self.init(
            shouldPresentRatingPrompt: dto.shouldPresentRatingPrompt,
            event: .init(dto.event)
        )
    }
}
