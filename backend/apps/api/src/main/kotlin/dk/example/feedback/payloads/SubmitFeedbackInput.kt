package dk.example.feedback.payloads

import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Input payload for submitting participant feedback to a event.")
data class SubmitFeedbackInput(
    @field:Schema(description = "Collection of feedback answers keyed by question id.")
    val feedback: List<FeedbackInput>,
    @field:Schema(description = "Event pin code the feedback belongs to.")
    val pinCode: String,
)
