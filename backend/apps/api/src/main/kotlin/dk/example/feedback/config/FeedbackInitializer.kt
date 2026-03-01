package dk.example.feedback.config

import dk.example.feedback.firebase.FirebaseService
import dk.example.feedback.persistence.repo.MockRepo
import org.slf4j.LoggerFactory
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.ApplicationListener
import org.springframework.stereotype.Component

@Component
class FeedbackInitializer(
    private val mockRepo: MockRepo,
    private val feedbackConfig: FeedbackConfig,
    private val firebaseService: FirebaseService,
) : ApplicationListener<ApplicationReadyEvent> {

    private val logger = LoggerFactory.getLogger(FeedbackInitializer::class.java)

    override fun onApplicationEvent(event: ApplicationReadyEvent) {
        insertMockData()
        if (feedbackConfig.firebaseConfigPath.isNotBlank()) {
            firebaseService.configure(configFilePath = feedbackConfig.firebaseConfigPath)
        } else {
            logger.warn("Skipping Firebase initialization because no Firebase config path was provided.")
        }
    }

    private fun insertMockData() {
        try {
            mockRepo.insertMockData()
            logger.info("Mock data setup completed successfully.")
        } catch (e: Exception) {
            logger.error("Failed to insert mock data", e)
        }
    }
}
