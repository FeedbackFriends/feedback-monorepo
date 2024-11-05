package dk.example.feedback.service

import dk.example.feedback.model.dto.SessionDto
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class SessionService(
    val eventService: EventService,
    val firebaseService: FirebaseService
) {

    fun getSession(accountId: String, claim: Claim?): SessionDto {
        val account = firebaseService.getUser(accountId)
        val participantEvents = eventService.getParticipantEvents(accountId = accountId)
        when (claim) {
            Claim.Manager -> {
                val managerEvents = eventService.getManagerEvents(accountId)
                return SessionDto(
                    claim = claim,
                    accountInfo = SessionDto.AccountInfoDto(
                        name = account.displayName,
                        email = account.email,
                        phoneNumber = account.phoneNumber
                    ),
                    participantEvents = participantEvents,
                    managerData = SessionDto.ManagerDataDto(
                        managerEvents = managerEvents,
                        teams = emptyList()
                    )
                )
            }
            Claim.Participant -> {
                return SessionDto(
                    claim = claim,
                    accountInfo = SessionDto.AccountInfoDto(
                        name = account.displayName,
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
                        name = account.displayName,
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