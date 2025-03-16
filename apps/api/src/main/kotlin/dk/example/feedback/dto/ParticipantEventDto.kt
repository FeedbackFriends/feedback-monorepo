package dk.example.feedback.dto

import java.time.OffsetDateTime
import java.util.*

data class ParticipantEventDto (
    var id: UUID,
    val title: String,
    val agenda: String?,
    val date: OffsetDateTime,
    val pinCode: String,
    val durationInMinutes: Int,
    val location: String?,
    val ownerInfo: OwnerInfoDto,
    val questions: List<ParticipantQuestionDto>,
    val feedbackSubmited: Boolean,
    val recentlyJoined: Boolean,
)

