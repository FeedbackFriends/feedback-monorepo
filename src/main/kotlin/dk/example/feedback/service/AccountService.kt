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
    private val authContextHelper: AuthContextHelper
) {

    private val logger = LoggerFactory.getLogger(AccountService::class.java)

    fun fetchAccount(accountId: String): AccountEntity? {
        return accountRepo.getAccount(accountId)
    }

    fun createAnonymousAccountIfNotExist() {
        val accountId = context.getAuthContext().accountId
        accountRepo.createOrGetAccount(
            accountId = accountId,
            name = null,
            email = null,
            phoneNumber = null,
        )
    }

    fun upsertAccount(
        accountId: String,
        name: String?,
        email: String?,
        phoneNumber: String?,
    ) {
        val accountExists = accountRepo.accountExists(accountId)
        authContextHelper.verifyLoggedInAccountHasId(id = accountId)
        if (accountExists) {
            accountRepo.updateAccount(accountId = accountId, name = name, email = email, phoneNumber = phoneNumber)
        } else {
            accountRepo.createOrGetAccount(
                accountId = accountId,
                name = name,
                email = email,
                phoneNumber = phoneNumber,
            )
        }
    }

    fun deleteAccount(accountId: String) {
        authContextHelper.verifyLoggedInAccountHasId(id = accountId)
        accountRepo.deleteAccount(accountId)
    }

    fun updateAccountFcmToken(fcmToken: String?) {
        accountRepo.updateFcmToken(accountId = context.getAuthContext().accountId, fcmToken = fcmToken)
    }
}
