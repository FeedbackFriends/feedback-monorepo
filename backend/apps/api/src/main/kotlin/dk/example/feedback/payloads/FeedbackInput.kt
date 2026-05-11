package dk.example.feedback.payloads

import dk.example.feedback.model.enumerations.Emoji
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.enumerations.Opinion
import dk.example.feedback.model.enumerations.ThumbsUpThumpsDown
import dk.example.feedback.model.interfaces.Feedback
import io.swagger.v3.oas.annotations.media.Schema
import java.util.*

@Schema(description = "Single feedback answer submitted for one question in a event.")
data class FeedbackInput(
    override val comment: String?,
    override val emoji: Emoji?,
    override val thumbsUpThumpsDown: ThumbsUpThumpsDown?,
    override val opinion: Opinion?,
    override val zeroToTen: Int?,
    @field:Schema(description = "Question identifier this feedback answer targets.")
    override val questionId: UUID,
    @field:Schema(description = "Feedback type that determines which answer field is expected.")
    override val feedbackType: FeedbackType,
): Feedback
