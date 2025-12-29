package dk.example.feedback.controller

import dk.example.feedback.dto.SessionDto
import dk.example.feedback.service.SessionService
import io.swagger.v3.oas.annotations.tags.Tag
import java.util.*
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
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

    @GetMapping("/session-update/{feedbackSessionHash}")
    fun getUpdatedSession(
        @AuthenticationPrincipal principal: Jwt,
        @PathVariable feedbackSessionHash: UUID,
    ): UpdatedSessionResponse {
        return UpdatedSessionResponse(
            session = sessionService.getUpdatedSession(
                jwt = principal,
                feedbackSessionHash = feedbackSessionHash
            )
        )
    }

    data class UpdatedSessionResponse(
        val session: SessionDto?
    )
}

