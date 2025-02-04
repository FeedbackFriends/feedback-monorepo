package dk.example.feedback.service

import dk.example.feedback.helpers.AuthContextHelper
import dk.example.feedback.model.database.AccountEntity
import dk.example.feedback.persistence.repo.AccountRepo
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class AccountService(
    val accountRepo: AccountRepo,
    val context: AuthContextHelper,
    private val authContext: AuthContextHelper,
    val firebaseService: FirebaseService,
) {

    private val logger = LoggerFactory.getLogger(AccountService::class.java)

    fun fetchAccount(accountId: String): AccountEntity? {
        return accountRepo.getAccount(accountId)
    }

    fun createAnonymousAccount() {
        val accountId = context.getAuthContext().accountId
        accountRepo.createOrGetAccount(
            accountId = accountId,
            name = null,
            email = null,
            phoneNumber = null,
        )
    }

    fun updateAccount(
        accountId: String,
        name: String?,
        email: String?,
        phoneNumber: String?,
    ) {
        authContext.verifyLoggedInAccountHasId(id = accountId)
        accountRepo.updateAccount(accountId = accountId, name = name, email = email, phoneNumber = phoneNumber)
    }

    fun createAccount() {
        val accountId = context.getAuthContext().accountId
        authContext.verifyLoggedInAccountHasId(id = accountId)
        val firebaseUser = firebaseService.getUser(userId = accountId)
        accountRepo.createOrGetAccount(
            accountId = accountId,
            name = firebaseUser.displayName,
            email = firebaseUser.email,
            phoneNumber = firebaseUser.phoneNumber,
        )
    }

    fun deleteAccount(accountId: String) {
        authContext.verifyLoggedInAccountHasId(id = accountId)
        accountRepo.deleteAccount(accountId)
    }

    fun updateAccountFcmToken(fcmToken: String?) {
        accountRepo.updateFcmToken(accountId = context.getAuthContext().accountId, fcmToken = fcmToken)
    }
}
