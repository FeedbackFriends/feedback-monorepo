package dk.example.feedback.persistence.repo

import dk.example.feedback.model.enumerations.ActivityRunMode
import dk.example.feedback.model.enumerations.Emoji
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.enumerations.Opinion
import dk.example.feedback.model.enumerations.ThumbsUpThumpsDown
import dk.example.feedback.persistence.table.AccountTable
import dk.example.feedback.persistence.table.ActivityTable
import dk.example.feedback.persistence.table.EventTable
import dk.example.feedback.persistence.table.FeedbackTable
import dk.example.feedback.persistence.table.PinCodeTable
import dk.example.feedback.persistence.table.QuestionTable
import dk.example.feedback.persistence.table.SessionParticipantTable
import java.nio.charset.StandardCharsets
import java.time.OffsetDateTime
import java.time.ZoneOffset.UTC
import java.util.UUID
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.insertAndGetId
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

        private const val managerId = "mock_id"
        private const val totalSessions = 20
        private const val totalParticipants = 60
        private const val maxFeedbackRows = 200
    }

    fun insertMockData() {
        transaction {
            AccountTable.selectAll().where { AccountTable.id eq managerId }.firstOrNull()?.let {
                logger.info("Mock data already exists.")
                return@transaction
            }

            val seededAt = OffsetDateTime.of(2026, 1, 15, 9, 0, 0, 0, UTC)
            val managerEntityId = EntityID(managerId, AccountTable)

            insertManagerAccount(createdAt = seededAt)
            val participantIds = insertParticipantAccounts(createdAt = seededAt)

            var feedbackCount = 0
            for (sessionIndex in 0 until totalSessions) {
                val sessionSeed = sessionIndex + 1
                val activityId = deterministicUuid("activity-$sessionSeed")
                val sessionId = deterministicUuid("session-$sessionSeed")
                val scenario = Scenario.entries[sessionIndex % Scenario.entries.size]
                val startDate = sessionStart(seed = sessionSeed)
                val title = eventTitles[sessionIndex % eventTitles.size]

                insertActivity(
                    activityId = activityId,
                    title = "$title #$sessionSeed",
                    agenda = scenario.agenda,
                    manager = managerEntityId,
                    timestamp = seededAt,
                )

                insertSession(
                    sessionId = sessionId,
                    activityId = activityId,
                    title = "$title #$sessionSeed",
                    agenda = scenario.agenda,
                    location = locations[sessionIndex % locations.size],
                    durationInMinutes = durations[sessionIndex % durations.size],
                    manager = managerEntityId,
                    startDate = startDate,
                    timestamp = seededAt,
                )

                val questions = insertQuestions(
                    sessionId = sessionId,
                    activityId = activityId,
                    manager = managerEntityId,
                    timestamp = seededAt,
                )

                insertPinCode(sessionId = sessionId, sessionIndex = sessionIndex)

                val sessionParticipants = pickParticipantsForSession(
                    allParticipants = participantIds,
                    sessionIndex = sessionIndex,
                    count = 6,
                )

                val submittedParticipantsTarget = scenario.submittedParticipants.coerceAtMost(sessionParticipants.size)
                sessionParticipants.forEachIndexed { participantOrder, participantId ->
                    val shouldAttemptFeedback = participantOrder < submittedParticipantsTarget
                    var feedbackForParticipant = 0

                    if (shouldAttemptFeedback && feedbackCount < maxFeedbackRows) {
                        val questionsToAnswer = scenario.questionsPerSubmitter
                            .coerceAtMost(questions.size)
                            .coerceAtMost(maxFeedbackRows - feedbackCount)

                        for (questionOffset in 0 until questionsToAnswer) {
                            val questionId = questions[questionOffset]
                            val type = questionTypes[questionOffset]
                            insertFeedback(
                                sessionIndex = sessionIndex,
                                participantOrder = participantOrder,
                                questionOffset = questionOffset,
                                questionId = questionId,
                                feedbackType = type,
                                manager = managerEntityId,
                                participantId = participantId,
                                timestamp = seededAt,
                            )
                            feedbackCount += 1
                            feedbackForParticipant += 1
                        }
                    }

                    SessionParticipantTable.insert {
                        it[session] = sessionId
                        it[participant] = EntityID(participantId, AccountTable)
                        it[feedbackSubmitted] = feedbackForParticipant > 0
                        it[dateCreated] = seededAt.plusMinutes((sessionIndex * 10 + participantOrder).toLong())
                    }
                }
            }

            logger.info("Inserted mock seed data: sessions={}, participants={}, feedback={}", totalSessions, totalParticipants, feedbackCount)
        }
    }

    private fun insertManagerAccount(createdAt: OffsetDateTime) {
        AccountTable.insert {
            it[id] = EntityID(managerId, AccountTable)
            it[email] = "test@email.dk"
            it[name] = "Test Manager"
            it[phoneNumber] = "12345678"
            it[ratingPrompted] = false
            it[AccountTable.createdAt] = createdAt
            it[updatedAt] = createdAt
            it[feedbackSessionHash] = deterministicUuid("manager-feedback-session")
        }
    }

    private fun insertParticipantAccounts(createdAt: OffsetDateTime): List<String> {
        return (1..totalParticipants).map { index ->
            val participantId = "mock_participant_${index.toString().padStart(3, '0')}"
            AccountTable.insert {
                it[id] = EntityID(participantId, AccountTable)
                it[email] = "$participantId@email.dk"
                it[name] = "Mock Participant $index"
                it[phoneNumber] = "555000${index.toString().padStart(3, '0')}"
                it[ratingPrompted] = index % 2 == 0
                it[AccountTable.createdAt] = createdAt.plusMinutes(index.toLong())
                it[updatedAt] = createdAt.plusMinutes(index.toLong())
                it[feedbackSessionHash] = deterministicUuid("participant-feedback-session-$participantId")
            }
            participantId
        }
    }

    private fun insertActivity(
        activityId: UUID,
        title: String,
        agenda: String,
        manager: EntityID<String>,
        timestamp: OffsetDateTime,
    ) {
        ActivityTable.insert {
            it[id] = EntityID(activityId, ActivityTable)
            it[ActivityTable.title] = title
            it[ActivityTable.agenda] = agenda
            it[runMode] = ActivityRunMode.MANUAL
            it[sendEmails] = false
            it[ActivityTable.manager] = manager
            it[lastUpdated] = timestamp
            it[dateCreated] = timestamp
        }
    }

    private fun insertSession(
        sessionId: UUID,
        activityId: UUID,
        title: String,
        agenda: String,
        location: String,
        durationInMinutes: Int,
        manager: EntityID<String>,
        startDate: OffsetDateTime,
        timestamp: OffsetDateTime,
    ) {
        EventTable.insert {
            it[id] = EntityID(sessionId, EventTable)
            it[activity] = EntityID(activityId, ActivityTable)
            it[EventTable.title] = title
            it[EventTable.agenda] = agenda
            it[EventTable.location] = location
            it[EventTable.durationInMinutes] = durationInMinutes
            it[EventTable.manager] = manager
            it[EventTable.startDate] = startDate
            it[lastUpdated] = timestamp
            it[dateCreated] = timestamp
            it[createdFromMailListener] = false
            it[calendarProvider] = null
            it[calendarEventId] = null
        }
    }

    private fun insertQuestions(
        sessionId: UUID,
        activityId: UUID,
        manager: EntityID<String>,
        timestamp: OffsetDateTime,
    ): List<UUID> {
        return questionTypes.mapIndexed { index, type ->
            QuestionTable.insertAndGetId {
                it[questionText] = questionTextByType.getValue(type)
                it[activity] = EntityID(activityId, ActivityTable)
                it[session] = sessionId
                it[event] = sessionId
                it[feedbackType] = type
                it[QuestionTable.manager] = manager
                it[QuestionTable.index] = index
                it[lastUpdated] = timestamp
                it[dateCreated] = timestamp
                it[activityQuestionId] = deterministicUuid("activity-question-$activityId-$type")
            }.value
        }
    }

    private fun insertPinCode(sessionId: UUID, sessionIndex: Int) {
        PinCodeTable.insert {
            it[code] = (1000 + sessionIndex).toString()
            it[event] = sessionId
        }
    }

    private fun insertFeedback(
        sessionIndex: Int,
        participantOrder: Int,
        questionOffset: Int,
        questionId: UUID,
        feedbackType: FeedbackType,
        manager: EntityID<String>,
        participantId: String,
        timestamp: OffsetDateTime,
    ) {
        FeedbackTable.insert {
            it[id] = EntityID(
                deterministicUuid("feedback-$sessionIndex-$participantOrder-$questionOffset-$participantId"),
                FeedbackTable,
            )
            it[type] = feedbackType
            it[comment] = if (feedbackType == FeedbackType.Comment) {
                "Session ${sessionIndex + 1} suggestion from participant ${participantOrder + 1}"
            } else {
                null
            }
            it[emoji] = if (feedbackType == FeedbackType.Emoji) {
                Emoji.entries[(sessionIndex + participantOrder) % Emoji.entries.size]
            } else {
                null
            }
            it[thumbsUpThumpsDown] = if (feedbackType == FeedbackType.ThumpsUpThumpsDown) {
                if ((sessionIndex + participantOrder) % 2 == 0) ThumbsUpThumpsDown.Up else ThumbsUpThumpsDown.Down
            } else {
                null
            }
            it[zeroToTen] = if (feedbackType == FeedbackType.ZeroToTen) {
                (sessionIndex * 3 + participantOrder) % 11
            } else {
                null
            }
            it[opinion] = if (feedbackType == FeedbackType.Opinion) {
                Opinion.entries[(sessionIndex + participantOrder) % Opinion.entries.size]
            } else {
                null
            }
            it[question] = EntityID(questionId, QuestionTable)
            it[FeedbackTable.manager] = manager
            it[participant] = EntityID(participantId, AccountTable)
            it[seenByManager] = (sessionIndex + participantOrder + questionOffset) % 3 == 0
            it[dateCreated] = timestamp.plusMinutes((sessionIndex * 20 + participantOrder * 3 + questionOffset).toLong())
            it[lastUpdated] = timestamp.plusMinutes((sessionIndex * 20 + participantOrder * 3 + questionOffset).toLong())
        }
    }

    private fun pickParticipantsForSession(
        allParticipants: List<String>,
        sessionIndex: Int,
        count: Int,
    ): List<String> {
        val start = (sessionIndex * 3) % allParticipants.size
        return (0 until count).map { offset ->
            allParticipants[(start + offset) % allParticipants.size]
        }
    }

    private fun sessionStart(seed: Int): OffsetDateTime {
        return when {
            seed <= 6 -> OffsetDateTime.of(2025, 11, seed, 9, 0, 0, 0, UTC)
            seed <= 12 -> OffsetDateTime.of(2026, 5, (seed - 6).coerceAtMost(28), 10, 0, 0, 0, UTC)
            else -> OffsetDateTime.of(2026, 8, (seed - 12).coerceAtMost(28), 11, 0, 0, 0, UTC)
        }
    }

    private fun deterministicUuid(seed: String): UUID {
        return UUID.nameUUIDFromBytes(seed.toByteArray(StandardCharsets.UTF_8))
    }

    private enum class Scenario(val submittedParticipants: Int, val questionsPerSubmitter: Int, val agenda: String) {
        NO_FEEDBACK(0, 0, "Planning and updates only; no participant submissions expected."),
        LIGHT_FEEDBACK(2, 2, "Quick pulse-check with a couple of responses."),
        MIXED_FEEDBACK(3, 3, "Standard retrospective with mixed participation."),
        BROAD_FEEDBACK(4, 4, "Cross-team review with broad participation."),
        HEAVY_FEEDBACK(5, 5, "Deep-dive workshop with full questionnaire responses."),
    }

    private val questionTypes = listOf(
        FeedbackType.Opinion,
        FeedbackType.Comment,
        FeedbackType.Emoji,
        FeedbackType.ThumpsUpThumpsDown,
        FeedbackType.ZeroToTen,
    )

    private val questionTextByType = mapOf(
        FeedbackType.Opinion to "I am generally happy with my work life balance.",
        FeedbackType.Comment to "Tell me how I can improve?",
        FeedbackType.Emoji to "How was the energy in this session?",
        FeedbackType.ThumpsUpThumpsDown to "Do you want more feedback sessions like this?",
        FeedbackType.ZeroToTen to "How happy are you from 0-10?",
    )

    private val locations = listOf(
        "Copenhagen HQ",
        "Aarhus Office",
        "Odense Hub",
        "Remote / Google Meet",
        "Client Site",
    )

    private val durations = listOf(30, 45, 60, 75, 90)

    private val eventTitles = listOf(
        "Weekly Team Sync",
        "Project Kickoff",
        "Sprint Retrospective",
        "Product Strategy",
        "Customer Feedback Review",
        "Marketing Alignment",
        "Architecture Deep Dive",
        "Quarterly Update",
        "One-on-One Coaching",
        "Incident Postmortem",
        "Onboarding Session",
        "Roadmap Prioritization",
    )
}
