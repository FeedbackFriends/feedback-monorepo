package dk.example.feedback.persistence.repo

import dk.example.feedback.model.database.NotificationFeedbackReceivedEntity
import dk.example.feedback.persistence.dao.EventDao
import dk.example.feedback.persistence.dao.NotificationFeedbackReceivedDao
import dk.example.feedback.persistence.table.NotificationFeedbackReceivedTable
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.*
import org.jetbrains.exposed.dao.id.EntityID
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional

@Component
@Transactional
class NotificationRepo {

    private val logger = LoggerFactory.getLogger(NotificationRepo::class.java)

    fun getFeedbackReceivedNotifications(): List<NotificationFeedbackReceivedEntity> {
        return NotificationFeedbackReceivedDao.all().toList().map { it.toModel() }
    }

    fun removeFeedbackReceivedNotification(eventIds: List<EntityID<UUID>>) {
        NotificationFeedbackReceivedDao.find {
            NotificationFeedbackReceivedTable.id inList eventIds
        }.forEach { it.delete() }
    }

    fun persistNotificationReceived(eventId: UUID) {
        val foundNotification = NotificationFeedbackReceivedDao.findById(eventId)
        if (foundNotification != null) {
            foundNotification.apply {
                this.lastFeedbackReceived = OffsetDateTime.now(ZoneOffset.UTC)
                this.newFeedback += 1
            }
            return
        }
        NotificationFeedbackReceivedDao.new(id = eventId) {
            this.newFeedback = 1
            this.event = EventDao.findById(eventId) ?: throw Exception("Could not find event id: ${eventId}")
            this.lastFeedbackReceived = OffsetDateTime.now(ZoneOffset.UTC)
        }
    }
}
