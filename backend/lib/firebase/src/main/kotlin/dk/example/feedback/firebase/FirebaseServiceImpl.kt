package dk.example.feedback.firebase

import com.google.auth.oauth2.GoogleCredentials
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.UserRecord
import com.google.firebase.messaging.ApnsConfig
import com.google.firebase.messaging.Aps
import com.google.firebase.messaging.ApsAlert
import com.google.firebase.messaging.FirebaseMessaging
import com.google.firebase.messaging.Message
import dk.example.feedback.model.enumerations.Role
import java.io.FileInputStream
import java.io.FileNotFoundException
import java.io.InputStream
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service

@Service
class FirebaseServiceImpl : FirebaseService, FirebaseAdminService {

    private val logger = LoggerFactory.getLogger(FirebaseServiceImpl::class.java)

    override fun configure(configFilePath: String) {
        try {
            logger.info("Initializing FirebaseApp from config file path: {}", configFilePath)
            FileInputStream(configFilePath).use { firebaseServiceAccount ->
                initializeApp(firebaseServiceAccount)
            }
        } catch (e: FileNotFoundException) {
            logger.error("Firebase configuration file not found at path: ${configFilePath}", e)
        } catch (e: Exception) {
            logger.error("Failed to initialize FirebaseApp", e)
        }
    }

    private fun initializeApp(firebaseServiceAccount: InputStream) {
        if (FirebaseApp.getApps().isNotEmpty()) {
            logger.info("FirebaseApp already initialized, skipping reconfiguration.")
            return
        }

        val options = FirebaseOptions.builder()
            .setCredentials(GoogleCredentials.fromStream(firebaseServiceAccount))
            .build()
        FirebaseApp.initializeApp(options)
        logger.info("FirebaseApp initialized successfully.")
    }

    override fun pushFeedbackReceivedNotifications(feedbackReceivedNotifications: List<FeedbackReceivedNotification>) {
        FirebaseMessaging.getInstance().sendEach(
            feedbackReceivedNotifications.map {
                Message.builder()
                    .setApnsConfig(
                        ApnsConfig.builder()
                            .setAps(
                                Aps.builder()
                                    .setAlert(
                                        ApsAlert.builder()
                                            .setTitleLocalizationKey("notification_feedback_received_title")
                                            .setLocalizationKey("notification_feedback_received_body")
                                            .addAllLocalizationArgs(listOf(it.newFeedback.toString(), it.eventTitle))
                                            .build()
                                    )
                                    .build()
                            )
                            .build()
                    )
                    .putData("eventId", it.eventId.toString())
                    .putData("type", "FEEDBACK_RECEIVED")
                    .setToken(it.fcmToken)
                    .build()
            }
        )
    }

    override fun getUser(userId: String): FirebaseUser {

        val userRecord = FirebaseAuth.getInstance().getUser(userId)
        return FirebaseUser(
            displayName = userRecord.displayName,
            phoneNumber = userRecord.phoneNumber,
            email = userRecord.email,
            photoUrl = userRecord.photoUrl
        )
    }

    override fun deleteUser(userId: String) {
        FirebaseAuth.getInstance().deleteUserAsync(userId)
    }

    override fun updateUser(userId: String, email: String?, displayName: String?, phoneNumber: String?) {
        val updateRequest = UserRecord.UpdateRequest(userId).apply {
            if (email != null) {
                setEmail(email)
            }
            if (displayName != null) {
                setDisplayName(displayName)
            }
            if (phoneNumber != null) {
                setPhoneNumber(phoneNumber)
            }
        }
        FirebaseAuth.getInstance().updateUser(updateRequest)
    }

    override fun setRole(userId: String, requestedRole: Role?) {
        logger.info("Setting role ${requestedRole?.toString()} for user $userId")
        try {
            FirebaseAuth.getInstance()
                .setCustomUserClaims(userId, mapOf("role" to requestedRole?.toString()))
            logger.info("Role successfully set for user $userId")
        } catch (e: Exception) {
            logger.error("Failed to set role for user $userId", e)
            throw RuntimeException("Failed to set role", e)
        }
    }

    override fun createUserIfMissing(uid: String, email: String, displayName: String) {
        val createUserRequest = UserRecord.CreateRequest()
            .setUid(uid)
            .setEmail(email)
            .setDisplayName(displayName)

        try {
            logger.debug("Firebase: Creating user")
            FirebaseAuth.getInstance().createUser(createUserRequest)
        } catch (e: Exception) {
            logger.debug("Firebase: User already exists so will sign in")
        }
    }

    override fun createCustomToken(uid: String): String {
        return FirebaseAuth.getInstance().createCustomTokenAsync(uid).get()
    }
}
