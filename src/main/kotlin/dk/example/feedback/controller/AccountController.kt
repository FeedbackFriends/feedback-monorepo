package dk.example.feedback.controller

import ControllerPaths
import dk.example.feedback.constants.Roles
import dk.example.feedback.helpers.AuthContextHelper
import dk.example.feedback.model.dto.SessionDto
import dk.example.feedback.model.payloads.CreateAccountInput
import dk.example.feedback.model.payloads.ModifyAccountInput
import dk.example.feedback.model.payloads.SetFcmTokenInput
import dk.example.feedback.model.payloads.UpdateClaimInput
import dk.example.feedback.service.AccountService
import dk.example.feedback.service.Claim
import dk.example.feedback.service.FirebaseService
import dk.example.feedback.service.SessionService
import org.slf4j.LoggerFactory
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
@RequestMapping(ControllerPaths.Account.ControllerUrl)
class AccountController(
    val accountService: AccountService,
    val firebaseService: FirebaseService,
    val sessionService: SessionService,
    val authContext: AuthContextHelper,
) {

    private val logger = LoggerFactory.getLogger(AccountController::class.java)

    @DeleteMapping
    @PreAuthorize("hasAnyAuthority('${Roles.MANAGER}', '${Roles.PARTICIPANT}')")
    fun deleteAccount(
        @AuthenticationPrincipal principal: Jwt,
    ) {
        val accountId = principal.subject
        firebaseService.deleteUser(accountId)
        accountService.deleteAccount(accountId = accountId)
    }

    @PutMapping
    @PreAuthorize("hasAnyAuthority('${Roles.MANAGER}', '${Roles.PARTICIPANT}')")
    fun modifyAccount(
        @AuthenticationPrincipal principal: Jwt,
        @RequestBody input: ModifyAccountInput,
    ) {
        val accountId = principal.subject
        accountService.updateAccount(
            accountId = accountId,
            name = input.name,
            email = input.email,
            phoneNumber = input.phoneNumber
        )

    }

    @PutMapping("/claim")
    @PreAuthorize("hasAnyAuthority('${Roles.MANAGER}', '${Roles.PARTICIPANT}')")
    fun updateClaim(
        @AuthenticationPrincipal principal: Jwt,
        @RequestBody input: UpdateClaimInput,
    ) {
        val accountId = principal.subject
        return firebaseService.setUserClaims(userId = accountId, requestedClaim = input.claim)
    }

    @PutMapping("/fcmToken")
    fun updateFcmToken(
        @RequestBody input: SetFcmTokenInput,
    ) {
        return accountService.updateAccountFcmToken(fcmToken = input.fcmToken)
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping
    fun createAccount(
        @RequestBody input: CreateAccountInput,
    ): SessionDto {
        val authContext = authContext.getAuthContext()
        firebaseService.setUserClaims(userId = authContext.accountId, requestedClaim = input.requestedClaim)
        when (input.requestedClaim) {
            // Firebase user is anonymous if null
            null -> {
                logger.info("Creating anonymous account for ${authContext.accountId} since custom claim is null")
                accountService.createAnonymousAccount()
            }
            Claim.Manager, Claim.Participant -> {
                logger.info("Creating account for ${authContext.accountId} since requested custom claim is $input.requestedClaim")
                accountService.createAccount()
            }
        }
        return sessionService.getSession()
    }
}

