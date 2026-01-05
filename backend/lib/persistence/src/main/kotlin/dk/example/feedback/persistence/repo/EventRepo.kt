package dk.example.feedback.persistence.repo

import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.model.database.QuestionEntity
import dk.example.feedback.model.enumerations.CalendarProvider
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.exceptions.PinCodeNotFoundException
import dk.example.feedback.persistence.dao.AccountDao
import dk.example.feedback.persistence.dao.EventDao
import dk.example.feedback.persistence.dao.EventInviteDao
import dk.example.feedback.persistence.dao.PinCodeDao
import dk.example.feedback.persistence.dao.QuestionDao
import dk.example.feedback.persistence.table.AccountTable
import dk.example.feedback.persistence.table.EventInviteTable
import dk.example.feedback.persistence.table.EventParticipantTable
import dk.example.feedback.persistence.table.EventTable
import dk.example.feedback.persistence.table.PinCodeTable
import dk.example.feedback.persistence.table.QuestionTable
import java.time.Duration
import java.time.Instant
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.time.temporal.ChronoUnit
import java.util.*
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.inList
import org.jetbrains.exposed.sql.and
import org.jetbrains.exposed.sql.batchInsert
import org.jetbrains.exposed.sql.deleteWhere
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.update
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional

@Component
@Transactional
class EventRepo {

    private val logger = LoggerFactory.getLogger(EventRepo::class.java)

    fun cleanUpPinCodesWithStopTimeOlderThan(duration: Duration) {
        logger.info("Started cleaning up pin codes job")
        val allEvents = EventDao.all()
        val now = OffsetDateTime.now(ZoneOffset.UTC)
        val deletedPinCodes = mutableListOf<String>()
        allEvents.forEach { eventDao ->
            val eventStopTime = eventDao.date.plusMinutes(eventDao.durationInMinutes.toLong())
            val durationFromStartToStop = Duration.between(eventStopTime, now)
            if (eventStopTime.isBefore(now) && durationFromStartToStop > duration) {
                PinCodeTable.deleteWhere {
                    event eq eventDao.id
                }
                deletedPinCodes.add(eventDao.id.value.toString())
            }
        }
        logger.info("Deleted pin codes: $deletedPinCodes")
    }

    fun pinCodeExists(pinCode: String): Boolean {
        val optionalFoundPinCode = PinCodeDao.find { PinCodeTable.code eq pinCode }.firstOrNull()
        return optionalFoundPinCode?.pinCode?.value == pinCode
    }

    fun persistEvent(
        title: String,
        agenda: String?,
        date: OffsetDateTime,
        location: String?,
        durationInMinutes: Int,
        generatedPinCode: String,
        questions: List<Pair<String, FeedbackType>>,
        managerId: String,
        createdFromMailListener: Boolean = false,
        invitedEmails: List<String> = emptyList(),
        calendarProvider: CalendarProvider? = null,
        calendarEventId: String? = null,
    ): EventEntity {

        val managerAccount = AccountDao.findById(managerId) ?: throw Exception("Could not find manager id: $managerId")
        val createdEvent = EventDao.new {
            this.title = title
            this.agenda = agenda
            this.date = date
            this.location = location
            this.durationInMinutes = durationInMinutes
            this.manager = managerAccount
            this.createdFromMailListener = createdFromMailListener
            this.calendarProvider = calendarProvider
            this.calendarEventId = calendarEventId
        }
        PinCodeDao.new(id = generatedPinCode) {
            this.event = createdEvent
        }
        addQuestionsAndRemoveExisting(createdEvent.id.value, questions, createdEvent.manager.id.value)
        addInvites(createdEvent.id.value, invitedEmails)
        return createdEvent.toModel()
    }

    fun getEventByCalendarEventId(managerId: String, calendarEventId: String): EventEntity? {
        return EventDao
            .find { (EventTable.manager eq managerId) and (EventTable.calendarEventId eq calendarEventId) }
            .firstOrNull()
            ?.toModel()
    }

    fun updateEventFromMailListener(
        eventId: UUID,
        title: String,
        agenda: String?,
        date: OffsetDateTime,
        location: String?,
        durationInMinutes: Int,
        invitedEmails: List<String>,
        calendarProvider: CalendarProvider?,
        calendarEventId: String?,
    ): EventEntity {
        val foundEvent = EventDao.findById(eventId) ?: throw Exception("Could not find event id: $eventId")
        foundEvent.apply {
            this.title = title
            this.agenda = agenda
            this.date = date
            this.location = location
            this.durationInMinutes = durationInMinutes
            this.calendarProvider = calendarProvider
            this.calendarEventId = calendarEventId
            this.createdFromMailListener = true
        }
        addInvites(eventId, invitedEmails)
        return foundEvent.toModel()
    }

    fun deleteEvent(eventId: UUID) {
        val foundEvent = EventDao.findById(eventId) ?: throw Exception("Could not find event id: ${eventId}")
        foundEvent.delete()
    }

    fun updateEvent(
        eventId: UUID,
        title: String,
        agenda: String?,
        date: OffsetDateTime,
        location: String?,
        durationInMinutes: Int,
        questions: List<Pair<String, FeedbackType>>,
    ): EventEntity {
        val foundEvent = EventDao.findById(eventId) ?: throw Exception("Could not find event id: ${eventId}")
        foundEvent.apply {
            this.title = title
            this.agenda = agenda
            this.date = date
            this.location = location
            this.durationInMinutes = durationInMinutes
        }
        addQuestionsAndRemoveExisting(eventId, questions, foundEvent.manager.id.value)
        return foundEvent.toModel()
    }

