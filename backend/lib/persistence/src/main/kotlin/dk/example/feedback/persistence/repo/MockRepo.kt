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
import dk.example.feedback.persistence.table.EventParticipantTable
import java.nio.charset.StandardCharsets
import java.time.OffsetDateTime
import java.time.ZoneOffset.UTC
import java.util.UUID
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.inList
import org.jetbrains.exposed.sql.and
import org.jetbrains.exposed.sql.deleteWhere
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.insertAndGetId
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional

@Component
@Transactional
class MockRepo {

    fun resetManagerWithData(managerId: String) {
        transaction {
            val eventId = deterministicUuid("manager-with-data-event-$managerId")
            val activityId = deterministicUuid("manager-with-data-activity-$managerId")
            val syntheticParticipantId = "$managerId-participant"
            resetSeedGraph(
                accountIds = setOf(managerId, syntheticParticipantId),
                eventId = eventId,
                activityId = activityId,
            )
        }
    }

    fun resetParticipantWithData(participantId: String) {
        transaction {
            val eventId = deterministicUuid("participant-with-data-event-$participantId")
            val activityId = deterministicUuid("participant-with-data-activity-$participantId")
            val syntheticManagerId = "$participantId-manager"
            resetSeedGraph(
                accountIds = setOf(participantId, syntheticManagerId),
                eventId = eventId,
                activityId = activityId,
            )
        }
    }

    fun insertManagerWithData(managerId: String) {
        transaction {
            val seededAt = OffsetDateTime.of(2026, 1, 15, 9, 0, 0, 0, UTC)
            ensureAccountExists(
                id = managerId,
                name = "Mock Manager",
                email = "$managerId@email.dk",
                phoneNumber = "11111111",
                createdAt = seededAt,
                feedbackHashSeed = "manager-feedback-event-$managerId",
            )

            val syntheticParticipantId = "$managerId-participant"
            ensureAccountExists(
                id = syntheticParticipantId,
                name = "Mock Participant",
                email = "$syntheticParticipantId@email.dk",
                phoneNumber = "22222222",
                createdAt = seededAt.plusMinutes(1),
                feedbackHashSeed = "participant-feedback-event-$syntheticParticipantId",
            )

            val managerEntityId = EntityID(managerId, AccountTable)
            val participantEntityId = EntityID(syntheticParticipantId, AccountTable)
            val activityId = deterministicUuid("manager-with-data-activity-$managerId")
            val eventId = deterministicUuid("manager-with-data-event-$managerId")
            if (EventTable.selectAll().where { EventTable.id eq EntityID(eventId, EventTable) }.firstOrNull() != null) {
                return@transaction
            }

            insertActivity(
                activityId = activityId,
                title = "Mock Manager Activity",
                agenda = "Deterministic manager seed data.",
                manager = managerEntityId,
                timestamp = seededAt,
            )
            val questions = insertEventWithQuestions(
                eventId = eventId,
                activityId = activityId,
                location = "Copenhagen HQ",
                durationInMinutes = 45,
                manager = managerEntityId,
                startDate = OffsetDateTime.now(UTC).plusDays(1),
                timestamp = seededAt,
            )
            insertPinCode(eventId = eventId, code = "2000")
            insertEventParticipant(
                eventId = eventId,
                participantId = participantEntityId,
                feedbackSubmitted = true,
                timestamp = seededAt.plusMinutes(2),
            )
            repeat(20) { index ->
                val questionOffset = index % questionTypes.size
                insertFeedback(
                    feedbackSeed = index,
                    questionOffset = questionOffset,
                    questionId = questions[questionOffset],
                    feedbackType = questionTypes[questionOffset],
                    manager = managerEntityId,
                    participantId = syntheticParticipantId,
                    timestamp = seededAt,
                )
            }
        }
    }

