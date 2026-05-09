package dk.example.feedback.service

import dk.example.feedback.dto.NotificationHistoryDto
import dk.example.feedback.dto.NotificationHistoryItem
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.persistence.repo.NewFeedbackNotificationRepo
import dk.example.feedback.persistence.repo.NotificationHistoryRepo
import org.slf4j.LoggerFactory
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service

@Service
class NotificationHistoryService(
    val newFeedbackNotificationRepo: NewFeedbackNotificationRepo,
    val notificationHistoryRepo: NotificationHistoryRepo,
) {

    private val logger = LoggerFactory.getLogger(NotificationHistoryService::class.java)


    fun markNotificationHistoryAsSeen(jwt: Jwt) {
        val accountId = jwt.getAccountId()
        notificationHistoryRepo.markAllNotificationHistoryAsSeen(accountId = accountId)
    }

    fun getNotificationHistory(accountId: String): NotificationHistoryDto {
        val items = notificationHistoryRepo.listAllNotificationHistoryForAccount(accountId = accountId).map {
            NotificationHistoryItem(
                id = it.id,
                date = it.createdAt,
                eventTitle = it.event.title,
                eventId = it.event.id,
                newFeedbackCount = it.newFeedback,
                seenByManager = it.seenByManager,
            )
        }
        return NotificationHistoryDto(
            items = items,
            unseenTotal = items.filter { !it.seenByManager }.size,
        )
    }

    fun movePendingNotificationsToNotificationHistoryAndReturn(accountId: String): List<EventEntity> {
        val pendingNewFeedbackNotifications = newFeedbackNotificationRepo.getAllForAccount(accountId = accountId)
        logger.info("Pending new feedback notifications: ${pendingNewFeedbackNotifications.size}")
        newFeedbackNotificationRepo.removeAllForAccount(accountId = accountId)
        logger.info("Removed all pending new feedback notifications for account: $accountId")
        for (feedback in pendingNewFeedbackNotifications) {
            logger.info("Persisting notification history for event: ${feedback.event.id}")
            notificationHistoryRepo.persistNotificationHistory(
                accountId = accountId,
                eventId = feedback.event.id,
                newFeedback = feedback.newFeedback,
            )
        }
        return pendingNewFeedbackNotifications.map { it.event }
    }
}
