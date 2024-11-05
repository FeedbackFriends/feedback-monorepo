package dk.example.feedback.controller

import ControllerPaths
import dk.example.feedback.helpers.getCustomClaim
import dk.example.feedback.logger
import dk.example.feedback.model.AccountDetails
import dk.example.feedback.model.dto.SessionDto
import dk.example.feedback.service.AccountService
import dk.example.feedback.service.Claim
import dk.example.feedback.service.FirebaseService
import dk.example.feedback.service.SessionService
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
) {

    @GetMapping("/TestReadClaim")
    @PreAuthorize("hasAuthority('Manager')")
    fun testReadClaim(
        @AuthenticationPrincipal principal: Jwt
    ): String {
        val claim = principal.getCustomClaim()
        return "Success, had claims: $claim"
    }

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
        @AuthenticationPrincipal principal: Jwt,
        @RequestBody input: SetFcmTokenInput,
    ) {
        val accountId = principal.subject
        return accountService.updateAccountFcmToken(accountId = accountId, fcmToken = input.fcmToken)
    }

    /*
    Called when App opened for the first time after Firebase setup anunymous account
    */
    @PostMapping("/setup-anonymous-account")
    fun createAnonymousAccount(
        @AuthenticationPrincipal principal: Jwt,
    ): SessionDto {
        val accountId = principal.subject
        logger.info("Creating anonymous account for $accountId if custom claim is null")
        // Firebase user is anonymous if null
        if (principal.getCustomClaim() == null) {
            logger.info("Creating anonymous account for $accountId since custom claim is null")
            accountService.createAnonymousAccountIfNotExist(
                accountId = accountId
            )
        }
        logger.info("Will now get session")
        return sessionService.getSession(accountId = accountId, claim = principal.getCustomClaim())
    }

    /*
     Called after the user has logged in anynoymously or with a provider
     */

    data class CreateAccountInput(
        val requestedClaim: Claim?
    )

    @PostMapping
    fun createAccount(
        @AuthenticationPrincipal principal: Jwt,
        @RequestBody input: CreateAccountInput,
    ): SessionDto {
        val accountId = principal.subject
        firebaseService.setUserClaims(userId = accountId, requestedClaim = input.requestedClaim)
        // Firebase user is anonymous if null
        when (input.requestedClaim) {
            null -> {
                logger.info("Creating anonymous account for $accountId since custom claim is null")
                accountService.createAnonymousAccountIfNotExist(
                    accountId = accountId
                )
            }
            Claim.Manager, Claim.Participant -> {
                logger.info("Creating account for $accountId since requested custom claim is $input.requestedClaim")
                val firebaseUser = firebaseService.getUser(userId = accountId)
                accountService.upsertAccount(
                    accountId = accountId,
                    name = firebaseUser.displayName,
                    email = firebaseUser.email,
                    phoneNumber = firebaseUser.phoneNumber,
                )
            }
        }
        return sessionService.getSession(accountId = accountId, claim = input.requestedClaim)
    }
}

