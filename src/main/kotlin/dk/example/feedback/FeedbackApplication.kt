package dk.example.feedback

import com.google.auth.oauth2.GoogleCredentials
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import dk.example.feedback.config.FeedbackConfig
import dk.example.feedback.persistence.table.EventTable
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.boot.runApplication
import java.io.FileInputStream
import java.io.FileNotFoundException
import javax.annotation.PostConstruct
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component

@SpringBootApplication
@EnableConfigurationProperties(FeedbackConfig::class)
class FeedbackApplication

fun main(args: Array<String>) {
	runApplication<FeedbackApplication>(*args)
}

@Component
class FirebaseInitializer(private val feedbackConfig: FeedbackConfig) {

	private val logger = LoggerFactory.getLogger(FirebaseInitializer::class.java)

	@PostConstruct
	fun initializeFirebaseApp() {
		try {
			logger.info("Initializing FirebaseApp: Getting config file from path: ${feedbackConfig.firebaseConfigPath}")
			val firebaseServiceAccount = FileInputStream(feedbackConfig.firebaseConfigPath)
			val options = FirebaseOptions.builder()
				.setCredentials(GoogleCredentials.fromStream(firebaseServiceAccount))
				.setProjectId("feedback2-a4dd9") // Replace with your project ID
				.build()
			FirebaseApp.initializeApp(options)
			logger.info("FirebaseApp initialized successfully.")
		} catch (e: FileNotFoundException) {
			logger.error("Firebase configuration file not found at path: ${feedbackConfig.firebaseConfigPath}", e)
		} catch (e: Exception) {
			logger.error("Failed to initialize FirebaseApp", e)
		}
	}
}