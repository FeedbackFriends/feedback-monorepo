package dk.example.feedback.controller

import dk.example.feedback.model.error.ApiError
import org.springframework.http.HttpStatusCode
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.ControllerAdvice
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler
import java.time.OffsetDateTime

class FeedbackAlreadyGivenException: Exception("Feedback already given")

@ControllerAdvice
class ControllerAdvisor : ResponseEntityExceptionHandler() {

    @ExceptionHandler
    fun handleError(ex: Exception): ResponseEntity<Any> {

        val error = ApiError(
            timestamp = OffsetDateTime.now(),
            message = ex.message ?: "Internal server error",
            stackTrace = ex.stackTraceToString()
        )

        val code = if (ex is FeedbackAlreadyGivenException) {
            409
        } else {
            500
        }
        return ResponseEntity(error, HttpStatusCode.valueOf(code))
    }
}

