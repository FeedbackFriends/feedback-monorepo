package dk.example.feedback.model.exceptions

import dk.example.feedback.model.error.DomainCode

class ForbiddenResourceAccessException(message: String) : DomainException(
    DomainCode.FORBIDDEN_RESOURCE_ACCESS,
    message,
)

class CannotJoinOwnEventException(message: String = "Owner of event cannot join own event") : DomainException(
    DomainCode.CANNOT_JOIN_OWN_EVENT,
    message,
)

class CannotGiveFeedbackToSelfException(message: String = "Owner of event cannot give feedback") : DomainException(
    DomainCode.CANNOT_GIVE_FEEDBACK_TO_SELF,
    message,
)
