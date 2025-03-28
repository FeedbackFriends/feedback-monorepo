package dk.example.feedback.service

import dk.example.feedback.dto.FeedbackCountStatsDto
import dk.example.feedback.dto.FeedbackSegmentationStatsDto
import dk.example.feedback.dto.FeedbackSummaryDto
import dk.example.feedback.dto.ManagerEventDto
import dk.example.feedback.dto.ManagerQuestion
import dk.example.feedback.dto.OwnerInfoDto
import dk.example.feedback.dto.ParticipantEventDto
import dk.example.feedback.dto.ParticipantQuestionDto
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.helpers.totalUniqueParticipants
import dk.example.feedback.helpers.verifyAccountHasId
import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.model.database.FeedbackEntity
import dk.example.feedback.model.enumerations.Emoji
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.exceptions.EventAlreadyJoinedException
import dk.example.feedback.model.exceptions.FeedbackAlreadySubmittedException
import dk.example.feedback.payloads.EventInput
import dk.example.feedback.persistence.repo.EventRepo
import java.util.*
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service

@Service
class EventService(
    private val eventRepo: EventRepo,
) {

    fun createEvent(eventInput: EventInput, jwt: Jwt): ManagerEventDto {
        val generatedPinCode = generateUniquePinCode()
        val managerId = jwt.getAccountId()
        val eventEntity = eventRepo.persistEvent(
            title = eventInput.title,
            agenda = eventInput.agenda,
            date = eventInput.date,
            location = eventInput.location,
            durationInMinutes = eventInput.durationInMinutes,
            generatedPinCode = generatedPinCode,
            questions = eventInput.questions.map { question ->
                Pair(question.questionText, question.feedbackType)
            },
            managerId = managerId
        )
        return eventEntity.toManagerEvent(
            pinCode = generatedPinCode
        )
    }

    fun deleteEvent(eventId: UUID, jwt: Jwt) {
        val event = eventRepo.getEvent(eventId)
        jwt.verifyAccountHasId(event.manager.id)
        eventRepo.deleteEvent(eventId)
    }

    fun updateEvent(eventInput: EventInput, eventId: UUID, jwt: Jwt): ManagerEventDto {
        val event = eventRepo.getEvent(eventId)
        jwt.verifyAccountHasId(event.manager.id)
        if (event.feedback.isNotEmpty()) {
            throw IllegalArgumentException("Cannot update event with feedback")
        }
        val updatedEvent = eventRepo.updateEvent(
            eventId = eventId,
            title = eventInput.title,
            agenda = eventInput.agenda,
            date = eventInput.date,
            location = eventInput.location,
            durationInMinutes = eventInput.durationInMinutes,
            questions = eventInput.questions.map { question ->
                Pair(question.questionText, question.feedbackType)
            }
        )
        return updatedEvent.toManagerEvent(
            pinCode = getPinCodeForEvent(eventId)
        )
    }

    fun getManagerEvents(managerId: String): List<ManagerEventDto> {
        return eventRepo.getManagerEvents(managerId).map {
            it.toManagerEvent(pinCode = getPinCodeForEvent(eventId = it.id))
        }
    }

    fun getParticipantEvents(accountId: String): List<ParticipantEventDto> {
        val eventsWrapped = eventRepo.getParticipantEvents(accountId)
        return eventsWrapped.map { wrapped ->
            val accountDidSubmitFeedbackForEvent =
                eventRepo.accountDidSubmitFeedbackForEvent(wrapped.event.id, accountId)
            wrapped.event.toParticipantEvent(
                getPinCodeForEvent(eventId = wrapped.event.id),
                feedbackSubmitted = accountDidSubmitFeedbackForEvent,
                recentlyJoined = wrapped.recentlyJoined
            )
        }
    }

    fun joinEvent(pinCode: String, jwt: Jwt): ParticipantEventDto {
        val accountId = jwt.getAccountId()
        val event = eventRepo.getEventByPinCode(pinCode)
        throwIfAccountIsManager(event, accountId)
        throwIfAccountAlreadyJoinedEvent(event, accountId)
        throwIfFeedbackAlreadySubmitted(event, accountId)
        eventRepo.updateOrCreateParticipant(eventId = event.id, accountId = accountId, feedbackSubmitted = false)
        return event.toParticipantEvent(
            pinCode = getPinCodeForEvent(event.id),
            feedbackSubmitted = false,
            recentlyJoined = true
        )
    }

    fun markEventAsSeen(eventId: UUID, jwt: Jwt) {
        val event = eventRepo.getEvent(eventId)
        jwt.verifyAccountHasId(event.manager.id)
        eventRepo.markEventAsSeen(eventId)
    }

    private fun getPinCodeForEvent(eventId: UUID): String {
        return eventRepo.getPinCodeForEvent(eventId)
    }

    private fun generateUniquePinCode(): String {
        repeat(10) {
            val pinCode = (1000..9999).random().toString()
            if (!eventRepo.pinCodeExists(pinCode)) return pinCode
        }
        throw IllegalStateException("Failed to generate a unique pin code after multiple attempts")
    }

    private fun throwIfAccountIsManager(event: EventEntity, accountId: String) {
        val isManager = event.manager.id == accountId
        if (isManager) {
            throw IllegalArgumentException("Owner of event cannot give feedback")
        }
    }

    private fun throwIfFeedbackAlreadySubmitted(event: EventEntity, accountId: String) {
        val events = eventRepo.getParticipantEvents(accountId)
        val feedbackAlreadySubmitted = events.find { it.event.id == event.id }
        if (feedbackAlreadySubmitted != null) {
            throw FeedbackAlreadySubmittedException(eventId = event.id, accountId = accountId)
        }
    }

    private fun throwIfAccountAlreadyJoinedEvent(event: EventEntity, accountId: String) {
        val participantEvents = eventRepo.getParticipantEvents(accountId)
        val hasJoinedEvent = participantEvents.any { it.event.id == event.id }
        if (hasJoinedEvent) {
            throw EventAlreadyJoinedException(eventId = event.id, accountId = accountId)
        }
    }
}

