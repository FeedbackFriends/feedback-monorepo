package dk.example.feedback.payloads

import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Input payload for joining a feedback event by pin code.")
data class StartFeedbackEventInput(
    @field:Schema(description = "Event pin code entered by the participant.")
    val pinCode: String,
)
