package dk.example.feedback.model.database

import java.time.OffsetDateTime
import java.util.UUID

data class EventInviteEntity(
    val id: UUID,
    val email: String,
    val accountId: String?,
    val createdAt: OffsetDateTime,
    val updatedAt: OffsetDateTime,
)

