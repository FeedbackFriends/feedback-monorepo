package dk.example.feedback.persistence.repo

import dk.example.feedback.model.database.NewFeedbackEntity
import dk.example.feedback.persistence.dao.AccountDao
import dk.example.feedback.persistence.dao.EventDao
import dk.example.feedback.persistence.dao.NewFeedbackDao
import dk.example.feedback.persistence.table.NewFeedbackTable
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.*
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional

@Component
@Transactional
class NewFeedbackRepo {

    fun getFeedbackReceivedNotifications(): List<NewFeedbackEntity> {
        return NewFeedbackDao.all().toList().map { it.toModel() }
    }

    fun getNewFeedbackForAccount(accountId: String): List<NewFeedbackEntity> {
        return NewFeedbackDao.find {
            NewFeedbackTable.account eq accountId
        }.map { it.toModel() }
    }

    fun removeNewFeedbackForAccount(accountId: String) {
        NewFeedbackDao.find { NewFeedbackTable.account eq accountId }.forEach { it.delete() }
    }

    fun removeAllNewFeedback() {
        NewFeedbackDao.all().forEach { it.delete() }
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
