package dk.example.feedback.controller

import dk.example.feedback.dto.BootstrapDto
import dk.example.feedback.service.BootstrapService
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

@RestController
@Tag(name = "Bootstrap")
@RequestMapping("/bootstrap")
class BootstrapController(val bootstrapService: BootstrapService) {

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    fun getBootstrap(
        @AuthenticationPrincipal principal: Jwt
    ): BootstrapDto {
        return bootstrapService.getSession(jwt = principal)
    }

    @GetMapping("/bootstrap-update/{hash}")
    fun getBoostrapUpdate(
        @AuthenticationPrincipal principal: Jwt,
        @PathVariable("hash") feedbackSessionHash: UUID,
    ): BootstrapDto {
        return bootstrapService.getUpdatedSession(
            jwt = principal,
            feedbackSessionHash = feedbackSessionHash,
        ) ?: bootstrapService.getSession(jwt = principal)
    }
}
