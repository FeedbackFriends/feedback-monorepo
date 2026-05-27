package dk.example.feedback.service

import dk.example.feedback.dto.EventDto
import dk.example.feedback.dto.ParticipantEventDto
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.model.exceptions.FeedbackAlreadySubmittedException
import dk.example.feedback.model.exceptions.EventAlreadyJoinedException
import dk.example.feedback.payloads.EventInput
import dk.example.feedback.persistence.pincodegenerator.PinCodeGenerator
import dk.example.feedback.persistence.repo.NotificationHistoryRepo
import dk.example.feedback.persistence.repo.EventRepo
import java.util.UUID
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service

@Service
class EventService(
    private val eventRepo: EventRepo,
    private val notificationHistoryRepo: NotificationHistoryRepo,
    private val authorizationService: AuthorizationService,
) {

    fun createEvent(eventInput: EventInput, jwt: Jwt): EventDto {
        val pinCode = PinCodeGenerator(eventRepo = eventRepo).generate()
        val event = eventRepo.persistEvent(
            activityId = eventInput.activityId,
            date = eventInput.date,
            location = eventInput.location,
            durationInMinutes = eventInput.durationInMinutes,
            generatedPinCode = pinCode,
            managerId = jwt.getAccountId(),
        )
        return event.toActivityEventDto(pinCode = pinCode)
    }

    fun updateEvent(eventInput: EventInput, eventId: UUID, jwt: Jwt): EventDto {
        val event = authorizationService.requireEventManager(eventId = eventId, actorAccountId = jwt.getAccountId())
        if (event.feedback.isNotEmpty()) {
            throw IllegalArgumentException("Cannot update event with feedback")
        }
        val updatedEvent = eventRepo.updateEvent(
            eventId = eventId,
            date = eventInput.date,
            location = eventInput.location,
            durationInMinutes = eventInput.durationInMinutes,
            managerId = jwt.getAccountId(),
        )
        return updatedEvent.toActivityEventDto(pinCode = eventRepo.getPinCodeForEvent(updatedEvent.id))
    }

    fun deleteEvent(eventId: UUID, jwt: Jwt) {
        authorizationService.requireEventManager(eventId = eventId, actorAccountId = jwt.getAccountId())
        eventRepo.deleteEvent(eventId = eventId, managerId = jwt.getAccountId())
    }

    fun joinEvent(pinCode: String, jwt: Jwt): ParticipantEventDto {
        val accountId = jwt.getAccountId()
        val event = eventRepo.getEventByPinCode(pinCode)
        authorizationService.requireNotEventManagerForJoin(event = event, actorAccountId = accountId)
        if (eventRepo.isParticipant(event.id, accountId)) {
            throw EventAlreadyJoinedException(event.id, accountId)
        }
        if (event.feedback.any { it.participantId == accountId }) {
            throw FeedbackAlreadySubmittedException(event.id, accountId)
        }
        eventRepo.updateOrCreateParticipant(eventId = event.id, accountId = accountId, feedbackSubmitted = false)
        return event.toParticipantEventDto(
            pinCode = eventRepo.getPinCodeForEvent(event.id),
            feedbackSubmitted = false,
            recentlyJoined = true,
        )
    }

    fun markEventAsSeen(eventId: UUID, jwt: Jwt) {
        authorizationService.requireEventManager(eventId = eventId, actorAccountId = jwt.getAccountId())
        eventRepo.markEventAsSeen(eventId = eventId, managerId = jwt.getAccountId())
        notificationHistoryRepo.markNotificationHistoryAsSeen(
            accountId = jwt.getAccountId(),
            eventId = eventId,
        )
    }

    fun getParticipantEvents(accountId: String): List<ParticipantEventDto> {
        return eventRepo.getParticipantEvents(accountId).map { wrapped ->
            val feedbackSubmitted = eventRepo.accountDidSubmitFeedbackForEvent(wrapped.event.id, accountId)
            wrapped.event.toParticipantEventDto(
                pinCode = eventRepo.getPinCodeForEvent(wrapped.event.id),
                feedbackSubmitted = feedbackSubmitted,
                recentlyJoined = wrapped.recentlyJoined,
            )
        }
    }
}
