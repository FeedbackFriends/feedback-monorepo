package dk.example.feedback.controller

import dk.example.feedback.dto.BootstrapDto
import dk.example.feedback.service.SupabaseIdentityService
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.helpers.role
import dk.example.feedback.model.enumerations.RoleConstants
import dk.example.feedback.payloads.CreateAccountInput
import dk.example.feedback.payloads.LinkFCMTokenToAccountInput
import dk.example.feedback.payloads.LogoutInput
import dk.example.feedback.payloads.ModifyAccountInput
import dk.example.feedback.service.AccountService
import dk.example.feedback.service.BootstrapService
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
    val identities: SupabaseIdentityService,
    val bootstrapService: BootstrapService,
) {

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    fun createAccount(
        @RequestBody input: CreateAccountInput,
        @AuthenticationPrincipal principal: Jwt,
    ): BootstrapDto {
        val user = identities.user(principal)
        val normalizedEmail = if (user.anonymous || user.emailConfirmedAt.isNullOrBlank()) null else user.email.normalizedEmail()
        accountService.createAccount(
            requestedRole = principal.role(),
            name = user.metadata["full_name"] as? String,
            email = normalizedEmail,
            phoneNumber = null,
            jwt = principal,
            fcmToken = input.fcmToken
        )
        return bootstrapService.getEvent(jwt = principal)
    }

    @PutMapping
    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}')")
    fun modifyAccount(
        @AuthenticationPrincipal principal: Jwt,
        @RequestBody input: ModifyAccountInput,
    ) {
        val normalizedEmail = identities.verifiedEmail(principal)
        if (input.email.normalizedEmail()?.let { it != normalizedEmail } == true)
            throw dk.example.feedback.model.exceptions.ForbiddenResourceAccessException("Change email through verified authentication")
        accountService.updateAccount(
            accountId = principal.getAccountId(),
            name = input.name,
            email = normalizedEmail,
            phoneNumber = input.phoneNumber,
            jwt = principal
        )
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
    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}')")
    fun deleteAccount(
        @AuthenticationPrincipal principal: Jwt,
    ) {
        val accountId = principal.getAccountId()
        identities.deleteUser(principal)
        accountService.deleteAccount(accountId = accountId, jwt = principal)
    }
}
