package dk.example.feedback.service

import dk.example.feedback.dto.ActivityDto
import dk.example.feedback.dto.ParticipantSessionDto
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.helpers.verifyAccountHasId
import dk.example.feedback.model.exceptions.FeedbackAlreadySubmittedException
import dk.example.feedback.model.exceptions.SessionAlreadyJoinedException
import dk.example.feedback.payloads.SessionInput
import dk.example.feedback.persistence.pincodegenerator.PinCodeGenerator
import dk.example.feedback.persistence.repo.NotificationHistoryRepo
import dk.example.feedback.persistence.repo.SessionRepo
import java.util.UUID
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service

@Service
class SessionService(
    private val sessionRepo: SessionRepo,
    private val activityService: ActivityService,
    private val notificationHistoryRepo: NotificationHistoryRepo,
) {

    fun createSession(sessionInput: SessionInput, jwt: Jwt): ActivityDto {
        val activity = activityService.toActivityDto(sessionInput.activityId)
        jwt.verifyAccountHasId(activity.owner.id)
        val pinCode = PinCodeGenerator(eventRepo = sessionRepo).generate()
        sessionRepo.persistSession(
            activityId = sessionInput.activityId,
            date = sessionInput.date,
            location = sessionInput.location,
            durationInMinutes = sessionInput.durationInMinutes,
            generatedPinCode = pinCode,
            managerId = jwt.getAccountId(),
        )
        return activityService.toActivityDto(sessionInput.activityId)
    }

    fun updateSession(sessionInput: SessionInput, sessionId: UUID, jwt: Jwt): ActivityDto {
        val session = sessionRepo.getSession(sessionId)
        jwt.verifyAccountHasId(session.manager.id)
        if (session.feedback.isNotEmpty()) {
            throw IllegalArgumentException("Cannot update session with feedback")
        }
        sessionRepo.updateSession(
            sessionId = sessionId,
            date = sessionInput.date,
            location = sessionInput.location,
            durationInMinutes = sessionInput.durationInMinutes,
        )
        return activityService.toActivityDto(session.activity.id)
    }

    fun deleteSession(sessionId: UUID, jwt: Jwt) {
        val session = sessionRepo.getSession(sessionId)
        jwt.verifyAccountHasId(session.manager.id)
        sessionRepo.deleteSession(sessionId)
    }

    fun joinSession(pinCode: String, jwt: Jwt): ParticipantSessionDto {
        val accountId = jwt.getAccountId()
        val session = sessionRepo.getSessionByPinCode(pinCode)
        if (session.manager.id == accountId) {
            throw IllegalArgumentException("Owner of session cannot give feedback")
        }
        if (sessionRepo.isParticipant(session.id, accountId)) {
            throw SessionAlreadyJoinedException(session.id, accountId)
        }
        if (session.feedback.any { it.participantId == accountId }) {
            throw FeedbackAlreadySubmittedException(session.id, accountId)
        }
        sessionRepo.updateOrCreateParticipant(sessionId = session.id, accountId = accountId, feedbackSubmitted = false)
        return session.toParticipantSessionDto(
            pinCode = sessionRepo.getPinCodeForSession(session.id),
            feedbackSubmitted = false,
            recentlyJoined = true,
        )
    }

    fun markSessionAsSeen(sessionId: UUID, jwt: Jwt) {
        val session = sessionRepo.getSession(sessionId)
        jwt.verifyAccountHasId(session.manager.id)
        sessionRepo.markSessionAsSeen(sessionId)
        notificationHistoryRepo.markNotificationHistoryAsSeen(
            accountId = jwt.getAccountId(),
            eventId = sessionId,
        )
    }

    fun getParticipantSessions(accountId: String): List<ParticipantSessionDto> {
        return sessionRepo.getParticipantSessions(accountId).map { wrapped ->
            val feedbackSubmitted = sessionRepo.accountDidSubmitFeedbackForSession(wrapped.session.id, accountId)
            wrapped.session.toParticipantSessionDto(
                pinCode = sessionRepo.getPinCodeForSession(wrapped.session.id),
                feedbackSubmitted = feedbackSubmitted,
                recentlyJoined = wrapped.recentlyJoined,
            )
        }
    }
}

typealias EventService = SessionService
