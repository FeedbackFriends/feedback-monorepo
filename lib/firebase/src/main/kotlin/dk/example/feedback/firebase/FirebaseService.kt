package dk.example.feedback.firebase

import dk.example.feedback.model.enumerations.Role

interface FirebaseService {
    fun configure(configFilePath: String)
    suspend fun sendFeedbackReceivedNotifications(feedbackReceivedNotifications: List<FeedbackReceivedNotification>)
    suspend fun getUser(userId: String): FirebaseUser
    suspend fun deleteUser(userId: String)
    suspend fun updateUser(userId: String, email: String?, displayName: String?, phoneNumber: String?)
    suspend fun setRole(userId: String, requestedRole: Role?)
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
)
