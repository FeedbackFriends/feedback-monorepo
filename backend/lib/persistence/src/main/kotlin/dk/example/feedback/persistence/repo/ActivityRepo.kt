package dk.example.feedback.persistence.repo

import dk.example.feedback.model.database.ActivityEntity
import dk.example.feedback.persistence.dao.AccountDao
import dk.example.feedback.persistence.dao.ActivityDao
import dk.example.feedback.persistence.dao.EventDao
import dk.example.feedback.persistence.table.ActivityTable
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.*
import org.jetbrains.exposed.sql.and
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional

@Component
@Transactional
class ActivityRepo {

    private val logger = LoggerFactory.getLogger(ActivityRepo::class.java)

    fun listAllForAccount(accountId: String): List<ActivityEntity> {
        return ActivityDao.find {
            ActivityTable.account eq accountId
        }.map {
            it.toModel()
        }
    }

    fun persistActivity(eventId: UUID, accountId: String, newFeedback: Int) {
        logger.info("Persisting activity feed for event id: $eventId, account id: $accountId, new feedback: $newFeedback")
        ActivityDao.new {
            this.newFeedback = newFeedback
            this.event = EventDao.findById(eventId) ?: throw Exception("Could not find event id: ${eventId}")
            this.createdAt = OffsetDateTime.now(ZoneOffset.UTC)
            this.account = AccountDao.findById(accountId) ?: throw Exception("Could not find account id: ${accountId}")
            this.seenByManager = false
        }
    }

    fun markAllAsSeen(accountId: String) {
        ActivityDao.find { ActivityTable.account eq accountId }.forEach {
            it.seenByManager = true
        }
    }

    fun markAsSeen(accountId: String, eventId: UUID) {
        ActivityDao.find {
            (ActivityTable.account eq accountId) and (ActivityTable.event eq eventId)
        }.forEach {
            it.seenByManager = true
        }
    }
}
