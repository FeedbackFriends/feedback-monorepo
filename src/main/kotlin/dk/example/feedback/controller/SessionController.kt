package dk.example.feedback.controller

import dk.example.feedback.model.dto.SessionDto
import dk.example.feedback.service.SessionService
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping(ControllerPaths.Session)
class SessionController(val sessionService: SessionService) {

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    fun getSession(
    ): SessionDto {
        return sessionService.getSession()
    }
}
