package dk.example.feedback.service

import dk.example.feedback.dto.ActivityDto
import dk.example.feedback.dto.ParticipantEventDto
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.helpers.verifyAccountHasId
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
    private val activityService: ActivityService,
    private val notificationHistoryRepo: NotificationHistoryRepo,
) {

    fun createEvent(eventInput: EventInput, jwt: Jwt): ActivityDto {
        val activity = activityService.toActivityDto(eventInput.activityId)
        jwt.verifyAccountHasId(activity.owner.id)
        val pinCode = PinCodeGenerator(eventRepo = eventRepo).generate()
        eventRepo.persistEvent(
            activityId = eventInput.activityId,
            date = eventInput.date,
            location = eventInput.location,
            durationInMinutes = eventInput.durationInMinutes,
            generatedPinCode = pinCode,
            managerId = jwt.getAccountId(),
        )
        return activityService.toActivityDto(eventInput.activityId)
    }

    fun updateEvent(eventInput: EventInput, eventId: UUID, jwt: Jwt): ActivityDto {
        val event = eventRepo.getEvent(eventId)
        jwt.verifyAccountHasId(event.manager.id)
        if (event.feedback.isNotEmpty()) {
            throw IllegalArgumentException("Cannot update event with feedback")
        }
        eventRepo.updateEvent(
            eventId = eventId,
            date = eventInput.date,
            location = eventInput.location,
            durationInMinutes = eventInput.durationInMinutes,
        )
        return activityService.toActivityDto(event.activity.id)
    }

    fun deleteEvent(eventId: UUID, jwt: Jwt) {
        val event = eventRepo.getEvent(eventId)
        jwt.verifyAccountHasId(event.manager.id)
        eventRepo.deleteEvent(eventId)
    }

    fun joinEvent(pinCode: String, jwt: Jwt): ParticipantEventDto {
        val accountId = jwt.getAccountId()
        val event = eventRepo.getEventByPinCode(pinCode)
        if (event.manager.id == accountId) {
            throw IllegalArgumentException("Owner of event cannot give feedback")
        }
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
        val event = eventRepo.getEvent(eventId)
        jwt.verifyAccountHasId(event.manager.id)
        eventRepo.markEventAsSeen(eventId)
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
