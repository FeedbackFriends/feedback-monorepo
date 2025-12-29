package dk.example.feedback.model.database

import java.time.OffsetDateTime
import java.util.*

data class ActivityEntity(
    val id: UUID,
    val createdAt: OffsetDateTime,
    val newFeedback: Int,
    val event: EventEntity,
    val seenByManager: Boolean,
    val account: AccountEntity
) 
