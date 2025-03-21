package dk.example.feedback.service

import dk.example.feedback.firebase.FeedbackReceivedNotification
import dk.example.feedback.firebase.FirebaseService
import dk.example.feedback.model.database.NotificationFeedbackReceivedEntity
import dk.example.feedback.persistence.repo.EventRepo
import dk.example.feedback.persistence.repo.NotificationRepo
import dk.example.feedback.persistence.table.EventTable
import java.time.Duration
import org.jetbrains.exposed.dao.id.EntityID
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Service

@Service
class ScheduleService(
    private val eventRepo: EventRepo,
    private val notificationRepo: NotificationRepo,
    private val firebaseService: FirebaseService,
) {

    @Scheduled(cron = "0 0 0 * * *", zone = "Europe/Copenhagen")
    fun cleanUpPinsScheduler() {
        val sevenDays = Duration.ofDays(7)
        eventRepo.cleanUpPinCodesWithStopTimeOlderThan(duration = sevenDays)
    }

    @Scheduled(fixedRate = 5000)
    suspend fun pushNotificationScheduler() = run {
        val notificationsToPush = mutableListOf<FeedbackReceivedNotification>()
        val notificationsToRemove = mutableListOf<NotificationFeedbackReceivedEntity>()

        notificationRepo.getFeedbackReceivedNotifications().forEach { notification ->
            val fcmToken = notification.account.fcmToken

            if (fcmToken == null) {
                notificationsToRemove += notification
            } else if (notification.shouldPush()) {
                notificationsToRemove += notification
                notificationsToPush += FeedbackReceivedNotification(
                    fcmToken = fcmToken,
                    newFeedback = notification.newFeedback,
                    eventTitle = notification.event.title,
                )
            }
        }
        if (notificationsToPush.isNotEmpty()) {
            firebaseService.sendFeedbackReceivedNotifications(feedbackReceivedNotifications = notificationsToPush)
        }
        if (notificationsToRemove.isNotEmpty()) {
            notificationRepo.removeFeedbackReceivedNotification(
                eventIds = notificationsToRemove.map { EntityID(it.event.id, EventTable) }
            )
        }
    }
}
