package dk.example.feedback.service

import dk.example.feedback.helpers.AuthContextHelper
import dk.example.feedback.model.*
import dk.example.feedback.model.db_models.EventEntity
import dk.example.feedback.model.db_models.FeedbackEntity
import dk.example.feedback.model.dto.ManagerEventDto
import dk.example.feedback.model.dto.ParticipantEventDto
import dk.example.feedback.persistence.repo.EventRepo
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.*

@Service
@Transactional
class EventService(
    private val eventRepo: EventRepo,
    private val authContext: AuthContextHelper
) {

    fun createEvent(eventInput: EventInput): ManagerEventDto {
        val generatedPinCode = generateUniquePinCode()
        val managerId = authContext.getAuthContext().accountId
        val eventEntity = eventRepo.createEvent(eventInput, generatedPinCode, managerId)
        return eventEntity.toManagerEvent()
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
        return updatedEvent.toManagerEvent()
    }

    fun getManagerEvents(managerId: String): List<ManagerEventDto> {
        val managerEvents = eventRepo.getManagerEvents(managerId).map { it.toManagerEvent() }
        managerEvents.forEach {
            eventRepo.resetNewFeedbackCount(it.id)
        }
        return managerEvents
    }

    fun getParticipantEvents(accountId: String): List<ParticipantEventDto> {
        return eventRepo.getParticipantEvents(accountId).map { it.toParticipantEvent() }
    }

    fun joinEvent(eventCode: String): ParticipantEventDto {
        val accountId = authContext.getAuthContext().accountId
        val event = eventRepo.getEventByPinCode(eventCode)
        throwIfAccountIsManager(event, accountId)
        eventRepo.addParticipantToEvent(eventId = event.id, accountId =  accountId, feedback = null)
        return event.toParticipantEvent()
    }

    private fun generateUniquePinCode(): String {
        repeat(10) {
            val pinCode = (1000..9999).random().toString()
            if (!eventRepo.pinCodeExists(pinCode)) return pinCode
        }
        throw IllegalStateException("Failed to generate a unique pin code after multiple attempts")
    }

    private fun throwIfAccountIsManager(events: EventEntity, accountId: String) {
        val isManager = events.manager.id == accountId
        if (isManager) {
            throw IllegalArgumentException("Owner of event cannot give feedback")
        }
    }
}

fun EventEntity.toManagerEvent(): ManagerEventDto {
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
            )
        },
        feedbackSummary = feedbackSummary,
        newFeedback = newFeedback,
        managerName = manager.name ?: "Unknown"
    )
}

fun EventEntity.toParticipantEvent(): ParticipantEventDto {
    return ParticipantEventDto(
        id = id,
        title = title,
        agenda = agenda,
        date = date,
        durationInMinutes = durationInMinutes,
        location = location,
        pinCode = pinCode,
        questions = questions.map { question ->
            ParticipantQuestion(
                id = question.id,
                questionText = question.questionText,
                feedbackType = question.feedbackType
            )
        },
        feedbackProvided = feedback.isNotEmpty()
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
