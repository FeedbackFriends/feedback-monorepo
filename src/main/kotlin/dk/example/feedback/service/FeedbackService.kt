package dk.example.feedback.service

import dk.example.feedback.controller.FeedbackController.SendFeedbackResponse
import dk.example.feedback.helpers.AuthContextHelper
import dk.example.feedback.model.*
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
    val firebaseService: FirebaseService,
    val context: AuthContextHelper,
) {

    fun startSession(pinCode: String): FeedbackSessionDto {
        val accountId = context.getAuthContext().accountId
        val event = eventRepo.getEventByPinCode(pinCode = pinCode)

        feedbackRepo.throwExceptionIfAccountAlreadyGivenFeedback(eventId = event.id, accountId = accountId)

        val manager = firebaseService.getUser(event.managerId) ?: throw Exception("Could not find manager with id: ${event.managerId}")
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
                name = manager.displayName,
                email = manager.email,
                phoneNumber = manager.phoneNumber
            )
        )
    }

    fun sendFeedback(feedback: List<FeedbackEntity>, pinCode: String): SendFeedbackResponse {
        val accountId = context.getAuthContext().accountId
        val event = eventRepo.getEventByPinCode(pinCode = pinCode)
        val managerId = event.managerId
        val managerAccount = accountRepo.getAccount(accountId = managerId) ?: throw Exception("Could not find manager with id: ${managerId}")
        // Check if user with given client id already provided feedback
        feedbackRepo.throwExceptionIfAccountAlreadyGivenFeedback(eventId = event.id, accountId = accountId)

        val participantAccount = accountRepo.getAccount(accountId = accountId) ?: throw Exception("Could not find participant with id: ${accountId}")

        feedbackRepo.sendFeedback(
            feedback = feedback,
            participantId = accountId,
            managerId = managerId,
            eventId = event.id
        )

        if (!participantAccount.ratingPrompted && feedbackRepo.getFeedbackCountByAccountId(accountId = accountId) >= 3) {
            accountRepo.updateRatingPrompted(accountId = accountId, ratingPrompted = true)
            return SendFeedbackResponse(shouldPresentRatingPrompt = true)
        }
        return SendFeedbackResponse(shouldPresentRatingPrompt = false)
    }
}