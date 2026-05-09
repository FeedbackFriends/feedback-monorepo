package dk.example.feedback.payloads

import io.swagger.v3.oas.annotations.media.Schema
import java.time.OffsetDateTime
import java.util.UUID

@Schema(description = "Input payload for creating a new feedback session for an activity.")
data class SessionInput(
    @field:Schema(description = "Identifier of the activity the session belongs to.")
    val activityId: UUID,
    @field:Schema(description = "Scheduled start timestamp for the session.")
    val date: OffsetDateTime,
    val durationInMinutes: Int,
    val location: String?,
)

typealias EventInput = SessionInput
