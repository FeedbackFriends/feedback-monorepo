package dk.example.feedback.service

import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.helpers.verifyAccountHasId
import dk.example.feedback.model.database.AccountEntity
import dk.example.feedback.model.enumerations.Role
import dk.example.feedback.persistence.repo.AccountRepo
import org.slf4j.LoggerFactory
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service

@Service
class AccountService(
    val accountRepo: AccountRepo,
    val firebaseService: FirebaseService,
) {

    private val logger = LoggerFactory.getLogger(AccountService::class.java)

    fun createAccount(requestedRole: Role?, name: String?, email: String?, phoneNumber: String?, jwt: Jwt) {
        when (requestedRole) {
            // Firebase user is anonymous if null
            null -> {
//                logger.info("Creating anonymous account for ${authContext.getAuthContext().accountId} since role is null")
                val accountId = jwt.getAccountId()
                accountRepo.createOrGetAccount(
                    accountId = accountId,
                    name = null,
                    email = null,
                    phoneNumber = null,
                )
            }

            Role.Organizer, Role.Participant -> {
//                logger.info("Creating account for ${authContext.getAuthContext().accountId} since requested role is $requestedRole")
                val accountId = jwt.getAccountId()
                accountRepo.createOrGetAccount(
                    accountId = accountId,
                    name = name,
                    email = email,
                    phoneNumber = phoneNumber,
                )
            }
        }
    }

    fun fetchAccount(accountId: String): AccountEntity? {
        return accountRepo.getAccount(accountId)
    }

    suspend fun updateAccount(
        accountId: String,
        name: String?,
        email: String?,
        phoneNumber: String?,
        jwt: Jwt,
    ) {
        jwt.verifyAccountHasId(accountId)
        firebaseService.updateUser(
            userId = accountId,
            email = email,
            displayName = name,
            phoneNumber = phoneNumber
        )
        accountRepo.updateAccount(accountId = accountId, name = name, email = email, phoneNumber = phoneNumber)
    }

    fun updateAccountFcmToken(fcmToken: String?, jwt: Jwt) {
        accountRepo.updateFcmToken(accountId = jwt.getAccountId(), fcmToken = fcmToken)
    }

    fun deleteAccount(accountId: String, jwt: Jwt) {
        jwt.verifyAccountHasId(accountId)
        accountRepo.deleteAccount(accountId)
    }
}
