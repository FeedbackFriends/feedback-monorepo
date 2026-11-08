package dk.example.feedback.controller

import dk.example.feedback.config.LoggingInterceptor
import dk.example.feedback.config.ErrorResponseConfig
import dk.example.feedback.config.LocalizedApiErrors
import dk.example.feedback.model.error.ApiError
import dk.example.feedback.model.exceptions.DomainException
import jakarta.servlet.http.HttpServletRequest
import jakarta.validation.ConstraintViolationException
import org.springframework.http.HttpStatus
import org.springframework.security.access.AccessDeniedException
import org.springframework.security.core.AuthenticationException
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.ControllerAdvice
import org.springframework.web.bind.annotation.ExceptionHandler

@ControllerAdvice
class ControllerAdvisor() {

    @ExceptionHandler(Exception::class)
    fun handleException(exception: Exception, request: HttpServletRequest): ResponseEntity<ApiError> {
        request.setAttribute(LoggingInterceptor.HANDLED_EXCEPTION_ATTRIBUTE, exception)

        val domainCode = if (exception is DomainException) exception.domainCode else null
        val status = when (exception) {
            is org.springframework.web.server.ResponseStatusException -> HttpStatus.resolve(exception.statusCode.value()) ?: HttpStatus.INTERNAL_SERVER_ERROR
            is AccessDeniedException -> HttpStatus.FORBIDDEN
            is AuthenticationException -> HttpStatus.UNAUTHORIZED
            is dk.example.feedback.model.exceptions.InvalidSupportSubmissionException -> HttpStatus.BAD_REQUEST
            is dk.example.feedback.model.exceptions.SupportSubmissionConflictException -> HttpStatus.CONFLICT
            is dk.example.feedback.model.exceptions.TeamConflictException -> HttpStatus.CONFLICT
            is dk.example.feedback.model.exceptions.InvalidTeamInputException -> HttpStatus.BAD_REQUEST
            is dk.example.feedback.model.exceptions.TeamNotFoundException -> HttpStatus.NOT_FOUND
            is ConstraintViolationException -> HttpStatus.BAD_REQUEST
            is org.springframework.beans.TypeMismatchException -> HttpStatus.BAD_REQUEST
            is org.springframework.http.converter.HttpMessageNotReadableException -> HttpStatus.BAD_REQUEST
            is org.springframework.validation.BindException -> HttpStatus.BAD_REQUEST
            is org.springframework.web.bind.MissingServletRequestParameterException -> HttpStatus.BAD_REQUEST
            else -> ErrorResponseConfig.resolve(domainCode)
        }
        return LocalizedApiErrors.response(exception, request, status, domainCode)
    }
}
