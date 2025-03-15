package dk.example.feedback.service.firebase

import dk.example.feedback.model.enumerations.Role

interface FirebaseService {
    fun configure(configFilePath: String)
    suspend fun sendNotifications(firebaseNotifications: List<FirebaseNotification>)
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

data class FirebaseNotification(
    val title: String,
    val body: String,
    val fcmToken: String,
    val data: Map<String, String>
)
