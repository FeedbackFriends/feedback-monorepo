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

    companion object {
        private const val REQUEST_START_TIME_ATTRIBUTE = "loggingInterceptor.requestStartTime"
        const val HANDLED_EXCEPTION_ATTRIBUTE = "loggingInterceptor.handledException"
    }

    private val logger = LoggerFactory.getLogger(LoggingInterceptor::class.java)

    override fun preHandle(request: HttpServletRequest, response: HttpServletResponse, handler: Any): Boolean {
        request.setAttribute(REQUEST_START_TIME_ATTRIBUTE, System.currentTimeMillis())
        return true
    }

    @Throws(Exception::class)
    override fun afterCompletion(
        request: HttpServletRequest,
        response: HttpServletResponse,
        handler: Any,
        exception: Exception?
    ) {
        val startedAt = request.getAttribute(REQUEST_START_TIME_ATTRIBUTE) as? Long
        val durationMs = startedAt?.let { System.currentTimeMillis() - it }
        val handledException = request.getAttribute(HANDLED_EXCEPTION_ATTRIBUTE) as? Exception
        val requestException = exception ?: handledException

        if (requestException != null) {
            val auth = SecurityContextHolder.getContext().authentication
            val jwt = auth?.principal as? Jwt

            logger.error(
                "Request failed method={} path={} status={} durationMs={} accountId={} role={}",
                request.method,
                request.requestURI,
                response.status,
                durationMs ?: -1,
                jwt?.getAccountId() ?: "anonymous",
                jwt?.role() ?: "N/A",
                requestException
            )
        } else if (response.status >= 500) {
            logger.error(
                "Request completed with server error method={} path={} status={} durationMs={}",
                request.method,
                request.requestURI,
                response.status,
                durationMs ?: -1
            )
        } else if (response.status >= 400) {
            logger.warn(
                "Request completed with client error method={} path={} status={} durationMs={}",
                request.method,
                request.requestURI,
                response.status,
                durationMs ?: -1
            )
        } else {
            logger.info(
                "Request completed method={} path={} status={} durationMs={}",
                request.method,
                request.requestURI,
                response.status,
                durationMs ?: -1
            )
        }
    }
}
