package dk.example.feedback.controller

import dk.example.feedback.dto.SessionDto
import dk.example.feedback.dto.UpdatedSessionDto
import dk.example.feedback.model.enumerations.RoleConstants
import dk.example.feedback.service.SessionService
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
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
        @AuthenticationPrincipal principal: Jwt
    ): SessionDto {
        return sessionService.getSession(jwt = principal)
    }

    @GetMapping("/real-time-updates")
    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}')")
    fun getUpdatedSession(
        @AuthenticationPrincipal principal: Jwt
    ): UpdatedSessionDto {
        return sessionService.getUpdatedSession(jwt = principal)
    }
}

