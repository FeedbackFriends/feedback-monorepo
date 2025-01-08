package dk.example.feedback.service

import dk.example.feedback.controller.FeedbackAlreadyGivenException
import dk.example.feedback.helpers.AuthContextHelper
import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.model.database.FeedbackEntity
import dk.example.feedback.model.dto.FeedbackSessionDto
import dk.example.feedback.model.dto.OwnerInfoDto
import dk.example.feedback.model.dto.ParticipantQuestionDto
import dk.example.feedback.model.dto.SubmitFeedbackResponseDto
import dk.example.feedback.model.payloads.FeedbackInput
import dk.example.feedback.persistence.repo.EventRepo
import dk.example.feedback.persistence.repo.FeedbackRepo
import dk.example.feedback.persistence.repo.AccountRepo
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class FeedbackService(
    val feedbackRepo: FeedbackRepo,
    val eventRepo: EventRepo,
    val accountRepo: AccountRepo,
    val context: AuthContextHelper,
) {

    fun startSession(pinCode: String): FeedbackSessionDto {
        val accountId = context.getAuthContext().accountId
        val event = eventRepo.getEventByPinCode(pinCode = pinCode)
        val feedback = event.feedback
        val manager = event.manager
        throwIfAccountAlreadyGivenFeedback(feedback = feedback, accountId = accountId)
        throwIfAccountIsManager(events = event, accountId = accountId)
        return FeedbackSessionDto(
            title = event.title,
            agenda = event.agenda,
            questions = event.questions.map {
                ParticipantQuestionDto(
                    id = it.id,
                    questionText = it.questionText,
                    feedbackType = it.feedbackType,
                )
            },
            ownerInfo = OwnerInfoDto(
                name = manager.name,
                email = manager.email,
                phoneNumber = manager.phoneNumber
            ),
            date = event.date,
        )
    }

    fun sendFeedback(feedbackInputList: List<FeedbackInput>, pinCode: String): SubmitFeedbackResponseDto {
        val accountId = context.getAuthContext().accountId
        val event = eventRepo.getEventByPinCode(pinCode = pinCode)
        val managerId = event.manager.id
        // Check if user with given client id already provided feedback
        throwIfAccountAlreadyGivenFeedback(feedback = event.feedback, accountId = accountId)
        throwIfAccountIsManager(events = event, accountId = accountId)
        val createdFeedbackList = feedbackRepo.persistFeedback(
            feedbackList = feedbackInputList,
            participantId = accountId,
            managerId = managerId,
            eventId = event.id
        )
        createdFeedbackList.forEach { eventRepo.addParticipantToEvent(eventId = event.id, accountId = accountId, feedback = it.id) }
        val shouldPresentRatingPrompt = shouldPresentRatingPrompt(accountId = accountId)
        if (shouldPresentRatingPrompt) {
            accountRepo.markRatingPrompted(accountId = accountId)
        }
        return SubmitFeedbackResponseDto(shouldPresentRatingPrompt = shouldPresentRatingPrompt)
    }

    private fun throwIfAccountAlreadyGivenFeedback(feedback: List<FeedbackEntity>, accountId: String) {
        val hasGivenFeedback = feedback.any { it.participantId == accountId }
        if (hasGivenFeedback) {
            throw FeedbackAlreadyGivenException()
        }
    }

    private fun throwIfAccountIsManager(events: EventEntity, accountId: String) {
        val isManager = events.manager.id == accountId
        if (isManager) {
            throw IllegalArgumentException("Owner of event cannot give feedback")
        }
    }

    private fun shouldPresentRatingPrompt(accountId: String): Boolean {
        return feedbackRepo.getTotalFeedbackSubmissionsForAccount(accountId = accountId) >= 3
    }
}
