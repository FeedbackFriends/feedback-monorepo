package dk.example.feedback.persistence.repo

import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.model.payloads.EventInput
import dk.example.feedback.persistence.dao.*
import dk.example.feedback.persistence.table.*
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.sql.*
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Transactional
@Component
class EventRepo {

    fun pinCodeExists(pinCode: String): Boolean {
        val optionalFoundPinCode = PinCodeDao.find { PinCodeTable.pinCode eq pinCode }.firstOrNull()
        return optionalFoundPinCode?.pinCode == pinCode
    }

    fun createEvent(eventInput: EventInput, generatedPinCode: String, managerId: String): EventEntity {

        val managerAccount = AccountDao.findById(managerId) ?: throw Exception("Could not find manager id: $managerId")
        val createdEvent = EventDao.new {
            this.title = eventInput.title
            this.agenda = eventInput.agenda
            this.date = eventInput.date
            this.location = eventInput.location
            this.durationInMinutes = eventInput.durationInMinutes
            this.manager = managerAccount
        }
        PinCodeDao.new {
            this.pinCode = generatedPinCode
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

    fun getManagerEvents(managerId: String): List<EventEntity> {
        return EventDao.find { EventTable.manager eq managerId }.map { it.toModel() }
    }

    fun getParticipantEvents(participantId: String): List<EventEntity> {
       return EventParticipantDao.find { EventParticipantTable.participant eq participantId }
           .map { it.event.toModel() }
    }

    fun addParticipantToEvent(eventId: UUID, accountId: String, feedback: UUID?) {
        EventParticipantTable.upsert {
            it[EventParticipantTable.event] = eventId
            it[EventParticipantTable.participant] = accountId
            it[EventParticipantTable.feedback] = feedback
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
        return PinCodeDao.find { PinCodeTable.event eq eventId }.firstOrNull()?.pinCode
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
