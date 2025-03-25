package dk.example.feedback.service

import dk.example.feedback.dto.ActivityDto
import dk.example.feedback.dto.ActivityItem
import dk.example.feedback.dto.SessionDto
import dk.example.feedback.dto.UpdatedSessionDto
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.helpers.role
import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.model.enumerations.Role
import dk.example.feedback.persistence.repo.ActivityRepo
import dk.example.feedback.persistence.repo.EventRepo
import dk.example.feedback.persistence.repo.NewFeedbackNotificationRepo
import org.slf4j.LoggerFactory
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service

@Service
class SessionService(
    val eventService: EventService,
    val accountService: AccountService,
    val newFeedbackNotificationRepo: NewFeedbackNotificationRepo,
    val activityRepo: ActivityRepo,
    private val eventRepo: EventRepo,
) {

    private val logger = LoggerFactory.getLogger(SessionService::class.java)

    fun getUpdatedSession(jwt: Jwt): UpdatedSessionDto {
        val newActivityItems = movePendingNotificationsToActivityAndReturn(accountId = jwt.getAccountId())
        logger.info("New feedback notifications: ${newActivityItems.size} for user: ${jwt.getAccountId()}")
        return UpdatedSessionDto(
            events = newActivityItems.map {
                it.toManagerEvent(pinCode = eventRepo.getPinCodeForEvent(it.id))
            },
            activity = getActivity(accountId = jwt.getAccountId())
        )
    }

    fun getSession(jwt: Jwt): SessionDto {
        val accountId = jwt.getAccountId()
        val role = jwt.role()
        val account = accountService.fetchAccount(accountId = accountId)
            ?: throw Exception("Account not found for id: $accountId")
        val participantEvents = eventService.getParticipantEvents(accountId = accountId)
        logger.info("Get session with role: $role")
        when (role) {
            Role.Organizer -> {
                movePendingNotificationsToActivityAndReturn(accountId = accountId)
                val managerEvents = eventService.getManagerEvents(accountId)
                val session = SessionDto(
                    role = role,
                    accountInfo = SessionDto.AccountInfoDto(
                        name = account.name,
                        email = account.email,
                        phoneNumber = account.phoneNumber
                    ),
                    participantEvents = participantEvents,
                    managerData = SessionDto.ManagerDataDto(
                        managerEvents = managerEvents,
                        activity = getActivity(accountId = accountId)
                    )
                )
                return session
            }

            Role.Participant -> {
                return SessionDto(
                    role = role,
                    accountInfo = SessionDto.AccountInfoDto(
                        name = account.name,
                        email = account.email,
                        phoneNumber = account.phoneNumber
                    ),
                    participantEvents = participantEvents,
                    managerData = null
                )
            }
            null -> {
                return SessionDto(
                    role = null,
                    accountInfo = SessionDto.AccountInfoDto(
                        name = account.name,
                        email = account.email,
                        phoneNumber = account.phoneNumber
                    ),
                    participantEvents = participantEvents,
                    managerData = null
                )
            }
        }
    }

    private fun getActivity(accountId: String): ActivityDto {
        val items = activityRepo.listAllForAccount(accountId = accountId).map {
            ActivityItem(
                id = it.id,
                date = it.createdAt,
                eventTitle = it.event.title,
                eventId = it.event.id,
                newFeedbackCount = it.newFeedback,
                seenBefore = it.seenBefore
            )
        }
        return ActivityDto(
            items = items,
            unseenTotal = items.filter { !it.seenBefore }.size
        )
    }

    private fun movePendingNotificationsToActivityAndReturn(accountId: String): List<EventEntity> {
        val pendingNewFeedbackNotifications = newFeedbackNotificationRepo.getAllForAccount(accountId = accountId)
        logger.info("Pending new feedback notifications: ${pendingNewFeedbackNotifications.size}")
        newFeedbackNotificationRepo.removeAllForAccount(accountId = accountId)
        logger.info("Removed all pending new feedback notifications for account: $accountId")
        for (feedback in pendingNewFeedbackNotifications) {
            logger.info("Persisting activity feed for event: ${feedback.event.id}")
            activityRepo.persistActivity(
                accountId = accountId,
                eventId = feedback.event.id,
                newFeedback = feedback.newFeedback,
            )
        }
        return pendingNewFeedbackNotifications.map { it.event }
    }
}
