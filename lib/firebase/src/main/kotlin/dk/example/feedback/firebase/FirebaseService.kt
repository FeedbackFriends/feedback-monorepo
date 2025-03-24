package dk.example.feedback.firebase

import dk.example.feedback.model.enumerations.Role

interface FirebaseService {
    fun configure(configFilePath: String)
    fun pushFeedbackReceivedNotifications(feedbackReceivedNotifications: List<FeedbackReceivedNotification>)
    fun getUser(userId: String): FirebaseUser
    fun deleteUser(userId: String)
    fun updateUser(userId: String, email: String?, displayName: String?, phoneNumber: String?)
    fun setRole(userId: String, requestedRole: Role?)
}

data class FirebaseUser(
    val displayName: String?,
    val phoneNumber: String?,
    val email: String?,
    val photoUrl: String?
)

data class FeedbackReceivedNotification(
    val fcmToken: String,
    val newFeedback: Int,
    val eventTitle: String,
)
