package dk.example.feedback.utils

import dk.example.feedback.firebase.FeedbackReceivedNotification
import dk.example.feedback.firebase.FirebaseService

data class TestIdentity(val displayName: String?, val email: String?, val phoneNumber: String?)

class FirebaseMockEngine(userId: String) : FirebaseService {
    private val users = mutableMapOf(userId to TestIdentity(null, null, null))
    override fun pushImprovementNotification(token: String, teamId: java.util.UUID, notificationId: java.util.UUID): Boolean = true
    override fun configure(serviceAccountJsonB64: String) {}
    override fun pushFeedbackReceivedNotifications(feedbackReceivedNotifications: List<FeedbackReceivedNotification>) {}
    fun getUser(userId: String): TestIdentity = users.getOrPut(userId) { TestIdentity(null, null, null) }
    fun updateUser(userId: String, email: String?, displayName: String?, phoneNumber: String?) {
        users[userId] = TestIdentity(displayName, email, phoneNumber)
    }
}
