package dk.example.feedback

import com.google.auth.oauth2.GoogleCredentials
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import dk.example.feedback.config.FeedbackConfig
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.persistence.table.AccountTable
import dk.example.feedback.persistence.table.EventTable
import dk.example.feedback.persistence.table.PinCodeTable
import dk.example.feedback.persistence.table.QuestionTable
import java.io.FileInputStream
import java.io.FileNotFoundException
import java.time.OffsetDateTime
import java.time.ZoneOffset.UTC
import java.util.*
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.transactions.transaction
import org.slf4j.LoggerFactory
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.boot.runApplication
import org.springframework.context.ApplicationListener
import org.springframework.scheduling.annotation.EnableScheduling
import org.springframework.stereotype.Component

@SpringBootApplication
@EnableConfigurationProperties(FeedbackConfig::class)
@EnableScheduling
class FeedbackApplication

fun main(args: Array<String>) {
	runApplication<FeedbackApplication>(*args)
}

@Component
class FirebaseInitializer(
	private val feedbackConfig: FeedbackConfig
) : ApplicationListener<ApplicationReadyEvent> {

	private val logger = LoggerFactory.getLogger(FirebaseInitializer::class.java)

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

	private fun setupMockData() {
		try {
			// Ensure the database connection is established
			logger.info("Database connected successfully.")

			// Insert mock data in a transaction
			transaction {
				val testId = "testId"
				AccountTable.insert {
					it[id] = testId
					it[email] = "test@email.dk"
					it[name] = "Test Name"
					it[fcmToken] = null
					it[phoneNumber] = "12345678"
					it[ratingPrompted] = false
					it[createdAt] = OffsetDateTime.now(UTC)
					it[updatedAt] = OffsetDateTime.now(UTC)
				}

				for (i in 1..10) {
					val eventId = UUID.randomUUID()
					EventTable.insert {
						it[id] = EntityID(eventId, EventTable)
						it[title] = "Test Event"
						it[agenda] = null
						it[location] = "Test Location"
						it[durationInMinutes] = 30
						it[manager] = testId
						it[startTime] = OffsetDateTime.now(UTC)
						it[lastUpdated] = OffsetDateTime.now(UTC)
						it[dateCreated] = OffsetDateTime.now(UTC)
					}

					QuestionTable.insert {
						it[questionText] = "How was the event?"
						it[event] = eventId
						it[feedbackType] = FeedbackType.Emoji
						it[manager] = testId
						it[index] = 0
						it[lastUpdated] = OffsetDateTime.now(UTC)
						it[dateCreated] = OffsetDateTime.now(UTC)
					}

					QuestionTable.insert {
						it[questionText] = "How was the food?"
						it[event] = eventId
						it[feedbackType] = FeedbackType.Emoji
						it[manager] = testId
						it[index] = 1
						it[lastUpdated] = OffsetDateTime.now(UTC)
						it[dateCreated] = OffsetDateTime.now(UTC)
					}

					PinCodeTable.insert {
						it[pinCode] = "000${i}"
						it[event] = eventId
					}
				}

			}
			logger.info("Mock data setup completed successfully.")
		} catch (e: Exception) {
			logger.error("Failed to insert mock data", e)
		}
	}
}
