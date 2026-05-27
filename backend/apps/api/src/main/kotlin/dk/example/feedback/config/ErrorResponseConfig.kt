package dk.example.feedback.config

import dk.example.feedback.model.error.DomainCode
import org.springframework.http.HttpStatus

object ErrorResponseConfig {
    val domainStatusMap: Map<DomainCode, HttpStatus> = mapOf(
        DomainCode.FORBIDDEN_RESOURCE_ACCESS to HttpStatus.FORBIDDEN,
        DomainCode.CANNOT_JOIN_OWN_EVENT to HttpStatus.FORBIDDEN,
        DomainCode.CANNOT_GIVE_FEEDBACK_TO_SELF to HttpStatus.FORBIDDEN,
        DomainCode.PINCODE_NOT_FOUND to HttpStatus.NOT_FOUND,
        DomainCode.FEEDBACK_ALREADY_SUBMITTED to HttpStatus.CONFLICT,
        DomainCode.EVENT_ALREADY_JOINED to HttpStatus.CONFLICT,
    )

    val globalDocumentedStatuses: List<HttpStatus> = (
        domainStatusMap.values.toSet() + setOf(HttpStatus.INTERNAL_SERVER_ERROR)
        ).sortedBy { it.value() }

    fun resolve(domainCode: DomainCode?): HttpStatus {
        return domainCode?.let { domainStatusMap[it] } ?: HttpStatus.INTERNAL_SERVER_ERROR
    }
}
