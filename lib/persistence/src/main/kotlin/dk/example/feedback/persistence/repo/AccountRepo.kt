package dk.example.feedback.persistence.repo

import dk.example.feedback.model.database.AccountEntity
import dk.example.feedback.persistence.dao.AccountDao
import dk.example.feedback.persistence.dao.FCMTokenDao
import dk.example.feedback.persistence.table.FCMTokenTable
import java.time.OffsetDateTime
import java.time.ZoneOffset
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

    fun upsertFcmToken(accountId: String, fcmToken: String) {
        val existingFcmToken = FCMTokenDao.findById(fcmToken)
        val account = AccountDao.findById(accountId)
            ?: error("Account with id $accountId not found")

        if (existingFcmToken == null) {
            FCMTokenDao.new(fcmToken) {
                this.value = fcmToken
                this.account = account
            }
        } else {
            existingFcmToken.apply {
                this.account = account
            }
        }
    }

    fun deleteFcmToken(fcmToken: String) {
        FCMTokenDao.find { FCMTokenTable.value eq fcmToken }.forEach { it.delete() }
    }

    fun markRatingAsPrompted(accountId: String) {
        val found =
            AccountDao.findById(accountId) ?: throw NoSuchElementException("Account not found with id: $accountId")
        found.apply {
            this.ratingPrompted = true
        }
    }
}
