package dk.example.feedback.model.database

import java.time.OffsetDateTime
import java.util.*

data class PinCodeEntity(
    val id: UUID,
    val pinCode: String,
    val createdAt: OffsetDateTime,
    val updatedAt: OffsetDateTime,
)
