package dk.example.feedback.persistence.repo

import dk.example.feedback.model.database.AccountEntity
import dk.example.feedback.model.helpers.normalizedEmail
import dk.example.feedback.persistence.dao.AccountDao
import dk.example.feedback.persistence.dao.FCMTokenDao
import dk.example.feedback.persistence.table.AccountTable
import dk.example.feedback.persistence.table.AccountTable.email
import dk.example.feedback.persistence.table.FCMTokenTable
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.*
import org.jetbrains.exposed.sql.insertIgnore
import org.jetbrains.exposed.sql.update
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
        if (email != null) {
            ensureEmailAvailable(email = email, accountId = accountId)
        }
        return AccountDao.new(id = accountId) {
            this.name = name
            this.email = email
            this.phoneNumber = phoneNumber
            this.createdAt = OffsetDateTime.now(ZoneOffset.UTC)
            this.updatedAt = OffsetDateTime.now(ZoneOffset.UTC)
            this.ratingPrompted = false
            this.feedbackSessionHash = UUID.randomUUID()
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
        if (email != null) {
            ensureEmailAvailable(email = email, accountId = accountId)
        }
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

    fun getAccountFromEmail(emailInput: String): AccountEntity? {
        val normalizedEmail = emailInput.normalizedEmail() ?: return null
        logger.info("Trying to find account with email: $normalizedEmail")
        return AccountDao.find { email eq normalizedEmail }.firstOrNull()?.toModel()
    }

    fun upsertFcmToken(accountId: String, fcmToken: String) {
        val foundAccount = AccountDao.findById(accountId)
            ?: error("Account with id $accountId not found")

        FCMTokenTable.insertIgnore {
            it[id] = fcmToken
            it[account] = foundAccount.id
        }

        FCMTokenTable.update({ FCMTokenTable.id eq fcmToken }) {
            it[account] = foundAccount.id
        }
    }

    fun deleteFcmToken(fcmToken: String) {
        FCMTokenDao.find { FCMTokenTable.id eq fcmToken }.forEach { it.delete() }
    }

    fun markRatingAsPrompted(accountId: String) {
        val found =
            AccountDao.findById(accountId) ?: throw NoSuchElementException("Account not found with id: $accountId")
        found.apply {
            this.ratingPrompted = true
        }
    }

    fun updateSessionHash(accountId: String) {
        val found =
            AccountDao.findById(accountId) ?: throw NoSuchElementException("Account not found with id: $accountId")
        found.apply {
            this.feedbackSessionHash = UUID.randomUUID()
        }
    }

    private fun ensureEmailAvailable(email: String, accountId: String) {
        val existing = AccountDao.find { AccountTable.email eq email }.firstOrNull()
        if (existing != null && existing.id.value != accountId) {
            throw IllegalArgumentException("Email already in use")
        }
    }
}
