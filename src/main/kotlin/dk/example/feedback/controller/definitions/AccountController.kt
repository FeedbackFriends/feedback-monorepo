package dk.example.feedback.controller.definitions

import ControllerPaths
import dk.example.feedback.constants.Roles
import dk.example.feedback.model.dto.SessionDto
import dk.example.feedback.model.payloads.CreateAccountInput
import dk.example.feedback.model.payloads.ModifyAccountInput
import dk.example.feedback.model.payloads.SetFcmTokenInput
import dk.example.feedback.model.payloads.UpdateClaimInput
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping

@RequestMapping(ControllerPaths.Account.ControllerUrl)
interface AccountController {

    @DeleteMapping
    @PreAuthorize("hasAnyAuthority('${Roles.MANAGER}', '${Roles.PARTICIPANT}')")
    fun deleteAccount(@AuthenticationPrincipal principal: Jwt)

    @PutMapping
    @PreAuthorize("hasAnyAuthority('${Roles.MANAGER}', '${Roles.PARTICIPANT}')")
    fun modifyAccount(
        @AuthenticationPrincipal principal: Jwt,
        @RequestBody input: ModifyAccountInput,
    )

    @PutMapping("/claim")
    @PreAuthorize("hasAnyAuthority('${Roles.MANAGER}', '${Roles.PARTICIPANT}')")
    fun updateClaim(
        @AuthenticationPrincipal principal: Jwt,
        @RequestBody input: UpdateClaimInput,
    )

    @PutMapping("/fcmToken")
    fun updateFcmToken(
        @RequestBody input: SetFcmTokenInput,
    )

    @PreAuthorize("isAuthenticated()")
    @PostMapping
    fun createAccount(
        @RequestBody input: CreateAccountInput,
    ): SessionDto
}
