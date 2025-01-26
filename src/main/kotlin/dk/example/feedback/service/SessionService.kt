package dk.example.feedback.service

import dk.example.feedback.helpers.AuthContextHelper
import dk.example.feedback.model.dto.SessionDto
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
        val claim = context.getAuthContext().customClaim
        val account = accountService.fetchAccount(accountId = accountId) ?: throw Exception("Account not found")
        val participantEvents = eventService.getParticipantEvents(accountId = accountId)
        logger.info("Get session with claim: $claim")
        when (claim) {
            Claim.Manager -> {
                val managerEvents = eventService.getManagerEvents(accountId)
                return SessionDto(
                    claim = claim,
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
            Claim.Participant -> {
                return SessionDto(
                    claim = claim,
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
                    claim = claim,
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