    fun insertParticipantWithData(participantId: String) {
        transaction {
            val seededAt = OffsetDateTime.of(2026, 1, 15, 9, 0, 0, 0, UTC)
            ensureAccountExists(
                id = participantId,
                name = "Mock Participant",
                email = "$participantId@email.dk",
                phoneNumber = "33333333",
                createdAt = seededAt.plusMinutes(1),
                feedbackHashSeed = "participant-feedback-event-$participantId",
            )

            val syntheticManagerId = "$participantId-manager"
            ensureAccountExists(
                id = syntheticManagerId,
                name = "Mock Manager",
                email = "$syntheticManagerId@email.dk",
                phoneNumber = "44444444",
                createdAt = seededAt,
                feedbackHashSeed = "manager-feedback-event-$syntheticManagerId",
            )

            val managerEntityId = EntityID(syntheticManagerId, AccountTable)
            val participantEntityId = EntityID(participantId, AccountTable)
            val activityId = deterministicUuid("participant-with-data-activity-$participantId")
            val eventId = deterministicUuid("participant-with-data-event-$participantId")
            if (EventTable.selectAll().where { EventTable.id eq EntityID(eventId, EventTable) }.firstOrNull() != null) {
                return@transaction
            }

            insertActivity(
                activityId = activityId,
                title = "Mock Participant Activity",
                agenda = "Deterministic participant seed data.",
                manager = managerEntityId,
                timestamp = seededAt,
            )
            val questions = insertEventWithQuestions(
                eventId = eventId,
                activityId = activityId,
                location = "Remote",
                durationInMinutes = 30,
                manager = managerEntityId,
                startDate = OffsetDateTime.of(2026, 1, 21, 10, 0, 0, 0, UTC),
                timestamp = seededAt,
            )
            insertPinCode(eventId = eventId, code = "2001")
            insertEventParticipant(
                eventId = eventId,
                participantId = participantEntityId,
                feedbackSubmitted = true,
                timestamp = seededAt.plusMinutes(2),
            )
            repeat(10) { index ->
                val questionOffset = index % questionTypes.size
                insertFeedback(
                    feedbackSeed = index,
                    questionOffset = questionOffset,
                    questionId = questions[questionOffset],
                    feedbackType = questionTypes[questionOffset],
                    manager = managerEntityId,
                    participantId = participantId,
                    timestamp = seededAt.plusMinutes(10),
                )
            }
        }
    }

    private fun ensureAccountExists(
        id: String,
        name: String,
        email: String,
        phoneNumber: String,
        createdAt: OffsetDateTime,
        feedbackHashSeed: String,
    ) {
        if (AccountTable.selectAll().where { AccountTable.id eq id }.firstOrNull() != null) {
            return
        }
        insertAccount(
            id = id,
            email = email,
            name = name,
            phoneNumber = phoneNumber,
            createdAt = createdAt,
            feedbackHashSeed = feedbackHashSeed,
        )
    }

