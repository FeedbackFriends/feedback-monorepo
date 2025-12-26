package dk.example.feedback.config

import dk.example.feedback.firebase.FirebaseService
import dk.example.feedback.persistence.repo.MockRepo
import org.slf4j.LoggerFactory
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.ApplicationListener
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.stereotype.Component

@Component
@ConditionalOnProperty(
    name = ["feedback.features.bootstrap.enabled"],
    havingValue = "true",
    matchIfMissing = true,
)
class FeedbackInitializer(
    private val mockRepo: MockRepo,
    private val feedbackConfig: FeedbackConfig,
    private val firebaseService: FirebaseService,
) : ApplicationListener<ApplicationReadyEvent> {

    private val logger = LoggerFactory.getLogger(FeedbackInitializer::class.java)

    override fun onApplicationEvent(event: ApplicationReadyEvent) {
        setupMockData()
        firebaseService.configure(configFilePath = feedbackConfig.firebaseConfigPath)
    }

    private fun setupMockData() {
        try {
            mockRepo.insertMockData()
            logger.info("Mock data setup completed successfully.")
        } catch (e: Exception) {
            logger.error("Failed to insert mock data", e)
        }
    }
}
