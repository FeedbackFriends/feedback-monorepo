package dk.example.feedback.payloads

import dk.example.feedback.model.enumerations.FeedbackType
import io.swagger.v3.oas.annotations.media.Schema
import java.util.UUID

@Schema(description = "Input payload for a question in activity create/update requests.")
data class QuestionInput(
    @field:Schema(description = "Canonical question identifier when updating an existing question.")
    val id: UUID? = null,
    @field:Schema(description = "Question text shown to participants.")
    val questionText: String,
    @field:Schema(description = "Feedback format expected for this question.")
    val feedbackType: FeedbackType,
)
