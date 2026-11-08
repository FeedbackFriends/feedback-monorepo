package dk.example.feedback.config

import dk.example.feedback.model.error.ApiError
import dk.example.feedback.model.error.DomainCode
import jakarta.servlet.http.HttpServletRequest
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import java.time.OffsetDateTime
import java.util.Locale
import java.util.ResourceBundle

/** Safe customer copy is independent of diagnostic exception messages. */
object LocalizedApiErrors {
    private val supportedLanguages = listOf("da", "en")

    fun language(header: String?): String {
        if (header.isNullOrBlank()) return "da"
        val ranges = try {
            Locale.LanguageRange.parse(header)
        } catch (_: IllegalArgumentException) {
            return "da"
        }
        val excluded = ranges.filter { it.weight == 0.0 }.map { it.range }.toSet()
        for (range in ranges.filter { it.weight > 0.0 }) {
            val candidates = if (range.range == "*") supportedLanguages else {
                listOf(range.range.substringBefore('-')).filter { it in supportedLanguages }
            }
            for (candidate in candidates) {
                if (candidate !in excluded && (range.range != "*" || "*" !in excluded)) return candidate
            }
        }
        return "da"
    }

    fun response(exception: Exception, request: HttpServletRequest, status: HttpStatus, domainCode: DomainCode? = null): ResponseEntity<ApiError> {
        val language = language(request.getHeader(HttpHeaders.ACCEPT_LANGUAGE))
        val messages = ResourceBundle.getBundle("errors", Locale.forLanguageTag(language))
        val key = if (exception is dk.example.feedback.model.exceptions.InvalidTeamInviteException) "teamInviteNotFound" else domainCode?.name ?: when (status.value()) {
            400, 405, 415, 422 -> "validation"
            401 -> "authentication"
            403 -> "forbidden"
            404 -> "notFound"
            409 -> "conflict"
            429 -> "rateLimited"
            503 -> "serviceUnavailable"
            else -> "unexpected"
        }
        val error = ApiError(
            timestamp = OffsetDateTime.now(),
            message = exception.message ?: "An unexpected error occurred",
            domainCode = domainCode,
            exceptionType = exception.javaClass.simpleName,
            path = request.requestURI,
            userTitle = messages.getString("$key.title"),
            userMessage = messages.getString("$key.message"),
        )
        return ResponseEntity.status(status)
            .header(HttpHeaders.CONTENT_LANGUAGE, language)
            .varyBy(HttpHeaders.ACCEPT_LANGUAGE)
            .body(error)
    }
}
