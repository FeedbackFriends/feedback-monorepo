package dk.example.feedback

import com.google.auth.oauth2.GoogleCredentials
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import dk.example.feedback.config.FeedbackConfig
import org.apache.logging.log4j.LogManager
import org.apache.logging.log4j.Logger
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.boot.runApplication
import java.io.FileInputStream

@SpringBootApplication
@EnableConfigurationProperties(FeedbackConfig::class)
class FeedbackApplication

val logger: Logger = LogManager.getLogger(FeedbackApplication::class.java)

fun main(args: Array<String>) {
	runApplication<FeedbackApplication>(*args)

	val firebaseServiceAccount = FileInputStream("firebase_config.json")

	val options = FirebaseOptions.builder()
		.setCredentials(GoogleCredentials.fromStream(firebaseServiceAccount))
		.setProjectId("feedback2-a4dd9")
		.build()
	FirebaseApp.initializeApp(options)
	logger.info("FirebaseApp initialized")
}
