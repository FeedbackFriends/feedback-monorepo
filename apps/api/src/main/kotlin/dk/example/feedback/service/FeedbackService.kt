package dk.example.feedback.service

import dk.example.feedback.dto.FeedbackSessionDto
import dk.example.feedback.dto.OwnerInfoDto
import dk.example.feedback.dto.ParticipantQuestionDto
import dk.example.feedback.dto.SubmitFeedbackResponseDto
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.helpers.participantResponses
import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.model.database.FeedbackEntity
import dk.example.feedback.model.exceptions.FeedbackAlreadySubmittedException
import dk.example.feedback.payloads.FeedbackInput
import dk.example.feedback.persistence.repo.AccountRepo
import dk.example.feedback.persistence.repo.EventRepo
import dk.example.feedback.persistence.repo.FeedbackRepo
import dk.example.feedback.persistence.repo.NewFeedbackNotificationRepo
import java.util.*
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service

@Service
class FeedbackService(
    val feedbackRepo: FeedbackRepo,
    val eventRepo: EventRepo,
    val accountRepo: AccountRepo,
    val newFeedbackNotificationRepo: NewFeedbackNotificationRepo,
) {

    fun startSession(pinCode: String, jwt: Jwt): FeedbackSessionDto {
        val accountId = jwt.getAccountId()
        val event = eventRepo.getEventByPinCode(pinCode = pinCode)
        val feedback = event.feedback
        val manager = event.manager
        throwIfAccountAlreadyGivenFeedback(feedback = feedback, accountId = accountId, eventId = event.id)
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

    fun submitFeedback(
        feedbackInputList: List<FeedbackInput>,
        pinCode: String,
        jwt: Jwt
    ): SubmitFeedbackResponseDto {
        val accountId = jwt.getAccountId()
        val event = eventRepo.getEventByPinCode(pinCode = pinCode)
        val managerId = event.manager.id
        // Check if user with given client id already provided feedback
        throwIfAccountAlreadyGivenFeedback(feedback = event.feedback, accountId = accountId, eventId = event.id)
        throwIfAccountIsManager(events = event, accountId = accountId)
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
        accountRepo.updateSessionHash(accountId = managerId)
        return SubmitFeedbackResponseDto(
            shouldPresentRatingPrompt = shouldPresentRatingPrompt,
            event = event.toParticipantEvent(
                pinCode = pinCode,
                feedbackSubmitted = true,
                recentlyJoined = false
            )
        )
    }

    private fun throwIfAccountAlreadyGivenFeedback(feedback: List<FeedbackEntity>, accountId: String, eventId: UUID) {
        val hasGivenFeedback = feedback.any { it.participantId == accountId }
        if (hasGivenFeedback) {
            throw FeedbackAlreadySubmittedException(eventId = eventId, accountId = accountId)
        }
    }

    private fun throwIfAccountIsManager(events: EventEntity, accountId: String) {
        val isManager = events.manager.id == accountId
        if (isManager) {
            throw IllegalArgumentException("Owner of event cannot give feedback")
        }
    }
}
