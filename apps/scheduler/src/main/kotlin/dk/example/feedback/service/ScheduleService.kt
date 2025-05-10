package dk.example.feedback.service

import dk.example.feedback.firebase.FeedbackReceivedNotification
import dk.example.feedback.firebase.FirebaseService
import dk.example.feedback.model.database.NewFeedbackNotificationEntity
import dk.example.feedback.persistence.repo.ActivityRepo
import dk.example.feedback.persistence.repo.EventRepo
import dk.example.feedback.persistence.repo.NewFeedbackNotificationRepo
import java.time.Duration
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Service

@Service
class ScheduleService(
    private val eventRepo: EventRepo,
    private val newFeedbackNotificationRepo: NewFeedbackNotificationRepo,
    private val firebaseService: FirebaseService,
    private val activityRepo: ActivityRepo,
) {

    @Scheduled(cron = "0 0 0 * * *", zone = "Europe/Copenhagen")
    fun cleanUpPinsScheduler() {
        val sevenDays = Duration.ofDays(7)
        eventRepo.cleanUpPinCodesWithStopTimeOlderThan(duration = sevenDays)
    }

    @Scheduled(fixedRate = 5000)
    fun pushNotificationScheduler() {
        val notificationsToPush = mutableListOf<FeedbackReceivedNotification>()
        val notificationsToRemove = mutableListOf<NewFeedbackNotificationEntity>()

        newFeedbackNotificationRepo.listAll().forEach { notification ->
            val fcmTokens = notification.account.fcmTokens
            if (fcmTokens.isEmpty()) {
                notificationsToRemove += notification
            } else if (notification.shouldPush()) {
                notificationsToRemove += notification
                fcmTokens.forEach { fcmToken ->
                    notificationsToPush += FeedbackReceivedNotification(
                        fcmToken = fcmToken,
                        newFeedback = notification.newFeedback,
                        eventTitle = notification.event.title,
                    )
                }
            }
        }
        if (notificationsToPush.isNotEmpty()) {
            firebaseService.pushFeedbackReceivedNotifications(feedbackReceivedNotifications = notificationsToPush)
        }
        for (notification in notificationsToRemove) {
            newFeedbackNotificationRepo.removeAllForEvent(eventId = notification.event.id)
            activityRepo.persistActivity(
                eventId = notification.event.id,
                accountId = notification.account.id,
                newFeedback = notification.newFeedback
            )
        }
    }
}
