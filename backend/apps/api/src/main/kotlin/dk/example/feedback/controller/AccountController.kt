package dk.example.feedback.controller

import dk.example.feedback.dto.SessionDto
import dk.example.feedback.firebase.FirebaseService
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.model.enumerations.RoleConstants
import dk.example.feedback.payloads.CreateAccountInput
import dk.example.feedback.payloads.LinkFCMTokenToAccountInput
import dk.example.feedback.payloads.LogoutInput
import dk.example.feedback.payloads.ModifyAccountInput
import dk.example.feedback.payloads.UpdateRoleInput
import dk.example.feedback.service.AccountService
import dk.example.feedback.service.SessionService
import dk.example.feedback.model.helpers.normalizedEmail
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@Tag(name = "Account")
@RequestMapping("/account")
class AccountController(
    val accountService: AccountService,
    val firebaseService: FirebaseService,
    val sessionService: SessionService,
) {

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    fun createAccount(
        @RequestBody input: CreateAccountInput,
        @AuthenticationPrincipal principal: Jwt,
    ): SessionDto {
        firebaseService.setRole(userId = principal.getAccountId(), requestedRole = input.requestedRole)
        val user = firebaseService.getUser(principal.getAccountId())
        val normalizedEmail = user.email.normalizedEmail()
        normalizedEmail
            ?.takeIf { it != user.email }
            ?.let { normalizedEmail ->
                firebaseService.updateUser(
                    userId = principal.getAccountId(),
                    email = normalizedEmail,
                    displayName = user.displayName,
                    phoneNumber = user.phoneNumber
                )
            }
        accountService.createAccount(
            requestedRole = input.requestedRole,
            name = user.displayName,
            email = normalizedEmail,
            phoneNumber = user.phoneNumber,
            jwt = principal,
            fcmToken = input.fcmToken
        )
        return sessionService.getSession(jwt = principal)
    }

    @PutMapping
    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}') or hasAuthority('${RoleConstants.PARTICIPANT}')")
    fun modifyAccount(
        @AuthenticationPrincipal principal: Jwt,
        @RequestBody input: ModifyAccountInput,
    ) {
        val normalizedEmail = input.email.normalizedEmail()
        val existingEmail = accountService.fetchAccount(principal.getAccountId())?.email
        if (normalizedEmail != null) {
            firebaseService.updateUser(
                userId = principal.getAccountId(),
                email = normalizedEmail,
                displayName = input.name,
                phoneNumber = input.phoneNumber
            )
        }
        accountService.updateAccount(
            accountId = principal.getAccountId(),
            name = input.name,
            email = normalizedEmail ?: existingEmail,
            phoneNumber = input.phoneNumber,
            jwt = principal
        )
    }

    @PutMapping("/role")
    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}') or hasAuthority('${RoleConstants.PARTICIPANT}')")
    fun updateRole(
        @AuthenticationPrincipal principal: Jwt,
        @RequestBody input: UpdateRoleInput,
    ) {
        firebaseService.setRole(userId = principal.getAccountId(), requestedRole = input.role)
    }

    @PutMapping("/fcm-token")
    @PreAuthorize("isAuthenticated()")
    fun linkFCMTokenToAccount(
        @RequestBody input: LinkFCMTokenToAccountInput,
        @AuthenticationPrincipal principal: Jwt,
    ) {
        accountService.linkFCMTokenToAccount(fcmToken = input.fcmToken, jwt = principal)
    }

    @PostMapping("/logout")
    @PreAuthorize("isAuthenticated()")
    fun logout(
        @RequestBody input: LogoutInput,
        @AuthenticationPrincipal principal: Jwt,
    ) {
        accountService.unlinkFCMTokenFromAccount(fcmToken = input.fcmToken, jwt = principal)
    }

    @DeleteMapping
    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}') or hasAuthority('${RoleConstants.PARTICIPANT}')")
    fun deleteAccount(
        @AuthenticationPrincipal principal: Jwt,
    ) {
        val accountId = principal.getAccountId()
        firebaseService.deleteUser(accountId)
        accountService.deleteAccount(accountId = accountId, jwt = principal)
    }
}
