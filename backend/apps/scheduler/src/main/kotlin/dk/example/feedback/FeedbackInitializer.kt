package dk.example.feedback

import dk.example.feedback.firebase.FirebaseService
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.ApplicationListener
import org.springframework.stereotype.Component

@Component
class FeedbackInitializer(
    private val feedbackConfig: FeedbackConfig,
    private val firebaseService: FirebaseService,
) : ApplicationListener<ApplicationReadyEvent> {
    override fun onApplicationEvent(event: ApplicationReadyEvent) {
        if (feedbackConfig.firebaseServiceAccountJsonB64.isNotBlank()) {
            firebaseService.configure(serviceAccountJsonB64 = feedbackConfig.firebaseServiceAccountJsonB64)
        }
    }
}
