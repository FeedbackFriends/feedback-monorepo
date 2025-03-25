package dk.example.feedback.service

import dk.example.feedback.dto.ActivityDto
import dk.example.feedback.dto.ActivityItem
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.persistence.repo.ActivityRepo
import dk.example.feedback.persistence.repo.EventRepo
import dk.example.feedback.persistence.repo.NewFeedbackNotificationRepo
import org.slf4j.LoggerFactory
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service

@Service
class ActivityService(
    val newFeedbackNotificationRepo: NewFeedbackNotificationRepo,
    val activityRepo: ActivityRepo,
    private val eventRepo: EventRepo,
) {

    private val logger = LoggerFactory.getLogger(ActivityService::class.java)


    fun markActivityAsSeen(jwt: Jwt) {
        val accountId = jwt.getAccountId()
        activityRepo.markAllAsSeen(accountId = accountId)
    }

    fun getActivity(accountId: String): ActivityDto {
        val items = activityRepo.listAllForAccount(accountId = accountId).map {
            ActivityItem(
                id = it.id,
                date = it.createdAt,
                eventTitle = it.event.title,
                eventId = it.event.id,
                newFeedbackCount = it.newFeedback,
                seenBefore = it.seenBefore
            )
        }
        return ActivityDto(
            items = items,
            unseenTotal = items.filter { !it.seenBefore }.size
        )
    }

    fun movePendingNotificationsToActivityAndReturn(accountId: String): List<EventEntity> {
        val pendingNewFeedbackNotifications = newFeedbackNotificationRepo.getAllForAccount(accountId = accountId)
        logger.info("Pending new feedback notifications: ${pendingNewFeedbackNotifications.size}")
        newFeedbackNotificationRepo.removeAllForAccount(accountId = accountId)
        logger.info("Removed all pending new feedback notifications for account: $accountId")
        for (feedback in pendingNewFeedbackNotifications) {
            logger.info("Persisting activity feed for event: ${feedback.event.id}")
            activityRepo.persistActivity(
                accountId = accountId,
                eventId = feedback.event.id,
                newFeedback = feedback.newFeedback,
            )
        }
        return pendingNewFeedbackNotifications.map { it.event }
    }
}
