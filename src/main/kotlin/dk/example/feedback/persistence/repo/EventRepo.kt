package dk.example.feedback.persistence.repo

import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.model.payloads.EventInput
import dk.example.feedback.persistence.dao.AccountDao
import dk.example.feedback.persistence.dao.EventDao
import dk.example.feedback.persistence.dao.PinCodeDao
import dk.example.feedback.persistence.dao.QuestionDao
import dk.example.feedback.persistence.table.EventParticipantTable
import dk.example.feedback.persistence.table.EventTable
import dk.example.feedback.persistence.table.PinCodeTable
import dk.example.feedback.persistence.table.QuestionTable
import java.time.Duration
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.*
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.and
import org.jetbrains.exposed.sql.batchInsert
import org.jetbrains.exposed.sql.deleteWhere
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.update
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional

@Transactional
@Component
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
        val optionalFoundPinCode = PinCodeDao.find { PinCodeTable.pinCode eq pinCode }.firstOrNull()
        return optionalFoundPinCode?.pinCode?.value == pinCode
    }

    fun persistEvent(eventInput: EventInput, generatedPinCode: String, managerId: String): EventEntity {

        val managerAccount = AccountDao.findById(managerId) ?: throw Exception("Could not find manager id: $managerId")
        val createdEvent = EventDao.new {
            this.title = eventInput.title
            this.agenda = eventInput.agenda
            this.date = eventInput.date
            this.location = eventInput.location
            this.durationInMinutes = eventInput.durationInMinutes
            this.manager = managerAccount
        }
        PinCodeDao.new(id = generatedPinCode) {
            this.event = createdEvent
        }
        addQuestionsAndRemoveExisting(createdEvent.id.value, eventInput, createdEvent.manager.id.value)
        return createdEvent.toModel()
    }

    fun deleteEvent(eventId: UUID) {
        val foundEvent = EventDao.findById(eventId) ?: throw Exception("Could not find event id: ${eventId}")
        foundEvent.delete()
    }

    fun updateEvent(eventInput: EventInput, eventId: UUID): EventEntity {
        val foundEvent = EventDao.findById(eventId) ?: throw Exception("Could not find event id: ${eventId}")
        foundEvent.apply {
            title = eventInput.title
            agenda = eventInput.agenda
            date = eventInput.date
            location = eventInput.location
            durationInMinutes = eventInput.durationInMinutes
        }
        addQuestionsAndRemoveExisting(eventId, eventInput, foundEvent.manager.id.value)
        return foundEvent.toModel()
    }

    fun getEventByPinCode(pinCode: String): EventEntity {
        return PinCodeDao.find { PinCodeTable.pinCode eq pinCode }.firstOrNull()?.event?.toModel()
            ?: throw Exception("Could not find event with pin code: $pinCode")
    }

    fun getEvent(eventId: UUID): EventEntity {
        return EventDao.findById(eventId)?.toModel() ?: throw Exception("Could not find event id: $eventId")
    }

    fun getEvents(eventIds: List<UUID>): List<EventEntity> {
        return eventIds.map {
            EventDao.findById(it)
        }.mapNotNull {
            it?.toModel()
        }
    }

    fun getManagerEvents(managerId: String): List<EventEntity> {
        return EventDao.find { EventTable.manager eq managerId }.map { it.toModel() }
    }

    fun getParticipantEvents(participantId: String): List<EventEntity> {
        val ids = EventParticipantTable
            .selectAll()
            .where { EventParticipantTable.participant eq participantId }
            .map {
                it[EventParticipantTable.event].value
            }
        return getEvents(ids)
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

    fun resetNewFeedbackForEvent(eventId: UUID) {
        EventDao.findById(eventId)?.apply {
            this.questions.forEach {
                it.feedback.forEach { feedback ->
                    feedback.isNew = false
                }
            }
        }
    }

    fun getPinCodeForEvent(eventId: UUID): String {
        return PinCodeDao.find { PinCodeTable.event eq eventId }.firstOrNull()?.pinCode?.value
            ?: throw Exception("Could not find pin code for event id: $eventId")
    }

    private fun addQuestionsAndRemoveExisting(eventId: UUID, eventInput: EventInput, managerId: String) {
        QuestionDao.find { QuestionTable.event eq eventId }.forEach { it.delete() }
        QuestionTable.batchInsert(eventInput.questions) { questionInput ->
            this[QuestionTable.event] = EntityID(eventId, EventTable)
            this[QuestionTable.index] = eventInput.questions.indexOf(questionInput)
            this[QuestionTable.questionText] = questionInput.questionText
            this[QuestionTable.feedbackType] = questionInput.feedbackType
            this[QuestionTable.manager] = managerId
        }
    }
}
