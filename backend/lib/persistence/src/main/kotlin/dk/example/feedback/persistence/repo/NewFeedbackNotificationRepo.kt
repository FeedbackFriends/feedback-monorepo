package dk.example.feedback.persistence.repo

import dk.example.feedback.model.database.NewFeedbackNotificationEntity
import dk.example.feedback.persistence.dao.AccountDao
import dk.example.feedback.persistence.dao.EventDao
import dk.example.feedback.persistence.dao.NewFeedbackNotificationDao
import dk.example.feedback.persistence.table.NewFeedbackNotificationTable
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.*
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional

@Component
@Transactional
class NewFeedbackNotificationRepo {

    private val logger = LoggerFactory.getLogger(NewFeedbackNotificationRepo::class.java)

    fun listAll(): List<NewFeedbackNotificationEntity> {
        return NewFeedbackNotificationDao.all().toList().map { it.toModel() }
    }

    fun getAllForAccount(accountId: String): List<NewFeedbackNotificationEntity> {
        return NewFeedbackNotificationDao.find {
            NewFeedbackNotificationTable.account eq accountId
        }.map { it.toModel() }
    }

    fun removeAllForAccount(accountId: String) {
        NewFeedbackNotificationDao.find { NewFeedbackNotificationTable.account eq accountId }.forEach { it.delete() }
    }

    fun removeAllForEvent(eventId: UUID) {
        NewFeedbackNotificationDao.find { NewFeedbackNotificationTable.event eq eventId }.forEach { it.delete() }
    }

    fun persistNewFeedbackNotification(eventId: UUID, accountId: String) {
        logger.debug("Persisting new feedback notification for eventId: {} and accountId: {}", eventId, accountId)
        val foundNotification = NewFeedbackNotificationDao.findById(eventId)
        if (foundNotification != null) {
            logger.debug("Found existing notification for eventId: {}", eventId)
            foundNotification.apply {
                this.lastFeedbackAt = OffsetDateTime.now(ZoneOffset.UTC)
                this.newFeedback += 1
                this.account =
                    AccountDao.findById(accountId) ?: throw Exception("Could not find account id: ${accountId}")
            }
            return
        }
        logger.debug("Creating new notification for eventId: {}", eventId)
        NewFeedbackNotificationDao.new(id = eventId) {
            this.newFeedback = 1
            this.event = EventDao.findById(eventId) ?: throw Exception("Could not find event id: ${eventId}")
            this.lastFeedbackAt = OffsetDateTime.now(ZoneOffset.UTC)
            this.account = AccountDao.findById(accountId) ?: throw Exception("Could not find account id: ${accountId}")
        }
    }
}
