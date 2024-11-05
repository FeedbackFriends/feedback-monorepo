package dk.example.feedback.controller

import dk.example.feedback.helpers.getCustomClaim
import dk.example.feedback.model.dto.SessionDto
import dk.example.feedback.service.Claim
import dk.example.feedback.service.SessionService
import org.springframework.web.bind.annotation.*
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt

@RestController
@RequestMapping(ControllerPaths.Session)
class SessionController(val sessionService: SessionService) {

    @GetMapping
    fun getSession(
        @AuthenticationPrincipal principal: Jwt,
    ): SessionDto {
        val accountId = principal.subject
        return sessionService.getSession(accountId = accountId, claim = principal.getCustomClaim())
    }
}