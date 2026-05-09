package dk.example.feedback.controller

import dk.example.feedback.dto.ActivityDto
import dk.example.feedback.dto.ParticipantSessionDto
import dk.example.feedback.model.enumerations.RoleConstants
import dk.example.feedback.payloads.SessionInput
import dk.example.feedback.service.SessionService
import io.swagger.v3.oas.annotations.tags.Tag
import java.util.*
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@Tag(name = "Sessions")
@RequestMapping("/session")
class SessionController(
    val sessionService: SessionService,
) {

    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}')")
    @PostMapping
    fun createSession(@RequestBody sessionInput: SessionInput, @AuthenticationPrincipal principal: Jwt): ActivityDto {
        return sessionService.createSession(sessionInput = sessionInput, jwt = principal)
    }

    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}')")
    @PutMapping("/{sessionId}")
    fun updateSession(
        @RequestBody sessionInput: SessionInput,
        @PathVariable sessionId: UUID,
        @AuthenticationPrincipal principal: Jwt
    ): ActivityDto {
        return sessionService.updateSession(sessionInput = sessionInput, sessionId = sessionId, jwt = principal)
    }

    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}')")
    @DeleteMapping("/{sessionId}")
    fun deleteSession(@PathVariable sessionId: UUID, @AuthenticationPrincipal principal: Jwt) {
        return sessionService.deleteSession(sessionId = sessionId, jwt = principal)
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("join/{pinCode}")
    fun joinSession(@PathVariable pinCode: String, @AuthenticationPrincipal principal: Jwt): ParticipantSessionDto {
        return sessionService.joinSession(pinCode = pinCode, jwt = principal)
    }

    @PutMapping("mark-as-seen/{sessionId}")
    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}')")
    fun markSessionAsSeen(@PathVariable sessionId: UUID, @AuthenticationPrincipal principal: Jwt) {
        return sessionService.markSessionAsSeen(sessionId = sessionId, jwt = principal)
    }
}
