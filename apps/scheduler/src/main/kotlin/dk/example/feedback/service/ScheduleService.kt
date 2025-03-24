package dk.example.feedback.service

import dk.example.feedback.firebase.FeedbackReceivedNotification
import dk.example.feedback.firebase.FirebaseService
import dk.example.feedback.model.database.NewFeedbackEntity
import dk.example.feedback.persistence.repo.EventRepo
import dk.example.feedback.persistence.repo.NewFeedbackRepo
import java.time.Duration
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Service

@Service
class ScheduleService(
    private val eventRepo: EventRepo,
    private val newFeedbackRepo: NewFeedbackRepo,
    private val firebaseService: FirebaseService,
) {

    @Scheduled(cron = "0 0 0 * * *", zone = "Europe/Copenhagen")
    fun cleanUpPinsScheduler() {
        val sevenDays = Duration.ofDays(7)
        eventRepo.cleanUpPinCodesWithStopTimeOlderThan(duration = sevenDays)
    }

    @Scheduled(fixedRate = 5000)
    fun pushNotificationScheduler() {
        val notificationsToPush = mutableListOf<FeedbackReceivedNotification>()
        val notificationsToRemove = mutableListOf<NewFeedbackEntity>()

        newFeedbackRepo.getFeedbackReceivedNotifications().forEach { notification ->
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
            firebaseService.pushFeedbackReceivedNotifications(feedbackReceivedNotifications = notificationsToPush)
        }
        if (notificationsToRemove.isNotEmpty()) {
            newFeedbackRepo.removeNewFeedback(
                eventIds = notificationsToRemove.map { it.event.id }
            )
        }
    }
}
