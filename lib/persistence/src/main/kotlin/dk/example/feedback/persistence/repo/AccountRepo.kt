package dk.example.feedback.persistence.repo

import dk.example.feedback.model.database.AccountEntity
import dk.example.feedback.persistence.dao.AccountDao
import dk.example.feedback.persistence.table.AccountTable
import java.time.OffsetDateTime
import java.time.ZoneOffset
import org.jetbrains.exposed.sql.or
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional

@Component
@Transactional
class AccountRepo {

    private val logger = LoggerFactory.getLogger(AccountRepo::class.java)

    @Transactional
    fun createOrGetAccount(
        name: String?,
        email: String?,
        phoneNumber: String?,
        accountId: String,
        fcmToken: String?
    ): AccountEntity {
        val existingAccount = AccountDao.findById(accountId)
        if (existingAccount != null) {
            return existingAccount.toModel()
        }
        return AccountDao.new(id = accountId) {
            this.name = name
            this.email = email
            this.phoneNumber = phoneNumber
            this.createdAt = OffsetDateTime.now(ZoneOffset.UTC)
            this.updatedAt = OffsetDateTime.now(ZoneOffset.UTC)
            this.ratingPrompted = false
            this.fcmToken = fcmToken
        }.toModel()
    }

    fun updateAccount(
        accountId: String,
        name: String?,
        email: String?,
        phoneNumber: String?,
    ): AccountEntity {
        val found =
            AccountDao.findById(accountId) ?: throw NoSuchElementException("Account not found with id: $accountId")
        found.apply {
            this.name = name
            this.email = email
            this.phoneNumber = phoneNumber
            this.updatedAt = OffsetDateTime.now(ZoneOffset.UTC)
        }
        return found.toModel()
    }

    fun deleteAccount(accountId: String) {
        AccountDao.findById(accountId)?.delete()
            ?: throw NoSuchElementException("Account not found with id: $accountId")
    }

    fun getAccount(accountId: String): AccountEntity {
        logger.info("Get account with id: $accountId")
        return AccountDao.findById(accountId)?.toModel()
            ?: throw NoSuchElementException("Account not found with id: $accountId")
    }

    fun updateFcmToken(accountId: String, fcmToken: String?) {
        val found =
            AccountDao.findById(accountId) ?: throw NoSuchElementException("Account not found with id: $accountId")
        found.apply {
            this.fcmToken = fcmToken
        }
    }
    fun lookupAccount(input: String): List<AccountEntity> {
        return AccountDao.find {
            (AccountTable.email like "%$input%") or (AccountTable.name like "%$input%") or (AccountTable.phoneNumber like "%$input%")
        }.toList().map { it.toModel() }
    }

    fun markRatingAsPrompted(accountId: String) {
        val found =
            AccountDao.findById(accountId) ?: throw NoSuchElementException("Account not found with id: $accountId")
        found.apply {
            this.ratingPrompted = true
        }
    }
}
