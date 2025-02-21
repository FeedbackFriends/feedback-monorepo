package dk.example.feedback.service

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.UserRecord
import com.google.firebase.messaging.FirebaseMessaging
import com.google.firebase.messaging.Message
import com.google.firebase.messaging.Notification
import dk.example.feedback.helpers.await
import dk.example.feedback.model.enumerations.Role
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service

interface FirebaseService {
    suspend fun sendNotifications(messages: List<Message>)
    suspend fun getUser(userId: String): User
    suspend fun deleteUser(userId: String)
    suspend fun updateUser(userId: String, email: String?, displayName: String?, phoneNumber: String?)
    suspend fun setRole(userId: String, requestedRole: Role?)

    data class User(
        val displayName: String?,
        val phoneNumber: String?,
        val email: String?,
        val photoUrl: String?
    )

    data class Message(
        val title: String,
        val body: String,
        val fcmToken: String,
        val data: Map<String, String>
    )
}

@Service
class FirebaseServiceLive: FirebaseService {

    private val logger = LoggerFactory.getLogger(FirebaseServiceLive::class.java)

    override suspend fun sendNotifications(messages: List<FirebaseService.Message>) {
        FirebaseMessaging.getInstance().sendEachAsync(
            messages.map {
                Message.builder()
                    .setNotification(
                        Notification.builder()
                            .setTitle(it.title)
                            .setBody(it.body)
                            .build()
                    )
                    .putAllData(it.data)
                    .setToken(it.fcmToken)
                    .build()
            }
        ).await()
    }

    override suspend fun getUser(userId: String): FirebaseService.User {

        val userRecord = FirebaseAuth.getInstance().getUserAsync(userId).await()
        // if email is null (user is anonymous) then return null
        return FirebaseService.User(
            displayName = userRecord.displayName,
            phoneNumber = userRecord.phoneNumber,
            email = userRecord.email,
            photoUrl = userRecord.photoUrl
        )
    }

    override suspend fun deleteUser(userId: String) {
        FirebaseAuth.getInstance().deleteUserAsync(userId).await()
    }

    override suspend fun updateUser(userId: String, email: String?, displayName: String?, phoneNumber: String?) {
        FirebaseAuth.getInstance().updateUserAsync(
            UserRecord.UpdateRequest(userId)
                .takeIf { email != null }?.setEmail(email)
                .takeIf { displayName != null }?.setDisplayName(displayName)
                .takeIf { phoneNumber != null }?.setPhoneNumber(phoneNumber)
        ).await()
    }

    override suspend fun setRole(userId: String, requestedRole: Role?) {
        logger.info("Setting role ${requestedRole?.name} for user $userId")
        try {
            FirebaseAuth.getInstance()
                .setCustomUserClaimsAsync(userId, mapOf("role" to requestedRole?.toString()))
                .await()
            logger.info("Role successfully set for user $userId")
        } catch (e: Exception) {
            logger.error("Failed to set role for user $userId", e)
            throw RuntimeException("Failed to set role", e)
        }
    }
}

