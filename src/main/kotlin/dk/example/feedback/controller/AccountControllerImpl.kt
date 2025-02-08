package dk.example.feedback.controller

import dk.example.feedback.controller.definitions.AccountController
import dk.example.feedback.helpers.AuthContextHelper
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.model.dto.SessionDto
import dk.example.feedback.model.payloads.CreateAccountInput
import dk.example.feedback.model.payloads.ModifyAccountInput
import dk.example.feedback.model.payloads.SetFcmTokenInput
import dk.example.feedback.model.payloads.UpdateClaimInput
import dk.example.feedback.service.AccountService
import dk.example.feedback.service.FirebaseService
import dk.example.feedback.service.SessionService
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.RestController

@RestController
class AccountControllerImpl(
    val accountService: AccountService,
    val firebaseService: FirebaseService,
    val sessionService: SessionService,
    val authContext: AuthContextHelper,
) : AccountController {

    override fun createAccount(
        input: CreateAccountInput,
    ): SessionDto {
        val authContext = authContext.getAuthContext()
        firebaseService.setUserClaims(userId = authContext.accountId, requestedClaim = input.requestedClaim)
        accountService.createAccount(requestedClaim = input.requestedClaim)
        return sessionService.getSession()
    }

    override fun modifyAccount(
        principal: Jwt,
        input: ModifyAccountInput,
    ) {
        accountService.updateAccount(
            accountId = principal.getAccountId(),
            name = input.name,
            email = input.email,
            phoneNumber = input.phoneNumber
        )
    }

    override fun updateClaim(
        principal: Jwt,
        input: UpdateClaimInput,
    ) {
        firebaseService.setUserClaims(userId = principal.getAccountId(), requestedClaim = input.claim)
    }

    override fun updateFcmToken(
        input: SetFcmTokenInput,
    ) {
        accountService.updateAccountFcmToken(fcmToken = input.fcmToken)
    }

    override fun deleteAccount(
        principal: Jwt,
    ) {
        val accountId = principal.getAccountId()
        firebaseService.deleteUser(accountId)
        accountService.deleteAccount(accountId = accountId)
    }
}
