package dk.example.feedback.model.database

import java.time.OffsetDateTime
import java.util.*

data class FCMTokenEntity(
    val id: UUID,
    val createdAt: OffsetDateTime,
    val value: String,
)
