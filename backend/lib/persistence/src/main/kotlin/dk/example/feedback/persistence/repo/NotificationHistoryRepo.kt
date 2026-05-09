package dk.example.feedback.persistence.repo

import dk.example.feedback.model.database.NotificationHistoryEntity
import dk.example.feedback.persistence.dao.AccountDao
import dk.example.feedback.persistence.dao.EventDao
import dk.example.feedback.persistence.dao.NotificationHistoryDao
import dk.example.feedback.persistence.table.NotificationHistoryTable
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.*
import org.jetbrains.exposed.sql.and
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional

@Component
@Transactional
class NotificationHistoryRepo {

    private val logger = LoggerFactory.getLogger(NotificationHistoryRepo::class.java)

    fun listAllNotificationHistoryForAccount(accountId: String): List<NotificationHistoryEntity> {
        return NotificationHistoryDao.find {
            NotificationHistoryTable.account eq accountId
        }.map {
            it.toModel()
        }
    }

    fun persistNotificationHistory(eventId: UUID, accountId: String, newFeedback: Int) {
        logger.info("Persisting notification history for event id: $eventId, account id: $accountId, new feedback: $newFeedback")
        NotificationHistoryDao.new {
            this.newFeedback = newFeedback
            this.event = EventDao.findById(eventId) ?: throw Exception("Could not find event id: ${eventId}")
            this.createdAt = OffsetDateTime.now(ZoneOffset.UTC)
            this.account = AccountDao.findById(accountId) ?: throw Exception("Could not find account id: ${accountId}")
            this.seenByManager = false
        }
    }

    fun markAllNotificationHistoryAsSeen(accountId: String) {
        NotificationHistoryDao.find { NotificationHistoryTable.account eq accountId }.forEach {
            it.seenByManager = true
        }
    }

    fun markNotificationHistoryAsSeen(accountId: String, eventId: UUID) {
        NotificationHistoryDao.find {
            (NotificationHistoryTable.account eq accountId) and (NotificationHistoryTable.event eq eventId)
        }.forEach {
            it.seenByManager = true
        }
    }
}
