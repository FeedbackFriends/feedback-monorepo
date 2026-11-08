package dk.example.feedback.firebase

import java.util.*

interface FirebaseService {
    fun configure(serviceAccountJsonB64: String)
    fun pushFeedbackReceivedNotifications(feedbackReceivedNotifications: List<FeedbackReceivedNotification>)
}

data class FeedbackReceivedNotification(
    val fcmToken: String,
    val newFeedback: Int,
    val eventTitle: String,
    val eventId: UUID,
)
