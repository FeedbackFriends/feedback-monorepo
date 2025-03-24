package dk.example.feedback.service

import dk.example.feedback.dto.SessionDto
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.helpers.role
import dk.example.feedback.helpers.totalFeedback
import dk.example.feedback.model.enumerations.Role
import dk.example.feedback.persistence.repo.EventRepo
import dk.example.feedback.persistence.repo.NewFeedbackRepo
import org.slf4j.LoggerFactory
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service

@Service
class SessionService(
    val eventService: EventService,
    val accountService: AccountService,
    val newFeedbackRepo: NewFeedbackRepo,
    val eventRepo: EventRepo
) {

    private val logger = LoggerFactory.getLogger(SessionService::class.java)

    fun getSession(jwt: Jwt): SessionDto {
        val accountId = jwt.getAccountId()
        val role = jwt.role()
        val account = accountService.fetchAccount(accountId = accountId)
            ?: throw Exception("Account not found for id: $accountId")
        val participantEvents = eventService.getParticipantEvents(accountId = accountId)
        logger.info("Get session with role: $role")
        when (role) {

            Role.Organizer -> {
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
                        newFeedback = newFeedbackRepo.getNewFeedbackForAccount(accountId = accountId).map {
                            SessionDto.NewFeedback(
                                eventId = it.id,
                                total = it.feedback.filter { it.isNew }.totalFeedback()
                            )
                        }
                    )
                )
                newFeedbackRepo.removeNewFeedback(eventIds = managerEvents.map { it.id })
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
