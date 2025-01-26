package dk.example.feedback.model.database

data class EventParticipantEntity(
    val event: EventEntity,
    val participant: AccountEntity,
    val feedbackSubmitted: Boolean,
)
