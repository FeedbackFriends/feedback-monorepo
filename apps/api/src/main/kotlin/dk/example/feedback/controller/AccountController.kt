package dk.example.feedback.controller

import dk.example.feedback.dto.SessionDto
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.model.enumerations.RoleConstants
import dk.example.feedback.payloads.CreateAccountInput
import dk.example.feedback.payloads.ModifyAccountInput
import dk.example.feedback.payloads.SetFcmTokenInput
import dk.example.feedback.payloads.UpdateRoleInput
import dk.example.feedback.service.AccountService
import dk.example.feedback.service.SessionService
import dk.example.feedback.service.firebase.FirebaseService
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
    suspend fun createAccount(
        @RequestBody input: CreateAccountInput,
        @AuthenticationPrincipal principal: Jwt,
    ): SessionDto {
        firebaseService.setRole(userId = principal.getAccountId(), requestedRole = input.requestedRole)
        val user = firebaseService.getUser(principal.getAccountId())
        accountService.createAccount(
            requestedRole = input.requestedRole,
            name = user.displayName,
            email = user.email,
            phoneNumber = user.phoneNumber,
            jwt = principal
        )
        return sessionService.getSession(jwt = principal)
    }

    @PutMapping
    @PreAuthorize("hasAuthority('${RoleConstants.ORGANIZER}') or hasAuthority('${RoleConstants.PARTICIPANT}')")
    fun modifyAccount(
        @AuthenticationPrincipal principal: Jwt,
        @RequestBody input: ModifyAccountInput,
    ) {
        accountService.updateAccount(
            accountId = principal.getAccountId(),
            name = input.name,
            email = input.email,
            phoneNumber = input.phoneNumber,
            jwt = principal
        )
    }

    @PutMapping("/role")
    @PreAuthorize("hasAuthority('${RoleConstants.ORGANIZER}') or hasAuthority('${RoleConstants.PARTICIPANT}')")
    suspend fun updateRole(
        @AuthenticationPrincipal principal: Jwt,
        @RequestBody input: UpdateRoleInput,
    ) {
        firebaseService.setRole(userId = principal.getAccountId(), requestedRole = input.role)
    }


    @PutMapping("/test")
    @PreAuthorize("hasAuthority('${RoleConstants.ORGANIZER}') or hasAuthority('${RoleConstants.PARTICIPANT}')")
    suspend fun test(): String {
        return "It works"
    }

    @PutMapping("/fcmToken")
    @PreAuthorize("isAuthenticated()")
    fun updateFcmToken(
        @RequestBody input: SetFcmTokenInput,
        @AuthenticationPrincipal principal: Jwt,
    ) {
        accountService.updateAccountFcmToken(fcmToken = input.fcmToken, jwt = principal)
    }

    @DeleteMapping
    @PreAuthorize("hasAuthority('${RoleConstants.ORGANIZER}') or hasAuthority('${RoleConstants.PARTICIPANT}')")
    suspend fun deleteAccount(
        @AuthenticationPrincipal principal: Jwt,
    ) {
        val accountId = principal.getAccountId()
        firebaseService.deleteUser(accountId)
        accountService.deleteAccount(accountId = accountId, jwt = principal)
    }
}
