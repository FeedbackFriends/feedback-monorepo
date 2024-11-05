package dk.example.feedback.persistence.repo

import dk.example.feedback.logger
import dk.example.feedback.model.AccountDetails
import dk.example.feedback.model.db_models.AccountEntity
import dk.example.feedback.persistence.dao.AccountDao
import dk.example.feedback.persistence.table.AccountTable
import org.jetbrains.exposed.sql.*
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.time.OffsetDateTime
import java.time.ZoneOffset

@Component
@Transactional
class AccountRepo {

    fun createAccount(
        name: String?,
        email: String?,
        phoneNumber: String?,
        accountId: String,
    ): AccountEntity {
        AccountTable.insert {
            it[id] = accountId
            it[AccountTable.name] = name
            it[AccountTable.email] = email
            it[AccountTable.phoneNumber] = phoneNumber
            it[AccountTable.createdAt] = OffsetDateTime.now(ZoneOffset.UTC)
            it[AccountTable.updatedAt] = OffsetDateTime.now(ZoneOffset.UTC)
        }
        return getAccountById(accountId) ?: throw NoSuchElementException("User not found")
    }

    fun updateAccount(
        accountId: String,
        name: String?,
        email: String?,
        phoneNumber: String?,
    ): AccountEntity {
        val found = AccountDao.findById(accountId) ?: throw NoSuchElementException("User not found")
        found.apply {
            this.name = name
            this.email = email
            this.phoneNumber = phoneNumber
            this.updatedAt = OffsetDateTime.now(ZoneOffset.UTC)
        }
        return found.toModel()
    }

    fun delete(accountId: String) {
        AccountDao.findById(accountId)?.delete() ?: throw NoSuchElementException("User not found")
    }

    fun getAccountById(accountId: String): AccountEntity? {
        logger.info("Creating anonymous account with id: $accountId")
        return AccountDao.findById(accountId)?.toModel()
    }

    fun updateFcmToken(accountId: String, fcmToken: String?) {
        val found = AccountDao.findById(accountId) ?: throw NoSuchElementException("User not found")
        found.apply {
            this.fcmToken = fcmToken
        }
    }

//    fun updateRole(userId: String, role: Role) {
//        val found = AccountDao.findById(userId) ?: throw NoSuchElementException("User not found")
//        found.apply {
//            this.role = role
//        }
//    }

    fun findAccountsMatchingInput(input: String): List<AccountEntity> {
        TODO()
//        return AccountDao.find {
//            (AccountTable.email like "%$input%") or (AccountTable.name like "%$input%") or (AccountTable.phoneNumber like "%$input%")
//        }
//            .toList()
//            .map { it.toModel() }
    }

    fun getAll(): List<AccountEntity> {
        return AccountDao.all().toList().map { it.toModel() }
    }

    fun updateRatingPrompted(ratingPrompted: Boolean, accountId: String) {
        val found = AccountDao.findById(accountId) ?: throw NoSuchElementException("User not found")
        found.apply {
            this.ratingPrompted = ratingPrompted
        }
    }
}