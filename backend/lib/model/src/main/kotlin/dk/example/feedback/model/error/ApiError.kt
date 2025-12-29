package dk.example.feedback.model.error

import java.time.OffsetDateTime

data class ApiError(
    val timestamp: OffsetDateTime,
    val message: String,
    val domainCode: DomainCode?,
    val exceptionType: String,
    val path: String,
)

enum class DomainCode {
    FEEDBACK_ALREADY_SUBMITTED,
    EVENT_ALREADY_JOINED,
    CANNOT_JOIN_OWN_EVENT,
    CANNOT_GIVE_FEEDBACK_TO_SELF,
    PINCODE_NOT_FOUND,
}
