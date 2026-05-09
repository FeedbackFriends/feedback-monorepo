package dk.example.feedback.model.database

import java.time.OffsetDateTime

data class NewFeedbackNotificationEntity(
    val lastFeedbackAt: OffsetDateTime,
    val newFeedback: Int,
    val session: SessionEntity,
    val account: AccountEntity
) {
    val event: SessionEntity
        get() = session

    fun shouldPush(): Boolean {
        val thirtyMinutesAgo = OffsetDateTime.now().minusMinutes(30)
        return lastFeedbackAt.isBefore(thirtyMinutesAgo)
    }
}
