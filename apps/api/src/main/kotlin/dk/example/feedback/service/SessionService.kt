package dk.example.feedback.service

import dk.example.feedback.dto.SessionDto
import dk.example.feedback.dto.UpdatedSessionDto
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.helpers.role
import dk.example.feedback.model.enumerations.Role
import dk.example.feedback.persistence.repo.EventRepo
import org.slf4j.LoggerFactory
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service

@Service
class SessionService(
    val eventService: EventService,
    val accountService: AccountService,
    val eventRepo: EventRepo,
    val activityService: ActivityService,
) {

    private val logger = LoggerFactory.getLogger(SessionService::class.java)

    fun getUpdatedSession(jwt: Jwt): UpdatedSessionDto {
        val newActivityItems =
            activityService.movePendingNotificationsToActivityAndReturn(accountId = jwt.getAccountId())
        logger.info("New feedback notifications: ${newActivityItems.size} for user: ${jwt.getAccountId()}")
        when (jwt.role()) {
            Role.Manager -> {
                return UpdatedSessionDto(
                    updatedManagerEvents = newActivityItems.map {
                        it.toManagerEvent(pinCode = eventRepo.getPinCodeForEvent(it.id))
                    },
                    activity = activityService.getActivity(accountId = jwt.getAccountId())
                )
            }

            else -> {
                return UpdatedSessionDto(
                    updatedManagerEvents = null,
                    activity = activityService.getActivity(accountId = jwt.getAccountId())
                )
            }
        }
    }

    fun getSession(jwt: Jwt): SessionDto {
        val accountId = jwt.getAccountId()
        val role = jwt.role()
        val account = accountService.fetchAccount(accountId = accountId)
            ?: throw Exception("Account not found for id: $accountId")
        val participantEvents = eventService.getParticipantEvents(accountId = accountId)
        logger.info("Get session with role: $role")
        when (role) {
            Role.Manager -> {
                activityService.movePendingNotificationsToActivityAndReturn(accountId = accountId)
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
                        activity = activityService.getActivity(accountId = accountId),
                        recentlyUsedQuestions = eventService.getRecentlyUsedQuestions(accountId = accountId),
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
}
