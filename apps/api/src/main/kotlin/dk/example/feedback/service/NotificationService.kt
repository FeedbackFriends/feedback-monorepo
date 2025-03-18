package dk.example.feedback.service

import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.service.firebase.FirebaseNotification
import dk.example.feedback.service.firebase.FirebaseService
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service


@Service
class NotificationService(
    private val firebaseService: FirebaseService
) {
    private val logger = LoggerFactory.getLogger(NotificationService::class.java)

    suspend fun notifyOrganizerThatFeedbackIsReceived(event: EventEntity, fcmToken: String) {
        logger.info("Notify organizer that feedback was submitted. With FCM token: ${fcmToken}")
        firebaseService.sendNotifications(
            firebaseNotifications = listOf(
                FirebaseNotification(
                    title = "title",
                    body = "body",
                    fcmToken = fcmToken,
                    data = mapOf(
                        "event_id" to event.id.toString(),
                        "event_title" to event.title,
                        "type" to NotificationType.FEEDBACK_RECEIVED.name
                    )
                )
            ),
        )
    }
}

enum class NotificationType {
    FEEDBACK_RECEIVED,
}
