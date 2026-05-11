package dk.example.feedback.controller

import dk.example.feedback.dto.BootstrapDto
import dk.example.feedback.service.BootstrapService
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.http.ResponseEntity
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
        return bootstrapService.getEvent(jwt = principal)
    }

    @GetMapping("/bootstrap-update/{hash}")
    @PreAuthorize("isAuthenticated()")
    @Operation(
        summary = "Get bootstrap update by hash",
        description = "Returns a full bootstrap payload when the provided hash is stale; returns 204 when unchanged.",
    )
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Bootstrap updated; full bootstrap payload returned.",
                content = [
                    Content(
                        mediaType = "application/json",
                        schema = Schema(implementation = BootstrapDto::class),
                    ),
                ],
            ),
            ApiResponse(
                responseCode = "204",
                description = "Bootstrap hash unchanged; no response body.",
                content = [Content()],
            ),
        ],
    )
    fun getBoostrapUpdate(
        @AuthenticationPrincipal principal: Jwt,
        @PathVariable("hash") bootstrapVersion: UUID,
    ): ResponseEntity<BootstrapDto> {
        val updated = bootstrapService.getUpdatedEvent(
            jwt = principal,
            bootstrapVersion = bootstrapVersion,
        ) ?: return ResponseEntity.noContent().build()
        return ResponseEntity.ok(updated)
    }
}
