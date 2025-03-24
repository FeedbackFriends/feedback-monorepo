package dk.example.feedback.dto

import dk.example.feedback.model.enumerations.Role
import java.util.*


data class SessionDto(
    val role: Role?,
    val accountInfo: AccountInfoDto,
    val participantEvents: List<ParticipantEventDto>,
    val managerData: ManagerDataDto?,
) {
    data class ManagerDataDto(
        val managerEvents: List<ManagerEventDto>,
        val newFeedback: List<NewFeedback>
    )
    data class AccountInfoDto(
        val name: String?,
        val email: String?,
        val phoneNumber: String?
    )
    data class NewFeedback(
        val eventId: UUID,
        val total: Int
    )
}