fun EventEntity.toManagerEvent(pinCode: String): ManagerEventDto {
    return ManagerEventDto(
        id = id,
        title = title,
        agenda = agenda,
        date = date,
        durationInMinutes = durationInMinutes,
        location = location,
        pinCode = pinCode,
        questions = questions.sortedBy { it.createdAt }.map { question ->
            ManagerQuestion(
                id = question.id,
                questionText = question.questionText,
                feedbackType = question.feedbackType,
                feedbackSummary = generateFeedbackSummary(
                    uniqueParticipantFeedback = question.feedback.totalUniqueParticipants(),
                    feedback = question.feedback
                ),
                feedback = question.feedback,
            )
        },
        feedbackSummary = generateFeedbackSummary(
            uniqueParticipantFeedback = feedback.totalUniqueParticipants(),
            feedback = feedback
        ),
        ownerInfo = OwnerInfoDto(name = manager.name, email = manager.email, phoneNumber = manager.phoneNumber)
    )
}

fun EventEntity.toParticipantEvent(
    pinCode: String,
    feedbackSubmitted: Boolean,
    recentlyJoined: Boolean
): ParticipantEventDto {
    return ParticipantEventDto(
        id = id,
        title = title,
        agenda = agenda,
        date = date,
        durationInMinutes = durationInMinutes,
        location = location,
        pinCode = pinCode,
        questions = questions.map { question ->
            ParticipantQuestionDto(
                id = question.id,
                questionText = question.questionText,
                feedbackType = question.feedbackType
            )
        },
        feedbackSubmited = feedbackSubmitted,
        ownerInfo = OwnerInfoDto(name = manager.name, email = manager.email, phoneNumber = manager.phoneNumber),
        recentlyJoined = recentlyJoined
    )
}

private fun generateFeedbackSummary(
    uniqueParticipantFeedback: Int,
    feedback: List<FeedbackEntity>
): FeedbackSummaryDto? {
    val totalEmojiFeedback = feedback.count { it.feedbackType == FeedbackType.Emoji }
    val emojiFeedback = feedback.filter { it.feedbackType == FeedbackType.Emoji }
    return if (uniqueParticipantFeedback > 0) {
        FeedbackSummaryDto(
            segmentationStats = FeedbackSegmentationStatsDto(
                verySadPercentage = calculatePercentage(feedback, Emoji.VerySad, totalEmojiFeedback),
                sadPercentage = calculatePercentage(feedback, Emoji.Sad, totalEmojiFeedback),
                happyPercentage = calculatePercentage(feedback, Emoji.Happy, totalEmojiFeedback),
                veryHappyPercentage = calculatePercentage(feedback, Emoji.VeryHappy, totalEmojiFeedback)
            ),
            countStats = FeedbackCountStatsDto(
                uniqueParticipantFeedback = uniqueParticipantFeedback,
                verySadCount = emojiFeedback.count { it.emoji == Emoji.VerySad },
                sadCount = emojiFeedback.count { it.emoji == Emoji.Sad },
                happyCount = emojiFeedback.count { it.emoji == Emoji.Happy },
                veryHappyCount = emojiFeedback.count { it.emoji == Emoji.VeryHappy },
                commentsCount = feedback.count { it.comment != null }
            ),
            unseenCount = feedback.filter { !it.seenByManager }.totalUniqueParticipants()
        )
    } else null
}

private fun calculatePercentage(
    feedback: List<FeedbackEntity>,
    emoji: Emoji,
    totalEmojiFeedback: Int
): Double {
    if (totalEmojiFeedback == 0) return 0.0
    return (feedback.count { it.emoji == emoji } * 100.0) / totalEmojiFeedback
}
