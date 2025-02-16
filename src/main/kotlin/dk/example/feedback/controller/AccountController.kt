package dk.example.feedback.controller

import dk.example.feedback.constants.Roles
import dk.example.feedback.helpers.AuthContextHelper
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.model.dto.SessionDto
import dk.example.feedback.model.payloads.CreateAccountInput
import dk.example.feedback.model.payloads.ModifyAccountInput
import dk.example.feedback.model.payloads.SetFcmTokenInput
import dk.example.feedback.model.payloads.UpdateRoleInput
import dk.example.feedback.service.AccountService
import dk.example.feedback.service.FirebaseService
import dk.example.feedback.service.SessionService
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
    val authContext: AuthContextHelper,
) {

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    fun createAccount(
        @RequestBody input: CreateAccountInput,
    ): SessionDto {
        val authContext = authContext.getAuthContext()
        firebaseService.setRole(userId = authContext.accountId, requestedRole = input.requestedRole)
        accountService.createAccount(requestedRole = input.requestedRole)
        return sessionService.getSession()
    }

    @PutMapping
    @PreAuthorize("hasAnyAuthority('${Roles.ORGANIZER}', '${Roles.PARTICIPANT}')")
    fun modifyAccount(
        @AuthenticationPrincipal principal: Jwt,
        @RequestBody input: ModifyAccountInput,
    ) {
        accountService.updateAccount(
            accountId = principal.getAccountId(),
            name = input.name,
            email = input.email,
            phoneNumber = input.phoneNumber
        )
    }

    @PutMapping("/role")
    @PreAuthorize("hasAnyAuthority('${Roles.ORGANIZER}', '${Roles.PARTICIPANT}')")
    fun updateRole(
        @AuthenticationPrincipal principal: Jwt,
        @RequestBody input: UpdateRoleInput,
    ) {
        firebaseService.setRole(userId = principal.getAccountId(), requestedRole = input.role)
    }

    @PutMapping("/fcmToken")
    @PreAuthorize("isAuthenticated()")
    fun updateFcmToken(
        @RequestBody input: SetFcmTokenInput,
    ) {
        accountService.updateAccountFcmToken(fcmToken = input.fcmToken)
    }

    @DeleteMapping
    @PreAuthorize("hasAnyAuthority('${Roles.ORGANIZER}', '${Roles.PARTICIPANT}')")
    fun deleteAccount(
        @AuthenticationPrincipal principal: Jwt,
    ) {
        val accountId = principal.getAccountId()
        firebaseService.deleteUser(accountId)
        accountService.deleteAccount(accountId = accountId)
    }
}
