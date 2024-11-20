package dk.example.feedback.persistence.repo

import dk.example.feedback.model.*
import dk.example.feedback.model.db_models.EventEntity
import dk.example.feedback.model.dto.ManagerEventDto
import dk.example.feedback.model.dto.ParticipantEventDto
import dk.example.feedback.model.dto.toManagerEvent
import dk.example.feedback.persistence.dao.*
import dk.example.feedback.persistence.table.*
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.sql.*
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.UUID

@Transactional
@Component
class EventRepo {

    fun pinCodeExistsAlready(pinCode: String): Boolean {
        val optionalFoundPincode = EventDao.find { EventTable.pinCode eq pinCode }.firstOrNull()
        return optionalFoundPincode?.pinCode == pinCode
    }

    fun createEvent(eventInput: EventInput, generatedPinCode: String, managerId: String): EventEntity {

        val managerAccount = AccountDao.findById(managerId) ?: throw Exception("Could not find manager id: $managerId")
        val createdEvent = EventDao.new {
            this.title = eventInput.title
            this.agenda = eventInput.agenda
            this.date = eventInput.date
            this.location = eventInput.location
            this.pinCode = generatedPinCode
            this.durationInMinutes = eventInput.durationInMinutes
            this.manager = managerAccount
            this.team = null
//            this.team = eventInput.teamId?.let { TeamDao.findById(it) }
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
            updatedAt = OffsetDateTime.now(ZoneOffset.UTC)
        }
        addQuestionsAndRemoveExisting(eventId, eventInput, foundEvent.manager.id.value)
        return foundEvent.toModel()
    }

    fun getEventByPinCode(pinCode: String): EventEntity {
        val optionalFoundEvent = EventDao.find { EventTable.pinCode eq pinCode }.firstOrNull()
        if (optionalFoundEvent == null) {
            throw Exception("Could not find event with pin code: $pinCode")
        }
        return optionalFoundEvent.toModel()
    }

    fun getEvent(eventId: UUID): EventEntity? {
        return EventDao.findById(eventId)?.toModel()
    }

    fun getManagerEvents(managerId: String): List<ManagerEventDto> {
        val eventsDao = EventDao.find { EventTable.manager eq managerId }
        val events = eventsDao.toList().map { it.toModel().toManagerEvent() }
        eventsDao.forEach { event ->
            event.apply {
                this.newFeedback = 0
            }
        }
        return events
    }

    fun getParticipantEvents(accountId: String): List<ParticipantEventDto> {

        val eventsParticipated = TeamMemberDao.find { TeamMemberTable.account eq accountId }.map { it.team }.map { it.events }.flatten()
        return eventsParticipated.map {
            ParticipantEventDto(
                id = it.id.value,
                title = it.title,
                agenda = it.agenda,
                date = it.date,
                durationInMinutes = it.durationInMinutes,
                location = it.location,
                pinCode = it.pinCode,
                questions = it.questions.map {
                    ParticipantQuestion(
                        id = it.id.value,
                        questionText = it.questionText,
                        feedbackType = it.feedbackType,
                    )
                },
                teamName = it.team?.teamName,
                feedbackProvided = it.questions.flatMap { it.feedback }.any { it.participant?.id?.value == accountId }
            )
        }
    }

    private fun addQuestionsAndRemoveExisting(eventId: UUID, eventInput: EventInput, managerId: String) {
        QuestionDao.find { QuestionTable.event eq eventId }.forEach { it.delete() }
        QuestionTable.batchInsert(eventInput.questions) { questionInput ->
            this[QuestionTable.event] = EntityID(eventId, EventTable)
            this[QuestionTable.index] = eventInput.questions.indexOf(questionInput)
            this[QuestionTable.questionText] = questionInput.questionText
            this[QuestionTable.feedbackType] = questionInput.feedbackType
            this[QuestionTable.createdAt] = OffsetDateTime.now(ZoneOffset.UTC)
            this[QuestionTable.updatedAt] = OffsetDateTime.now(ZoneOffset.UTC)
            this[QuestionTable.manager] = managerId
        }
    }

    fun addParticipantToEvent(eventId: UUID, accountId: String) {
        EventParticipantTable.upsert {
            it[EventParticipantTable.event] = eventId
            it[EventParticipantTable.participant] = accountId
        }
    }
}