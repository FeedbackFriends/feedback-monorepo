package dk.example.feedback.model.database

import java.time.OffsetDateTime
import java.util.*

data class NotificationHistoryEntity(
    val id: UUID,
    val createdAt: OffsetDateTime,
    val newFeedback: Int,
    val session: SessionEntity,
    val seenByManager: Boolean,
    val account: AccountEntity,
) {
    val event: SessionEntity
        get() = session
}
