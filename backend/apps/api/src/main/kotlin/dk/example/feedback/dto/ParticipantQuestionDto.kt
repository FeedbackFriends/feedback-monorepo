package dk.example.feedback.dto

import dk.example.feedback.model.enumerations.FeedbackType
import io.swagger.v3.oas.annotations.media.Schema
import java.util.*

@Schema(description = "Participant-facing question payload for feedback submission.")
data class ParticipantQuestionDto(
    @field:Schema(description = "Question identifier used when submitting feedback.")
    val id: UUID,
    @field:Schema(description = "Question text presented to the participant.")
    val questionText: String,
    @field:Schema(description = "Feedback format expected for this question.")
    val feedbackType: FeedbackType,
)
