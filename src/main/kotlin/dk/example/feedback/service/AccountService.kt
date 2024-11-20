package dk.example.feedback.service

import dk.example.feedback.helpers.AuthContextHelper
import dk.example.feedback.model.db_models.AccountEntity
import dk.example.feedback.persistence.repo.AccountRepo
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional


@Service
@Transactional
class AccountService(
    val accountRepo: AccountRepo,
    val context: AuthContextHelper
) {

    val logger = LoggerFactory.getLogger(AccountService::class.java)

    fun fetchAccounts(): List<AccountEntity> {
        return accountRepo.getAll()
    }

    fun fetchAccount(accountId: String): AccountEntity? {
        return accountRepo.getAccount(accountId)
    }

    fun createAnonymousAccountIfNotExist() {
        val accountId = context.getAuthContext().accountId
        accountRepo.createAccount(
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
        val accountExists = accountRepo.getAccount(accountId) != null
        if (accountExists) {
            accountRepo.updateAccount(accountId = accountId, name = name, email = email, phoneNumber = phoneNumber)
        } else {
            accountRepo.createAccount(
                accountId = accountId,
                name = name,
                email = email,
                phoneNumber = phoneNumber,
            )
        }
    }

    fun deleteAccount(accountId: String) {
        accountRepo.delete(accountId)
    }

    fun findAccount(input: String): List<AccountEntity> {
        return accountRepo.findAccountsMatchingInput(input)
    }

    fun updateAccountFcmToken(fcmToken: String?) {
        accountRepo.updateFcmToken(accountId = context.getAuthContext().accountId, fcmToken = fcmToken)
    }
}