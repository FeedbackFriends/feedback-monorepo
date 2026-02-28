package dk.example.feedback.service

import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.helpers.verifyAccountHasId
import dk.example.feedback.model.database.AccountEntity
import dk.example.feedback.model.enumerations.Role
import dk.example.feedback.model.helpers.normalizedEmail
import dk.example.feedback.persistence.repo.AccountRepo
import dk.example.feedback.persistence.repo.EventRepo
import org.slf4j.LoggerFactory
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service

@Service
class AccountService(
    val accountRepo: AccountRepo,
    private val eventRepo: EventRepo,
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
                )
            }

            Role.Manager, Role.Participant -> {
                val accountId = jwt.getAccountId()
                val normalizedEmail = email.normalizedEmail()
                accountRepo.createOrGetAccount(
                    accountId = accountId,
                    name = name,
                    email = normalizedEmail,
                    phoneNumber = phoneNumber,
                )
                if (normalizedEmail != null) {
                    eventRepo.joinInvitedEventsForEmail(accountId = accountId, email = normalizedEmail)
                }
            }
        }
        if (fcmToken != null) {
            accountRepo.upsertFcmToken(accountId = jwt.getAccountId(), fcmToken = fcmToken)
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
        val normalizedEmail = email.normalizedEmail()
        jwt.verifyAccountHasId(accountId)
        accountRepo.updateAccount(accountId = accountId, name = name, email = normalizedEmail, phoneNumber = phoneNumber)
        if (normalizedEmail != null) {
            eventRepo.joinInvitedEventsForEmail(accountId = accountId, email = normalizedEmail)
        }
    }

    fun linkFCMTokenToAccount(fcmToken: String, jwt: Jwt) {
        accountRepo.upsertFcmToken(accountId = jwt.getAccountId(), fcmToken = fcmToken)
    }

    fun unlinkFCMTokenFromAccount(fcmToken: String, jwt: Jwt) {
        jwt.verifyAccountHasId(jwt.getAccountId())
        accountRepo.getAccount(accountId = jwt.getAccountId()).fcmTokens
            .find { it == fcmToken }
            ?: throw IllegalArgumentException("FCM token $fcmToken not found for account ${jwt.getAccountId()}")
        accountRepo.deleteFcmToken(fcmToken = fcmToken)
    }

    fun deleteAccount(accountId: String, jwt: Jwt) {
        jwt.verifyAccountHasId(accountId)
        accountRepo.deleteAccount(accountId)
    }
}
