package dk.example.feedback.model.exceptions

import dk.example.feedback.model.error.DomainCode
import java.util.*

abstract class DomainException(
    val domainCode: DomainCode,
    override val message: String
) : RuntimeException(message)

class FeedbackAlreadySubmittedException(eventId: UUID, accountId: String) : DomainException(
    DomainCode.FEEDBACK_ALREADY_SUBMITTED,
    "Feedback for event $eventId already submitted by user $accountId"
)

class EventAlreadyJoinedException(eventId: UUID, accountId: String) : DomainException(
    DomainCode.EVENT_ALREADY_JOINED,
    "User $accountId has already joined event $eventId"
)

class PinCodeNotFoundException(pinCode: String) : DomainException(
    DomainCode.PINCODE_NOT_FOUND,
    "Could not find any event with pincode $pinCode"
)
