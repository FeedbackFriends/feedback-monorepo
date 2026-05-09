package dk.example.feedback.dto

import io.swagger.v3.oas.annotations.media.Schema
import java.time.OffsetDateTime

@Schema(description = "Participant-facing session payload returned after joining by pin code.")
data class FeedbackSessionDto(
    @field:Schema(description = "Activity title for the joined session.")
    val title: String,
    val agenda: String?,
    val questions: List<ParticipantQuestionDto>,
    val ownerInfo: OwnerInfoDto,
    @field:Schema(description = "Scheduled timestamp for the joined session.")
    val date: OffsetDateTime,
)





