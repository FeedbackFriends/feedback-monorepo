package dk.example.feedback.model.error

import java.time.OffsetDateTime

data class ApiError(
    val timestamp: OffsetDateTime,
    val message: String,
    val stackTrace: String,
)
