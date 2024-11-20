package dk.example.feedback.service

import dk.example.feedback.model.*
import dk.example.feedback.model.dto.ManagerEventDto
import dk.example.feedback.model.dto.ParticipantEventDto
import dk.example.feedback.model.dto.toManagerEvent
import dk.example.feedback.model.dto.toParticipantEvent
import dk.example.feedback.persistence.repo.AccountRepo
import dk.example.feedback.persistence.repo.EventRepo
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.*

@Service
@Transactional
class EventService(
    val eventRepo: EventRepo,
    val accountRepo: AccountRepo,
) {

    fun create(eventInput: EventInput, accountId: String): ManagerEventDto {
        val generatedPinCode = generatePinCode()
        val eventEntity = eventRepo.createEvent(
            eventInput = eventInput,
            generatedPinCode = generatedPinCode,
            managerId = accountId
        )
        return eventEntity.toManagerEvent()
    }

    fun delete(eventId: UUID, accountId: String) {
        val event = eventRepo.getEvent(eventId = eventId)
        if (event?.managerId != accountId) throw Exception("You are not the manager of this event.")
        eventRepo.deleteEvent(eventId = eventId)
    }

    fun update(eventInput: EventInput, eventId: UUID, accountId: String): ManagerEventDto {
        val event = eventRepo.getEvent(eventId = eventId)
        if (event?.managerId != accountId) throw Exception("You are not the manager of this event.")
        return eventRepo.updateEvent(eventInput = eventInput, eventId = eventId).toManagerEvent()
    }

    fun getManagerEvents(managerId: String): List<ManagerEventDto> {
        return eventRepo.getManagerEvents(managerId = managerId)
    }

    fun getParticipantEvents(accountId: String): List<ParticipantEventDto> {
        return eventRepo.getParticipantEvents(accountId = accountId)
    }

    fun acceptEventInvite(eventId: UUID, accountId: String): ParticipantEventDto {
        val event = eventRepo.getEvent(eventId = eventId) ?: throw Exception("Event not found.")
        accountRepo.getAccount(accountId = accountId) ?: throw Exception("Account not found.")
        eventRepo.addParticipantToEvent(eventId = eventId, accountId = accountId)
        return event.toParticipantEvent()
    }

    private fun generatePinCode(): String {
        // random 4 digit pin code
        val generatedPinCode = (1000..9999).random().toString()
        return if (eventRepo.pinCodeExistsAlready(generatedPinCode)) throw Exception("The generated pin code already exist.") else generatedPinCode
    }
}