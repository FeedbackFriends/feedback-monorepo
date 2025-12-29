package dk.example.feedback.config

import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.helpers.role
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.slf4j.LoggerFactory
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Component
import org.springframework.web.servlet.HandlerInterceptor

@Component
class LoggingInterceptor : HandlerInterceptor {

    private val logger = LoggerFactory.getLogger(LoggingInterceptor::class.java)

    override fun preHandle(request: HttpServletRequest, response: HttpServletResponse, handler: Any): Boolean {
        logger.info("Incoming request - Method: {}, Path: {}", request.method, request.requestURI)
        return true
    }

    @Throws(Exception::class)
    override fun afterCompletion(
        request: HttpServletRequest,
        response: HttpServletResponse,
        handler: Any,
        exception: Exception?
    ) {
        if (exception != null) {
            val auth = SecurityContextHolder.getContext().authentication
            val jwt = auth?.principal as? Jwt

            logger.error(
                "Exception occurred - Type: {}, Message: {}, Path: {}, Method: {}, Status: {}, Account ID: {}, Role: {}",
                exception.javaClass.simpleName,
                exception.message,
                request.requestURI,
                request.method,
                response.status,
                jwt?.getAccountId() ?: "Unknown",
                jwt?.role() ?: "N/A",
                exception
            )
        } else {
            logger.info(
                "Request completed - Path: {}, Method: {}, Status: {}",
                request.requestURI,
                request.method,
                response.status
            )
        }
    }
}
