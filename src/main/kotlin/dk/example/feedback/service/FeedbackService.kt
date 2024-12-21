package dk.example.feedback.service

import dk.example.feedback.controller.FeedbackAlreadyGivenException
import dk.example.feedback.controller.FeedbackController.SendFeedbackResponse
import dk.example.feedback.helpers.AuthContextHelper
import dk.example.feedback.model.*
import dk.example.feedback.model.db_models.EventEntity
import dk.example.feedback.model.db_models.FeedbackEntity
import dk.example.feedback.model.dto.FeedbackSessionDto
import dk.example.feedback.model.dto.ManagerInfoDto
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
                ParticipantQuestion(
                    id = it.id,
                    questionText = it.questionText,
                    feedbackType = it.feedbackType,
                )
            },
            managerInfo = ManagerInfoDto(
                name = manager.name,
                email = manager.email,
                phoneNumber = manager.phoneNumber
            )
        )
    }

    fun sendFeedback(feedbackList: List<FeedbackEntity>, pinCode: String): SendFeedbackResponse {
        val accountId = context.getAuthContext().accountId
        val event = eventRepo.getEventByPinCode(pinCode = pinCode)
        val managerId = event.manager.id
        // Check if user with given client id already provided feedback
        throwIfAccountAlreadyGivenFeedback(feedback = feedbackList, accountId = accountId)
        throwIfAccountIsManager(events = event, accountId = accountId)
        feedbackRepo.persistFeedback(
            feedbackList = feedbackList,
            participantId = accountId,
            managerId = managerId,
            eventId = event.id
        )
        eventRepo.incrementNewFeedbackCount(eventId = event.id)
        feedbackList.forEach { eventRepo.addParticipantToEvent(eventId = event.id, accountId = accountId, feedback = it.id) }
        val shouldPresentRatingPrompt = shouldPresentRatingPrompt(accountId = accountId)
        if (shouldPresentRatingPrompt) {
            accountRepo.markRatingPrompted(accountId = accountId)
        }
        return SendFeedbackResponse(shouldPresentRatingPrompt = shouldPresentRatingPrompt)
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
