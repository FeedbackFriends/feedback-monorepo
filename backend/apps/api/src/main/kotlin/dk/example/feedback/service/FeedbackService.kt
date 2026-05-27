package dk.example.feedback.service

import dk.example.feedback.dto.FeedbackEventDto
import dk.example.feedback.dto.OwnerInfoDto
import dk.example.feedback.dto.ParticipantQuestionDto
import dk.example.feedback.dto.SubmitFeedbackResponseDto
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.helpers.participantResponses
import dk.example.feedback.model.database.FeedbackEntity
import dk.example.feedback.model.exceptions.FeedbackAlreadySubmittedException
import dk.example.feedback.payloads.FeedbackInput
import dk.example.feedback.persistence.repo.AccountRepo
import dk.example.feedback.persistence.repo.FeedbackRepo
import dk.example.feedback.persistence.repo.NewFeedbackNotificationRepo
import dk.example.feedback.persistence.repo.EventRepo
import java.util.*
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service

@Service
class FeedbackService(
    val feedbackRepo: FeedbackRepo,
    val eventRepo: EventRepo,
    val accountRepo: AccountRepo,
    val newFeedbackNotificationRepo: NewFeedbackNotificationRepo,
    val authorizationService: AuthorizationService,
) {

    fun startEvent(pinCode: String, jwt: Jwt): FeedbackEventDto {
        val accountId = jwt.getAccountId()
        val event = eventRepo.getEventByPinCode(pinCode = pinCode)
        val feedback = event.feedback
        val manager = event.manager
        throwIfAccountAlreadyGivenFeedback(feedback = feedback, accountId = accountId, eventId = event.id)
        authorizationService.requireNotEventManagerForFeedback(event = event, actorAccountId = accountId)
        return FeedbackEventDto(
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

    fun submitFeedback(
        feedbackInputList: List<FeedbackInput>,
        pinCode: String,
        jwt: Jwt
    ): SubmitFeedbackResponseDto {
        val accountId = jwt.getAccountId()
        val event = eventRepo.getEventByPinCode(pinCode = pinCode)
        val managerId = event.manager.id
        throwIfAccountAlreadyGivenFeedback(feedback = event.feedback, accountId = accountId, eventId = event.id)
        authorizationService.requireNotEventManagerForFeedback(event = event, actorAccountId = accountId)
        val persistedFeedback = feedbackRepo.persistFeedback(
            feedbackList = feedbackInputList,
            participantId = accountId,
            managerId = managerId,
        )
        eventRepo.updateOrCreateParticipant(eventId = event.id, accountId = accountId, feedbackSubmitted = true)
        val shouldPresentRatingPrompt = persistedFeedback.participantResponses() >= 3
        if (shouldPresentRatingPrompt) {
            accountRepo.markRatingAsPrompted(accountId = accountId)
        }
        newFeedbackNotificationRepo.persistNewFeedbackNotification(
            eventId = event.id,
            accountId = event.manager.id
        )
        accountRepo.updateBootstrapVersion(accountId = managerId)
        return SubmitFeedbackResponseDto(
            shouldPresentRatingPrompt = shouldPresentRatingPrompt,
            event = event.toParticipantEventDto(
                pinCode = pinCode,
                feedbackSubmitted = true,
                recentlyJoined = false,
            ),
        )
    }

    private fun throwIfAccountAlreadyGivenFeedback(feedback: List<FeedbackEntity>, accountId: String, eventId: UUID) {
        val hasGivenFeedback = feedback.any { it.participantId == accountId }
        if (hasGivenFeedback) {
            throw FeedbackAlreadySubmittedException(eventId = eventId, accountId = accountId)
        }
    }

}
