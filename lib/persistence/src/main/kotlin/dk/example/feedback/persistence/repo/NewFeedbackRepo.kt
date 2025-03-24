package dk.example.feedback.persistence.repo

import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.model.database.NewFeedbackEntity
import dk.example.feedback.persistence.dao.AccountDao
import dk.example.feedback.persistence.dao.EventDao
import dk.example.feedback.persistence.dao.NewFeedbackDao
import dk.example.feedback.persistence.table.NewFeedbackTable
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.*
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional

@Component
@Transactional
class NewFeedbackRepo {

    private val logger = LoggerFactory.getLogger(NewFeedbackRepo::class.java)

    fun getFeedbackReceivedNotifications(): List<NewFeedbackEntity> {
        return NewFeedbackDao.all().toList().map { it.toModel() }
    }

    fun getNewFeedbackForAccount(accountId: String): List<EventEntity> {
        val newEvents = NewFeedbackDao.find {
            NewFeedbackTable.account eq accountId
        }.map { it.event.toModel() }
        return newEvents
    }

    fun removeNewFeedback(eventIds: List<UUID>) {
        NewFeedbackDao.find {
            NewFeedbackTable.id inList eventIds
        }.forEach { it.delete() }
    }

    fun persistNewFeedback(eventId: UUID, accountId: String) {
        val foundNotification = NewFeedbackDao.findById(eventId)
        if (foundNotification != null) {
            foundNotification.apply {
                this.lastFeedbackReceived = OffsetDateTime.now(ZoneOffset.UTC)
                this.newFeedback += 1
                this.account =
                    AccountDao.findById(accountId) ?: throw Exception("Could not find account id: ${accountId}")
            }
            return
        }
        NewFeedbackDao.new(id = eventId) {
            this.newFeedback = 1
            this.event = EventDao.findById(eventId) ?: throw Exception("Could not find event id: ${eventId}")
            this.lastFeedbackReceived = OffsetDateTime.now(ZoneOffset.UTC)
            this.account = AccountDao.findById(accountId) ?: throw Exception("Could not find account id: ${accountId}")
        }
    }
}
