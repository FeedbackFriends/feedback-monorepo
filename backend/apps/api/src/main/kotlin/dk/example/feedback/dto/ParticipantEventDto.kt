package dk.example.feedback.dto

import io.swagger.v3.oas.annotations.media.Schema
import java.time.OffsetDateTime
import java.util.UUID

@Schema(description = "Participant-visible event payload including join and feedback status.")
data class ParticipantEventDto(
    @field:Schema(description = "Stable identifier for the event.")
    var id: UUID,
    @field:Schema(description = "Scheduled start timestamp for the event.")
    val date: OffsetDateTime,
    @field:Schema(description = "Pin code used to join the event.")
    val pinCode: String?,
    val durationInMinutes: Int,
    val location: String?,
    val createdFromMailListener: Boolean,
    val ownerInfo: OwnerInfoDto,
    val questions: List<ParticipantQuestionDto>,
    val feedbackSubmited: Boolean,
    val recentlyJoined: Boolean,
)
