package dk.example.feedback.service

import dk.example.feedback.controller.FeedbackAlreadyGivenException
import dk.example.feedback.helpers.AuthContextHelper
import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.model.database.FeedbackEntity
import dk.example.feedback.model.dto.FeedbackSummaryDto
import dk.example.feedback.model.dto.ManagerEventDto
import dk.example.feedback.model.dto.ManagerQuestion
import dk.example.feedback.model.dto.OwnerInfoDto
import dk.example.feedback.model.dto.ParticipantEventDto
import dk.example.feedback.model.dto.ParticipantQuestionDto
import dk.example.feedback.model.dto.QuestionFeedbackSummary
import dk.example.feedback.model.enumerations.Emoji
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.payloads.EventInput
import dk.example.feedback.persistence.repo.EventRepo
import java.util.*
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class EventService(
    private val eventRepo: EventRepo,
    private val authContext: AuthContextHelper
) {

    fun createEvent(eventInput: EventInput): ManagerEventDto {
        val generatedPinCode = generateUniquePinCode()
        val managerId = authContext.getAuthContext().accountId
        val eventEntity = eventRepo.persistEvent(eventInput, generatedPinCode, managerId)
        return eventEntity.toManagerEvent(
            pinCode = generatedPinCode
        )
    }

    fun deleteEvent(eventId: UUID) {
        val event = eventRepo.getEvent(eventId)
        authContext.verifyLoggedInAccountHasId(event.manager.id)
        eventRepo.deleteEvent(eventId)
    }

    fun updateEvent(eventInput: EventInput, eventId: UUID): ManagerEventDto {
        val event = eventRepo.getEvent(eventId)
        authContext.verifyLoggedInAccountHasId(event.manager.id)
        val updatedEvent = eventRepo.updateEvent(eventInput, eventId)
        return updatedEvent.toManagerEvent(
            pinCode = getPinCodeForEvent(eventId)
        )
    }

    fun getManagerEvents(managerId: String): List<ManagerEventDto> {
        val managerEvents = eventRepo.getManagerEvents(managerId).map {
            it.toManagerEvent(pinCode = getPinCodeForEvent(eventId = it.id))
        }
        managerEvents.forEach {
            eventRepo.resetNewFeedbackForEvent(it.id)
        }
        return managerEvents
    }

    fun getParticipantEvents(accountId: String): List<ParticipantEventDto> {
        val events = eventRepo.getParticipantEvents(accountId)
        return events.map { event ->
            val accountDidSubmitFeedbackForEvent = eventRepo.accountDidSubmitFeedbackForEvent(event.id, accountId)
            event.toParticipantEvent(
                getPinCodeForEvent(eventId = event.id),
                feedbackSubmitted = accountDidSubmitFeedbackForEvent
            )
        }
    }

    fun joinEvent(pinCode: String): ParticipantEventDto {
        val accountId = authContext.getAuthContext().accountId
        val event = eventRepo.getEventByPinCode(pinCode)
        throwIfAccountIsManager(event, accountId)
        throwIfAccountAlreadyJoinedEvent(event, accountId)
        throwIfFeedbackAlreadySubmitted(event, accountId)
        eventRepo.updateOrCreateParticipant(eventId = event.id, accountId = accountId, feedbackSubmitted = false)
        return event.toParticipantEvent(
            pinCode = getPinCodeForEvent(event.id),
            feedbackSubmitted = false
        )
    }

    fun resetNewFeedback(eventId: UUID) {
        val event = eventRepo.getEvent(eventId)
        authContext.verifyLoggedInAccountHasId(event.manager.id)
        eventRepo.resetNewFeedbackForEvent(eventId)
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
        val feedbackAlreadySubmitted = events.find { it.id == event.id }
        if (feedbackAlreadySubmitted != null) {
            throw FeedbackAlreadyGivenException()
        }
    }

    private fun throwIfAccountAlreadyJoinedEvent(event: EventEntity, accountId: String) {
        val participantEvents = eventRepo.getParticipantEvents(accountId)
        val hasJoinedEvent = participantEvents.any { it.id == event.id }
        if (hasJoinedEvent) {
            throw FeedbackAlreadyGivenException()
        }
    }
}

fun EventEntity.toManagerEvent(pinCode: String): ManagerEventDto {
    val totalFeedback = feedback.size
    val totalEmojiFeedback = feedback.count { it.feedbackType == FeedbackType.Emoji }
    val feedbackSummary = if (totalFeedback > 0) {
        FeedbackSummaryDto(
            totalFeedback = totalFeedback,
            verySadPercentage = calculatePercentage(feedback, Emoji.VerySad, totalEmojiFeedback),
            sadPercentage = calculatePercentage(feedback, Emoji.Sad, totalEmojiFeedback),
            happyPercentage = calculatePercentage(feedback, Emoji.Happy, totalEmojiFeedback),
            veryHappyPercentage = calculatePercentage(feedback, Emoji.VeryHappy, totalEmojiFeedback)
        )
    } else null

    return ManagerEventDto(
        id = id,
        title = title,
        agenda = agenda,
        date = date,
        durationInMinutes = durationInMinutes,
        location = location,
        pinCode = pinCode,
        questions = questions.map { question ->
            val questionFeedback = feedback.filter { it.questionId == question.id }
            ManagerQuestion(
                id = question.id,
                questionText = question.questionText,
                feedbackType = question.feedbackType,
                feedbackSummary = if (questionFeedback.isEmpty()) null else QuestionFeedbackSummary(
                    totalFeedback = questionFeedback.size,
                    verySadCount = questionFeedback.count { it.emoji == Emoji.VerySad },
                    sadCount = questionFeedback.count { it.emoji == Emoji.Sad },
                    happyCount = questionFeedback.count { it.emoji == Emoji.Happy },
                    veryHappyCount = questionFeedback.count { it.emoji == Emoji.VeryHappy }
                ),
                feedback = question.feedback,
                newFeedbackForQuestion = questionFeedback.map { it.isNew }.count()
            )
        },
        feedbackSummary = feedbackSummary,
        newFeedbackForEvent = questions.map { it.feedback }.flatten().map { it.isNew }.count(),
        ownerInfo = OwnerInfoDto(name = manager.name, email = manager.email, phoneNumber = manager.phoneNumber)
    )
}

fun EventEntity.toParticipantEvent(pinCode: String, feedbackSubmitted: Boolean): ParticipantEventDto {
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
        ownerInfo = OwnerInfoDto(name = manager.name, email = manager.email, phoneNumber = manager.phoneNumber)
    )
}

private fun calculatePercentage(
    feedback: List<FeedbackEntity>,
    emoji: Emoji,
    totalEmojiFeedback: Int
): Double {
    if (totalEmojiFeedback == 0) return 0.0
    return (feedback.count { it.emoji == emoji } * 100.0) / totalEmojiFeedback
}
