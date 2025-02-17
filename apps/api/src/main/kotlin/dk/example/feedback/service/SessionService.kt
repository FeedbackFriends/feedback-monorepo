package dk.example.feedback.service

import dk.example.feedback.dto.SessionDto
import dk.example.feedback.helpers.AuthContextHelper
import dk.example.feedback.model.enumerations.Role
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class SessionService(
    val eventService: EventService,
    val accountService: AccountService,
    val context: AuthContextHelper,
) {

    private val logger = LoggerFactory.getLogger(AccountService::class.java)

    fun getSession(): SessionDto {
        val accountId = context.getAuthContext().accountId
        val role = context.getAuthContext().role
        val account = accountService.fetchAccount(accountId = accountId) ?: throw Exception("Account not found")
        val participantEvents = eventService.getParticipantEvents(accountId = accountId)
        logger.info("Get session with role: $role")
        when (role) {

            Role.Organizer -> {
                val managerEvents = eventService.getManagerEvents(accountId)
                return SessionDto(
                    role = role,
                    accountInfo = SessionDto.AccountInfoDto(
                        name = account.name,
                        email = account.email,
                        phoneNumber = account.phoneNumber
                    ),
                    participantEvents = participantEvents,
                    managerData = SessionDto.ManagerDataDto(
                        managerEvents = managerEvents,
                    )
                )
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
