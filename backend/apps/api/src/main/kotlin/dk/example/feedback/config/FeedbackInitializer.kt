package dk.example.feedback.config

import dk.example.feedback.firebase.FirebaseService
import org.slf4j.LoggerFactory
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.ApplicationListener
import org.springframework.context.annotation.Profile
import org.springframework.stereotype.Component

@Component
@Profile("!openapi")
class FeedbackInitializer(
    private val feedbackConfig: FeedbackConfig,
    private val firebaseService: FirebaseService,
) : ApplicationListener<ApplicationReadyEvent> {

    private val logger = LoggerFactory.getLogger(FeedbackInitializer::class.java)

    override fun onApplicationEvent(event: ApplicationReadyEvent) {
        if (feedbackConfig.firebaseServiceAccountJsonB64.isNotBlank()) {
            firebaseService.configure(serviceAccountJsonB64 = feedbackConfig.firebaseServiceAccountJsonB64)
        } else {
            logger.warn("Skipping Firebase initialization because FIREBASE_SERVICE_ACCOUNT_JSON_B64 was not provided.")
        }
    }
}