    private fun insertAccount(
        id: String,
        email: String,
        name: String,
        phoneNumber: String,
        createdAt: OffsetDateTime,
        feedbackHashSeed: String,
    ) {
        AccountTable.insert {
            it[AccountTable.id] = EntityID(id, AccountTable)
            it[AccountTable.email] = email
            it[AccountTable.name] = name
            it[AccountTable.phoneNumber] = phoneNumber
            it[ratingPrompted] = false
            it[AccountTable.createdAt] = createdAt
            it[updatedAt] = createdAt
            it[bootstrapVersion] = deterministicUuid(feedbackHashSeed)
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

    private fun insertEvent(
        eventId: UUID,
        activityId: UUID,
        location: String,
        durationInMinutes: Int,
        manager: EntityID<String>,
        startDate: OffsetDateTime,
        timestamp: OffsetDateTime,
    ) {
        EventTable.insert {
            it[id] = EntityID(eventId, EventTable)
            it[activity] = EntityID(activityId, ActivityTable)
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

    private fun insertEventWithQuestions(
        eventId: UUID,
        activityId: UUID,
        location: String,
        durationInMinutes: Int,
        manager: EntityID<String>,
        startDate: OffsetDateTime,
        timestamp: OffsetDateTime,
    ): List<UUID> {
        insertEvent(
            eventId = eventId,
            activityId = activityId,
            location = location,
            durationInMinutes = durationInMinutes,
            manager = manager,
            startDate = startDate,
            timestamp = timestamp,
        )
        return insertQuestions(
            eventId = eventId,
            activityId = activityId,
            manager = manager,
            timestamp = timestamp,
        )
    }

    private fun insertQuestions(
        eventId: UUID,
        activityId: UUID,
        manager: EntityID<String>,
        timestamp: OffsetDateTime,
    ): List<UUID> {
        return questionTypes.mapIndexed { index, type ->
            QuestionTable.insertAndGetId {
                it[questionText] = questionTextByType.getValue(type)
                it[activity] = EntityID(activityId, ActivityTable)
                it[event] = eventId
                it[feedbackType] = type
                it[QuestionTable.manager] = manager
                it[QuestionTable.index] = index
                it[lastUpdated] = timestamp
                it[dateCreated] = timestamp
                it[activityQuestionId] = deterministicUuid("activity-question-$activityId-$type")
            }.value
        }
    }

    private fun insertPinCode(eventId: UUID, code: String) {
        PinCodeTable.insert {
            it[PinCodeTable.code] = code
            it[event] = eventId
        }
    }

    private fun insertEventParticipant(
        eventId: UUID,
        participantId: EntityID<String>,
        feedbackSubmitted: Boolean,
        timestamp: OffsetDateTime,
    ) {
        EventParticipantTable.insert {
            it[event] = eventId
            it[participant] = participantId
            it[EventParticipantTable.feedbackSubmitted] = feedbackSubmitted
            it[dateCreated] = timestamp
        }
    }

    private fun insertFeedback(
        feedbackSeed: Int,
        questionOffset: Int,
        questionId: UUID,
        feedbackType: FeedbackType,
        manager: EntityID<String>,
        participantId: String,
        timestamp: OffsetDateTime,
    ) {
        FeedbackTable.insert {
            it[id] = EntityID(
                deterministicUuid("feedback-$feedbackSeed-$questionOffset-$participantId"),
                FeedbackTable,
            )
            it[type] = feedbackType
            it[comment] = if (feedbackType == FeedbackType.Comment) {
                "Feedback #${feedbackSeed + 1} from $participantId"
            } else {
                null
            }
            it[emoji] = if (feedbackType == FeedbackType.Emoji) {
                Emoji.entries[feedbackSeed % Emoji.entries.size]
            } else {
                null
            }
            it[thumbsUpThumpsDown] = if (feedbackType == FeedbackType.ThumpsUpThumpsDown) {
                if (feedbackSeed % 2 == 0) ThumbsUpThumpsDown.Up else ThumbsUpThumpsDown.Down
            } else {
                null
            }
            it[zeroToTen] = if (feedbackType == FeedbackType.ZeroToTen) {
                feedbackSeed % 11
            } else {
                null
            }
            it[opinion] = if (feedbackType == FeedbackType.Opinion) {
                Opinion.entries[feedbackSeed % Opinion.entries.size]
            } else {
                null
            }
            it[question] = EntityID(questionId, QuestionTable)
            it[FeedbackTable.manager] = manager
            it[participant] = EntityID(participantId, AccountTable)
            it[seenByManager] = feedbackSeed % 3 == 0
            it[dateCreated] = timestamp.plusMinutes(feedbackSeed.toLong())
            it[lastUpdated] = timestamp.plusMinutes(feedbackSeed.toLong())
        }
    }

    private fun deterministicUuid(seed: String): UUID {
        return UUID.nameUUIDFromBytes(seed.toByteArray(StandardCharsets.UTF_8))
    }

    private fun resetSeedGraph(accountIds: Set<String>, eventId: UUID, activityId: UUID) {
        val managerAccountIds = accountIds.map { EntityID(it, AccountTable) }
        val eventEntityId = EntityID(eventId, EventTable)
        val activityEntityId = EntityID(activityId, ActivityTable)

        FeedbackTable.deleteWhere { FeedbackTable.manager inList managerAccountIds }
        FeedbackTable.deleteWhere { FeedbackTable.participant inList managerAccountIds }
        EventParticipantTable.deleteWhere { EventParticipantTable.participant inList managerAccountIds }
        PinCodeTable.deleteWhere { PinCodeTable.event eq eventEntityId }
        QuestionTable.deleteWhere { (QuestionTable.event eq eventEntityId) and (QuestionTable.activity eq activityEntityId) }
        EventTable.deleteWhere { EventTable.id eq eventEntityId }
        ActivityTable.deleteWhere { ActivityTable.id eq activityEntityId }
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
        FeedbackType.Emoji to "How was the energy in this event?",
        FeedbackType.ThumpsUpThumpsDown to "Do you want more feedback events like this?",
        FeedbackType.ZeroToTen to "How happy are you from 0-10?",
    )
}
