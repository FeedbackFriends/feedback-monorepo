package dk.example.feedback.controller

import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.payloads.SupportSubmissionInput
import dk.example.feedback.dto.SupportSubmissionReceipt
import dk.example.feedback.service.SupportSubmissionService
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@Tag(name = "Support")
@RequestMapping("/support")
class SupportSubmissionController(private val service: SupportSubmissionService) {
    @PreAuthorize("isAuthenticated()")
    @Operation(operationId = "submitSupportSubmission", summary = "Save product feedback or a bug report without affecting meeting feedback.")
    @PostMapping("/submissions")
    fun submit(@Valid @RequestBody input: SupportSubmissionInput, @AuthenticationPrincipal principal: Jwt): SupportSubmissionReceipt {
        return service.submit(input, principal.getAccountId())
    }
}
