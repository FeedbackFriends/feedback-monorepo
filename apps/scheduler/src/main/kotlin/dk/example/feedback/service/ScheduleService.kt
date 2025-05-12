package dk.example.feedback.service

import dk.example.feedback.firebase.FeedbackReceivedNotification
import dk.example.feedback.firebase.FirebaseService
import dk.example.feedback.model.database.NewFeedbackNotificationEntity
import dk.example.feedback.persistence.repo.ActivityRepo
import dk.example.feedback.persistence.repo.EventRepo
import dk.example.feedback.persistence.repo.NewFeedbackNotificationRepo
import java.time.Duration
import org.slf4j.LoggerFactory
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Service

@Service
class ScheduleService(
    private val eventRepo: EventRepo,
    private val newFeedbackNotificationRepo: NewFeedbackNotificationRepo,
    private val firebaseService: FirebaseService,
    private val activityRepo: ActivityRepo,
) {

    private val logger = LoggerFactory.getLogger(ScheduleService::class.java)

    @Scheduled(cron = "0 0 0 * * *", zone = "Europe/Copenhagen")
    fun cleanUpPinsScheduler() {
        val sevenDays = Duration.ofDays(7)
        eventRepo.cleanUpPinCodesWithStopTimeOlderThan(duration = sevenDays)
    }

    @Scheduled(fixedRate = 5000)
    fun pushNotificationScheduler() {
        logger.info("Starting push notification scheduler run")

        val notificationsToPush = mutableListOf<FeedbackReceivedNotification>()
        val notificationsToRemove = mutableListOf<NewFeedbackNotificationEntity>()

        val allNotifications = newFeedbackNotificationRepo.listAll()
        logger.debug("Found ${allNotifications.size} new feedback notifications")

        allNotifications.forEach { notification ->
            logger.debug("Processing notification for eventId=${notification.event.id}, accountId=${notification.account.id}")
            val fcmTokens = notification.account.fcmTokens
            logger.debug("Found ${fcmTokens.size} FCM tokens")
            if (fcmTokens.isEmpty()) {
                logger.debug("No FCM tokens, scheduling for removal")
                notificationsToRemove += notification
            } else if (notification.shouldPush()) {
                logger.debug("Notification should be pushed, adding to queue")
                notificationsToRemove += notification
                fcmTokens.forEach { fcmToken ->
                    notificationsToPush += FeedbackReceivedNotification(
                        fcmToken = fcmToken,
                        newFeedback = notification.newFeedback,
                        eventTitle = notification.event.title,
                    )
                }
            } else {
                logger.debug("Notification will not be pushed at this time")
            }
        }

        logger.info("Pushing ${notificationsToPush.size} notifications to Firebase")
        logger.debug("Notification payloads: $notificationsToPush")
        if (notificationsToPush.isNotEmpty()) {
            firebaseService.pushFeedbackReceivedNotifications(feedbackReceivedNotifications = notificationsToPush)
            logger.info("Push operation to Firebase completed")
        }

        logger.info("Removing ${notificationsToRemove.size} notifications and persisting activity logs")
        notificationsToRemove.forEach { notification ->
            logger.debug("Removing notifications and persisting activity for eventId=${notification.event.id}, accountId=${notification.account.id}")
            newFeedbackNotificationRepo.removeAllForEvent(eventId = notification.event.id)
            activityRepo.persistActivity(
                eventId = notification.event.id,
                accountId = notification.account.id,
                newFeedback = notification.newFeedback
            )
        }

        logger.info("Push notification scheduler run completed")
    }
}
