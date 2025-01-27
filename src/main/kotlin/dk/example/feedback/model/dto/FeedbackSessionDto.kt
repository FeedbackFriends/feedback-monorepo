package dk.example.feedback.model.dto

import java.time.OffsetDateTime

data class FeedbackSessionDto(
    val title: String,
    val agenda: String?,
    val questions: List<ParticipantQuestionDto>,
    val ownerInfo: OwnerInfoDto,
    val date: OffsetDateTime,
)






