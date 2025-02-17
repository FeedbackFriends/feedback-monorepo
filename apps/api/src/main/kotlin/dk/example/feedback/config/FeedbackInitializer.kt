package dk.example.feedback.config

import com.google.auth.oauth2.GoogleCredentials
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import dk.example.feedback.persistence.repo.MockRepo
import java.io.FileInputStream
import java.io.FileNotFoundException
import org.slf4j.LoggerFactory
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.ApplicationListener
import org.springframework.stereotype.Component

@Component
class FeedbackInitializer(
    private val feedbackConfig: FeedbackConfig,
    private val mockRepo: MockRepo,
) : ApplicationListener<ApplicationReadyEvent> {

    private val logger = LoggerFactory.getLogger(FeedbackInitializer::class.java)

    override fun onApplicationEvent(event: ApplicationReadyEvent) {
        initializeFirebaseApp()
        setupMockData()
    }

    private fun initializeFirebaseApp() {
        try {
            logger.info("Initializing FirebaseApp: Getting config file from path: ${feedbackConfig.firebaseConfigPath}")
            val firebaseServiceAccount = FileInputStream(feedbackConfig.firebaseConfigPath)
            val options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(firebaseServiceAccount))
                .setProjectId("feedback2-a4dd9") // TODO("Replace with your project ID")
                .build()
            FirebaseApp.initializeApp(options)
            logger.info("FirebaseApp initialized successfully.")
        } catch (e: FileNotFoundException) {
            logger.error("Firebase configuration file not found at path: ${feedbackConfig.firebaseConfigPath}", e)
        } catch (e: Exception) {
            logger.error("Failed to initialize FirebaseApp", e)
        }
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

