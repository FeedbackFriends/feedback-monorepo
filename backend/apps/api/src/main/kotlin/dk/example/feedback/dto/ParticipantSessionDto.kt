package dk.example.feedback.dto

import io.swagger.v3.oas.annotations.media.Schema
import java.time.OffsetDateTime
import java.util.UUID

@Schema(description = "Participant-visible session payload including join and feedback status.")
data class ParticipantSessionDto(
    @field:Schema(description = "Stable identifier for the session.")
    var id: UUID,
    @field:Schema(description = "Activity title shown to the participant.")
    val title: String,
    val agenda: String?,
    @field:Schema(description = "Scheduled start timestamp for the session.")
    val date: OffsetDateTime,
    @field:Schema(description = "Pin code used to join the session.")
    val pinCode: String?,
    val durationInMinutes: Int,
    val location: String?,
    val createdFromMailListener: Boolean,
    val ownerInfo: OwnerInfoDto,
    val questions: List<ParticipantQuestionDto>,
    val feedbackSubmited: Boolean,
    val recentlyJoined: Boolean,
)
