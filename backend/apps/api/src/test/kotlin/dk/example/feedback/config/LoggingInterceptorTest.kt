package dk.example.feedback.config

import ch.qos.logback.classic.Level
import ch.qos.logback.classic.Logger
import ch.qos.logback.core.read.ListAppender
import dk.example.feedback.controller.ControllerAdvisor
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertSame
import kotlin.test.assertTrue
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Test
import org.slf4j.LoggerFactory
import org.springframework.mock.web.MockHttpServletRequest
import org.springframework.mock.web.MockHttpServletResponse
import org.springframework.security.core.context.SecurityContextHolder

class LoggingInterceptorTest {

    @AfterEach
    fun tearDown() {
        SecurityContextHolder.clearContext()
    }

    @Test
    fun `afterCompletion logs handled exceptions attached by controller advice`() {
        val interceptor = LoggingInterceptor()
        val request = MockHttpServletRequest("GET", "/events")
        val response = MockHttpServletResponse().apply { status = 500 }
        val handledException = IllegalStateException("boom")
        val logger = LoggerFactory.getLogger(LoggingInterceptor::class.java) as Logger
        val appender = ListAppender<ch.qos.logback.classic.spi.ILoggingEvent>()

        appender.start()
        logger.addAppender(appender)

        try {
            interceptor.preHandle(request, response, Any())
            request.setAttribute(LoggingInterceptor.HANDLED_EXCEPTION_ATTRIBUTE, handledException)

            interceptor.afterCompletion(request, response, Any(), null)

            val event = appender.list.single()
            assertEquals(Level.ERROR, event.level)
            assertTrue(event.formattedMessage.contains("Request failed method=GET path=/events status=500"))
            assertEquals("java.lang.IllegalStateException", event.throwableProxy.className)
            assertEquals("boom", event.throwableProxy.message)
        } finally {
            logger.detachAppender(appender)
        }
    }

    @Test
    fun `controller advice stores handled exception on request`() {
        val controllerAdvisor = ControllerAdvisor()
        val request = MockHttpServletRequest("GET", "/events")
        val handledException = IllegalArgumentException("bad request")

        val response = controllerAdvisor.handleException(handledException, request)

        assertEquals(500, response.statusCode.value())
        assertSame(handledException, request.getAttribute(LoggingInterceptor.HANDLED_EXCEPTION_ATTRIBUTE))
        assertIs<IllegalArgumentException>(request.getAttribute(LoggingInterceptor.HANDLED_EXCEPTION_ATTRIBUTE))
    }
}
