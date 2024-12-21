package dk.example.feedback.controller

import ControllerPaths
import dk.example.feedback.helpers.AuthContextHelper
import dk.example.feedback.model.AccountDetails
import dk.example.feedback.model.dto.SessionDto
import dk.example.feedback.service.AccountService
import dk.example.feedback.service.Claim
import dk.example.feedback.service.FirebaseService
import dk.example.feedback.service.SessionService
import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.*
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt

@RestController
@RequestMapping(ControllerPaths.Account.ControllerUrl)
class AccountController(
    val accountService: AccountService,
    val firebaseService: FirebaseService,
    val sessionService: SessionService,
    val authContext: AuthContextHelper,
) {

    val logger = LoggerFactory.getLogger(AccountController::class.java)

    @DeleteMapping
    @PreAuthorize("hasAuthority('Manager' or 'Participant')")
    fun deleteAccount(
        @AuthenticationPrincipal principal: Jwt,
    ) {
        val accountId = principal.subject
        firebaseService.deleteUser(accountId)
        accountService.deleteAccount(accountId = accountId)
    }

    data class ModifyAccountInputDto(
        val accountDetails: AccountDetails,
        val requestedClaim: Claim
    )

    @PutMapping
    @PreAuthorize("hasAuthority('Manager' or 'Participant')")
    fun modifyAccount(
        @AuthenticationPrincipal principal: Jwt,
        @RequestBody input: ModifyAccountInputDto,
    ) {
        val accountId = principal.subject
        firebaseService.updateUser(
            userId = accountId,
            email = input.accountDetails.email,
            displayName = input.accountDetails.name,
            phoneNumber = input.accountDetails.phoneNumber
        )
        firebaseService.setUserClaims(userId = accountId, requestedClaim = input.requestedClaim)
    }

    @PostMapping("/find/{searchInput}")
    fun findAccount(@PathVariable searchInput: String): List<FoundAccount>{
        TODO()
//        return accountService.findAccount(searchInput).map {
//            FoundAccount(
//                id = it.id,
//                name = it.name!!,
//                email = it.email!!,
//                phoneNumber = it.phoneNumber
//            )
//        }
    }

    data class FoundAccount(
        val id: String,
        val name: String,
        val email: String,
        val phoneNumber: String?
    )

    data class SetFcmTokenInput(
        val fcmToken: String?
    )

    @PutMapping("/fcmToken")
    fun updateFcmToken(
        @RequestBody input: SetFcmTokenInput,
    ) {
        return accountService.updateAccountFcmToken(fcmToken = input.fcmToken)
    }

    data class CreateAccountInput(
        val requestedClaim: Claim?
    )

    /*
    Called after the user has logged in anynoymously or with a provider
    */
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
                accountService.createAnonymousAccountIfNotExist()
            }
            Claim.Manager, Claim.Participant -> {
                logger.info("Creating account for ${authContext.accountId} since requested custom claim is $input.requestedClaim")
                val firebaseUser = firebaseService.getUser(userId = authContext.accountId)
                accountService.upsertAccount(
                    accountId = authContext.accountId,
                    name = firebaseUser.displayName,
                    email = firebaseUser.email,
                    phoneNumber = firebaseUser.phoneNumber,
                )
            }
        }
        return sessionService.getSession()
    }
}

