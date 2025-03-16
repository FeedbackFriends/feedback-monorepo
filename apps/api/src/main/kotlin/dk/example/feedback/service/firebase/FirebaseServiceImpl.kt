package dk.example.feedback.service.firebase

import com.google.auth.oauth2.GoogleCredentials
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.UserRecord
import com.google.firebase.messaging.FirebaseMessaging
import com.google.firebase.messaging.Message
import com.google.firebase.messaging.Notification
import dk.example.feedback.helpers.await
import dk.example.feedback.model.enumerations.Role
import java.io.FileInputStream
import java.io.FileNotFoundException
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service

@Service
class FirebaseServiceImpl : FirebaseService {

    private val logger = LoggerFactory.getLogger(FirebaseServiceImpl::class.java)

    override fun configure(configFilePath: String) {
        try {
            logger.info("Initializing FirebaseApp: Getting config file from path: ${configFilePath}")
            val firebaseServiceAccount = FileInputStream(configFilePath)
            val options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(firebaseServiceAccount))
                .setProjectId("feedback2-a4dd9") // TODO("Replace with your project ID")
                .build()
            FirebaseApp.initializeApp(options)
            logger.info("FirebaseApp initialized successfully.")
        } catch (e: FileNotFoundException) {
            logger.error("Firebase configuration file not found at path: ${configFilePath}", e)
        } catch (e: Exception) {
            logger.error("Failed to initialize FirebaseApp", e)
        }
    }

    override suspend fun sendNotifications(firebaseNotifications: List<FirebaseNotification>) {
        FirebaseMessaging.getInstance().sendEachAsync(
            firebaseNotifications.map {
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

    override suspend fun getUser(userId: String): FirebaseUser {

        val userRecord = FirebaseAuth.getInstance().getUserAsync(userId).await()
        // if email is null (user is anonymous) then return null
        return FirebaseUser(
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
        logger.info("Setting role ${requestedRole?.toString()} for user $userId")
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
