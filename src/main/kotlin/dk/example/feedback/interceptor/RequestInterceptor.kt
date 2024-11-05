package dk.example.feedback.interceptor

import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.stereotype.Component
import org.springframework.web.servlet.HandlerInterceptor

@Component
class RequestInterceptor : HandlerInterceptor {

    override fun preHandle(request: HttpServletRequest, response: HttpServletResponse, handler: Any): Boolean {
        request.headerNames.toList().forEach { headerName ->
            // println("Header: $headerName + ${request.getHeader(headerName)}")
        }
        return super.preHandle(request, response, handler)
    }
}
