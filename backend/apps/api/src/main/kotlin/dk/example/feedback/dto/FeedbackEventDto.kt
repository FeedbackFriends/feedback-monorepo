package dk.example.feedback.dto

import io.swagger.v3.oas.annotations.media.Schema
import java.time.OffsetDateTime

@Schema(description = "Participant-facing event payload returned after joining by pin code.")
data class FeedbackEventDto(
    val questions: List<ParticipantQuestionDto>,
    val ownerInfo: OwnerInfoDto,
    @field:Schema(description = "Scheduled timestamp for the joined event.")
    val date: OffsetDateTime,
)




