package dk.example.feedback.service

import dk.example.feedback.dto.SessionDto
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.helpers.role
import dk.example.feedback.model.database.AccountEntity
import dk.example.feedback.model.enumerations.Role
import java.util.*
import org.slf4j.LoggerFactory
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service

@Service
class SessionService(
    val eventService: EventService,
    val accountService: AccountService,
    val activityService: ActivityService,
) {

    private val logger = LoggerFactory.getLogger(SessionService::class.java)

    fun getUpdatedSession(jwt: Jwt, feedbackSessionHash: UUID): SessionDto? {
        val accountId = jwt.getAccountId()
        val role = jwt.role()
        val account = accountService.fetchAccount(accountId = accountId)
            ?: throw Exception("Account not found for id: $accountId")
        if (account.feedbackSessionHash == feedbackSessionHash) {
            logger.info("Session hash is the same, no need to provide updated session")
            return null
        }
        return getSessionDto(
            accountId = accountId,
            role = role,
            account = account
        )
    }

    fun getSession(jwt: Jwt): SessionDto {
        val accountId = jwt.getAccountId()
        val role = jwt.role()
        val account = accountService.fetchAccount(accountId = accountId)
            ?: throw Exception("Account not found for id: $accountId")
        return getSessionDto(
            accountId = accountId,
            role = role,
            account = account
        )
    }

    private fun getSessionDto(
        accountId: String,
        role: Role?,
        account: AccountEntity,
    ): SessionDto {
        val participantEvents = eventService.getParticipantEvents(accountId = accountId)
        logger.info("Get session with role: $role")
        activityService.movePendingNotificationsToActivityAndReturn(accountId = accountId)
        val accountDto = SessionDto.AccountInfoDto(
            name = account.name,
            email = account.email,
            phoneNumber = account.phoneNumber,
        )
        when (role) {
            Role.Manager -> {
                val managerEvents = eventService.getManagerEvents(accountId)
                val session = SessionDto(
                    role = role,
                    accountInfo = SessionDto.AccountInfoDto(
                        name = account.name,
                        email = account.email,
                        phoneNumber = account.phoneNumber,
                    ),
                    participantEvents = participantEvents,
                    managerData = SessionDto.ManagerDataDto(
                        managerEvents = managerEvents,
                        activity = activityService.getActivity(accountId = accountId),
                        recentlyUsedQuestions = eventService.getRecentlyUsedQuestions(accountId = accountId),
                        feedbackSessionHash = account.feedbackSessionHash
                    )
                )
                return session
            }

            Role.Participant -> {
                return SessionDto(
                    role = role,
                    accountInfo = accountDto,
                    participantEvents = participantEvents,
                    managerData = null
                )
            }
            null -> {
                return SessionDto(
                    role = null,
                    accountInfo = accountDto,
                    participantEvents = participantEvents,
                    managerData = null
                )
            }
        }
    }
}
