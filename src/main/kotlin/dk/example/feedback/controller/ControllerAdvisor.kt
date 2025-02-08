package dk.example.feedback.controller

import dk.example.feedback.model.error.ApiError
import dk.example.feedback.model.exceptions.DomainException
import jakarta.servlet.http.HttpServletRequest
import java.time.OffsetDateTime
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.ControllerAdvice
import org.springframework.web.bind.annotation.ExceptionHandler

@ControllerAdvice
class ControllerAdvisor {

    private val logger = LoggerFactory.getLogger(ControllerAdvisor::class.java)

    @ExceptionHandler(Exception::class)
    fun handleException(exception: Exception, request: HttpServletRequest): ResponseEntity<ApiError> {
        logger.error("Exception caught: ${exception.javaClass.simpleName}", exception)

        val domainCode = if (exception is DomainException) exception.domainCode else null

        val error = ApiError(
            timestamp = OffsetDateTime.now(),
            message = exception.message ?: "An unexpected error occurred",
            domainCode = domainCode,
            exceptionType = exception.javaClass.simpleName,
            path = request.requestURI,
        )

        return ResponseEntity(error, HttpStatus.INTERNAL_SERVER_ERROR)
    }
}
