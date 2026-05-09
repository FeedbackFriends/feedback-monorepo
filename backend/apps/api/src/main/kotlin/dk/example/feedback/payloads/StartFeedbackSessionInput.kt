package dk.example.feedback.payloads

import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Input payload for joining a feedback session by pin code.")
data class StartFeedbackSessionInput(
    @field:Schema(description = "Session pin code entered by the participant.")
    val pinCode: String,
)
