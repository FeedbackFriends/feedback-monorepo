package dk.example.feedback.controller

import dk.example.feedback.dto.SessionDto
import dk.example.feedback.service.SessionService
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@Tag(name = "Session")
@RequestMapping("/session")
class SessionController(val sessionService: SessionService) {

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    fun getSession(
    ): SessionDto {
        return sessionService.getSession()
    }
}
