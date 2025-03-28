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
) {

    private val logger = LoggerFactory.getLogger(AccountService::class.java)

    fun createAccount(
        requestedRole: Role?,
        name: String?,
        email: String?,
        phoneNumber: String?,
        jwt: Jwt,
        fcmToken: String?
    ) {
        when (requestedRole) {
            // Firebase user is anonymous if null
            null -> {
                val accountId = jwt.getAccountId()
                accountRepo.createOrGetAccount(
                    accountId = accountId,
                    name = null,
                    email = null,
                    phoneNumber = null,
                    fcmToken = fcmToken,
                )
            }

            Role.Manager, Role.Participant -> {
                val accountId = jwt.getAccountId()
                accountRepo.createOrGetAccount(
                    accountId = accountId,
                    name = name,
                    email = email,
                    phoneNumber = phoneNumber,
                    fcmToken = fcmToken,
                )
            }
        }
    }

    fun fetchAccount(accountId: String): AccountEntity? {
        return accountRepo.getAccount(accountId)
    }

    fun updateAccount(
        accountId: String,
        name: String?,
        email: String?,
        phoneNumber: String?,
        jwt: Jwt,
    ) {
        jwt.verifyAccountHasId(accountId)
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