    fun getEventByPinCode(pinCode: String): EventEntity {
        return PinCodeDao.find { PinCodeTable.code eq pinCode }.firstOrNull()?.event?.toModel()
            ?: throw PinCodeNotFoundException(pinCode = pinCode)
    }

    fun getEvent(eventId: UUID): EventEntity {
        return EventDao.findById(eventId)?.toModel() ?: throw Exception("Could not find event id: $eventId")
    }

    fun getManagerEvents(managerId: String): List<EventEntity> {
        return EventDao.find { EventTable.manager eq managerId }.map { it.toModel() }
    }

    data class ParticipantEventsWithRecentlyJoined(
        val event: EventEntity,
        val recentlyJoined: Boolean,
    )

    fun getParticipantEvents(participantId: String): List<ParticipantEventsWithRecentlyJoined> {

        return EventParticipantTable
            .selectAll()
            .where { EventParticipantTable.participant eq participantId }
            .map {
                var recentlyJoined = false
                if (!it[EventParticipantTable.feedbackSubmitted]) {
                    val oneHourAgo = Instant.now().minus(1, ChronoUnit.HOURS)
                    val joinedWithinAnHour = it[EventParticipantTable.dateCreated].toInstant().isAfter(oneHourAgo)
                    if (joinedWithinAnHour) {
                        recentlyJoined = true
                    }
                }
                ParticipantEventsWithRecentlyJoined(
                    event = getEvent(it[EventParticipantTable.event].value),
                    recentlyJoined = recentlyJoined
                )
            }
    }

    fun accountDidSubmitFeedbackForEvent(eventId: UUID, accountId: String): Boolean {
        return EventParticipantTable
            .selectAll()
            .where { (EventParticipantTable.event eq eventId) and (EventParticipantTable.participant eq accountId) }
            .singleOrNull()
            ?.get(EventParticipantTable.feedbackSubmitted)
            ?: false
    }

    fun updateOrCreateParticipant(eventId: UUID, accountId: String, feedbackSubmitted: Boolean) {
        val existingTable = EventParticipantTable
            .selectAll()
            .where { (EventParticipantTable.event eq eventId) and (EventParticipantTable.participant eq accountId) }
            .singleOrNull()
        if (existingTable == null) {
            EventParticipantTable.insert {
                it[event] = eventId
                it[participant] = accountId
                it[EventParticipantTable.feedbackSubmitted] = feedbackSubmitted
            }
        } else {
            EventParticipantTable.update(
                { (EventParticipantTable.event eq eventId) and (EventParticipantTable.participant eq accountId) }
            ) {
                it[EventParticipantTable.feedbackSubmitted] = feedbackSubmitted
            }
        }
    }

    fun markEventAsSeen(eventId: UUID) {
        logger.info("Reset new feedback for event: ${eventId}")
        EventDao.findById(eventId)?.apply {
            logger.info("Event ${id.value} has ${questions.count()} questions")
            this.questions.forEach { question ->
                logger.info("Question ${question.id.value} has ${question.feedback.count()} feedback entries")
                question.feedback.forEach { feedback ->
                    feedback.seenByManager = true
                    feedback.flush()
                }
            }
        }
    }

    fun getPinCodeForEvent(eventId: UUID): String? {
        return PinCodeDao.find { PinCodeTable.event eq eventId }.firstOrNull()?.pinCode?.value
    }

    fun getRecentlyUsedQuestions(accountId: String): List<QuestionEntity> {
        return QuestionDao
            .all()
            .filter { it.manager.id.value == accountId }
            .sortedByDescending { it.dateCreated }
            .map { it.toModel() }
            .distinctBy { it.questionText }
    }

    private fun addQuestionsAndRemoveExisting(
        eventId: UUID,
        questions: List<Pair<String, FeedbackType>>,
        managerId: String
    ) {
        QuestionDao.find { QuestionTable.event eq eventId }.forEach { it.delete() }
        QuestionTable.batchInsert(questions) { questionInput ->
            this[QuestionTable.event] = EntityID(eventId, EventTable)
            this[QuestionTable.index] = questions.indexOf(questionInput)
            this[QuestionTable.questionText] = questionInput.first
            this[QuestionTable.feedbackType] = questionInput.second
            this[QuestionTable.manager] = managerId
        }
    }

    private fun addInvites(eventId: UUID, invitedEmails: List<String>) {
        val cleanedEmails = invitedEmails
            .map { it.trim() }
            .filter { it.isNotEmpty() }
            .distinctBy { it.lowercase() }

        if (cleanedEmails.isEmpty()) {
            return
        }

        val existingEmails = EventInviteTable
            .selectAll()
            .where { EventInviteTable.event eq EntityID(eventId, EventTable) }
            .map { it[EventInviteTable.email].lowercase() }
            .toSet()

        val accountsByEmail = AccountDao
            .find { AccountTable.email inList cleanedEmails }
            .associateBy { dao -> dao.email?.lowercase() }

        cleanedEmails
            .filterNot { existingEmails.contains(it.lowercase()) }
            .forEach { email ->
                EventInviteDao.new {
                    this.event = EntityID(eventId, EventTable)
                    this.email = email
                    this.account = accountsByEmail[email.lowercase()]
                }
            }
    }
}
