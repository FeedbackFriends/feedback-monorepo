package dk.example.feedback.firebase

import com.google.auth.oauth2.GoogleCredentials
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import com.google.firebase.messaging.ApnsConfig
import com.google.firebase.messaging.Aps
import com.google.firebase.messaging.ApsAlert
import com.google.firebase.messaging.FirebaseMessaging
import com.google.firebase.messaging.Message
import com.google.firebase.messaging.FirebaseMessagingException
import com.google.firebase.messaging.MessagingErrorCode
import java.io.ByteArrayInputStream
import java.io.InputStream
import java.util.Base64
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service

@Service
class FirebaseServiceImpl : FirebaseService {

    private val logger = LoggerFactory.getLogger(FirebaseServiceImpl::class.java)

    override fun pushImprovementNotification(token: String, teamId: java.util.UUID, notificationId: java.util.UUID): Boolean {
        try {
            FirebaseMessaging.getInstance().send(
            Message.builder()
                .setToken(token)
                .putData("type", "IMPROVEMENT_UPDATED")
                .putData("teamId", teamId.toString())
                .setApnsConfig(ApnsConfig.builder()
                    .putHeader("apns-collapse-id", notificationId.toString())
                    .setAps(Aps.builder().setAlert(ApsAlert.builder()
                        .setTitleLocalizationKey("notification_improvement_title")
                        .setLocalizationKey("notification_improvement_body").build()).build()).build())
                .build()
            )
        } catch (error: FirebaseMessagingException) {
            // The payload is fixed and valid; these failures belong to the stored recipient token.
            if (error.messagingErrorCode in setOf(MessagingErrorCode.UNREGISTERED, MessagingErrorCode.INVALID_ARGUMENT,
                    MessagingErrorCode.SENDER_ID_MISMATCH)) return false
            throw error
        }
        return true
    }

    override fun configure(serviceAccountJsonB64: String) {
        try {
            logger.info("Initializing FirebaseApp from FIREBASE_SERVICE_ACCOUNT_JSON_B64.")
            val decodedServiceAccount = Base64.getDecoder().decode(serviceAccountJsonB64)
            ByteArrayInputStream(decodedServiceAccount).use { firebaseServiceAccount ->
                initializeApp(firebaseServiceAccount)
            }
        } catch (e: IllegalArgumentException) {
            logger.error("Failed to decode FIREBASE_SERVICE_ACCOUNT_JSON_B64.", e)
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

}
