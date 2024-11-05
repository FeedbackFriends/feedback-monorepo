package dk.example.feedback.service

import dk.example.feedback.logger
import dk.example.feedback.model.*
import dk.example.feedback.model.db_models.AccountEntity
import dk.example.feedback.persistence.repo.AccountRepo
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional


@Service
@Transactional
class AccountService(val accountRepo: AccountRepo) {

    fun getAllAccounts(): List<AccountEntity> {
        return accountRepo.getAll()
    }

    fun getAccount(accountId: String): AccountEntity? {
        return accountRepo.getAccountById(accountId)
    }

    fun createAnonymousAccountIfNotExist(
        accountId: String,
    ) {
        val accountExists = accountRepo.getAccountById(accountId) != null
        if (!accountExists) {
            logger.info("createAnonymousAccountIfNotExist: Creating anonymous account with id: $accountId")
            accountRepo.createAccount(
                accountId = accountId,
                name = null,
                email = null,
                phoneNumber = null,
            )
        }
    }

    fun upsertAccount(
        accountId: String,
        name: String?,
        email: String?,
        phoneNumber: String?,
    ) {
        val accountExists = accountRepo.getAccountById(accountId) != null
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

    fun updateAccountFcmToken(accountId: String, fcmToken: String?) {
        accountRepo.updateFcmToken(accountId = accountId, fcmToken = fcmToken)
    }

//    fun throwExceptionIfAccountExists(accountId: String) {
//        if (accountRepo.getAccountById(accountId) == null) {
//            throw Exception("User not found with id: $accountId")
//        }
//    }

//    fun updateRole(accountId: String, role: Role) {
//        accountRepo.updateRole(accountId, role)
//    }
}