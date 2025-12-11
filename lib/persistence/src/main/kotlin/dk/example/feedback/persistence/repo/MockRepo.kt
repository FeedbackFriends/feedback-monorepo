package dk.example.feedback.persistence.repo

import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.persistence.table.AccountTable
import dk.example.feedback.persistence.table.EventTable
import dk.example.feedback.persistence.table.PinCodeTable
import dk.example.feedback.persistence.table.QuestionTable
import java.time.OffsetDateTime
import java.time.ZoneOffset.UTC
import java.util.*
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional

@Component
@Transactional
class MockRepo {

    companion object {
        private val logger = LoggerFactory.getLogger(MockRepo::class.java)
    }

    fun insertMockData() {
        transaction {
            val testId = "mock_id"
            AccountTable.selectAll().where { AccountTable.id eq testId }.firstOrNull()?.let {
                logger.info("Mock data already exists.")
                return@transaction
            }
            AccountTable.insert {
                it[id] = EntityID(testId, AccountTable)
                it[email] = "test@email.dk"
                it[name] = "Test Name"
                it[phoneNumber] = "12345678"
                it[ratingPrompted] = false
                it[createdAt] = OffsetDateTime.now(UTC)
                it[updatedAt] = OffsetDateTime.now(UTC)
                it[feedbackSessionHash] = UUID.randomUUID()
            }

            for (i in 1..9) {
                val eventId = UUID.randomUUID()
                val startDateValue = if (i == 1) OffsetDateTime.of(
                    2000,
                    1,
                    1,
                    0,
                    0,
                    0,
                    0,
                    UTC
                ) else OffsetDateTime.of(
                    2100,
                    1,
                    1,
                    0,
                    0,
                    0,
                    0,
                    UTC
                )
                EventTable.insert {
                    it[id] = EntityID(eventId, EventTable)
                    it[title] = eventTitles[i - 1]
                    it[agenda] = null
                    it[location] = "Test Location"
                    it[durationInMinutes] = 30
                    it[manager] = EntityID(testId, AccountTable)
                    it[startDate] = startDateValue
                    it[lastUpdated] = OffsetDateTime.now(UTC)
                    it[dateCreated] = OffsetDateTime.now(UTC)
                    it[createdFromMailListener] = false
                }

                QuestionTable.insert {
                    it[questionText] = "I am generally happy with my work life balance."
                    it[event] = eventId
                    it[feedbackType] = FeedbackType.Opinion
                    it[manager] = EntityID(testId, AccountTable)
                    it[index] = 0
                    it[lastUpdated] = OffsetDateTime.now(UTC)
                    it[dateCreated] = OffsetDateTime.now(UTC)
                }

                QuestionTable.insert {
                    it[questionText] = "Tell me how I can improve?"
                    it[event] = eventId
                    it[feedbackType] = FeedbackType.Comment
                    it[manager] = EntityID(testId, AccountTable)
                    it[index] = 0
                    it[lastUpdated] = OffsetDateTime.now(UTC)
                    it[dateCreated] = OffsetDateTime.now(UTC)
                }

                QuestionTable.insert {
                    it[questionText] = "How was the food?"
                    it[event] = eventId
                    it[feedbackType] = FeedbackType.Emoji
                    it[manager] = EntityID(testId, AccountTable)
                    it[index] = 1
                    it[lastUpdated] = OffsetDateTime.now(UTC)
                    it[dateCreated] = OffsetDateTime.now(UTC)
                }

                QuestionTable.insert {
                    it[questionText] = "Do you want more feedbacksessions like this?"
                    it[event] = eventId
                    it[feedbackType] = FeedbackType.ThumpsUpThumpsDown
                    it[manager] = EntityID(testId, AccountTable)
                    it[index] = 1
                    it[lastUpdated] = OffsetDateTime.now(UTC)
                    it[dateCreated] = OffsetDateTime.now(UTC)
                }

                QuestionTable.insert {
                    it[questionText] = "How happy are you from 0-10?"
                    it[event] = eventId
                    it[feedbackType] = FeedbackType.ZeroToTen
                    it[manager] = EntityID(testId, AccountTable)
                    it[index] = 1
                    it[lastUpdated] = OffsetDateTime.now(UTC)
                    it[dateCreated] = OffsetDateTime.now(UTC)
                }

                PinCodeTable.insert {
                    it[code] = "000${i}"
                    it[event] = eventId
                }
            }
        }
    }

    val eventTitles = listOf(
        "Weekly Team Sync",
        "Project Kickoff: New Feature X",
        "Retrospective: Sprint Review",
        "Product Strategy Discussion",
        "Customer Feedback Review",
        "Marketing & Sales Alignment",
        "Tech Architecture Deep Dive",
        "Quarterly Business Update",
        "One-on-One Coaching Session"
    )
}
