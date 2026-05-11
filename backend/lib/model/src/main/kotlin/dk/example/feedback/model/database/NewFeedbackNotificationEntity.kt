package dk.example.feedback.model.database

import java.time.OffsetDateTime

data class NewFeedbackNotificationEntity(
    val lastFeedbackAt: OffsetDateTime,
    val newFeedback: Int,
    val event: EventEntity,
    val account: AccountEntity
) {
    fun shouldPush(): Boolean {
        val thirtyMinutesAgo = OffsetDateTime.now().minusMinutes(30)
        return lastFeedbackAt.isBefore(thirtyMinutesAgo)
    }
}
