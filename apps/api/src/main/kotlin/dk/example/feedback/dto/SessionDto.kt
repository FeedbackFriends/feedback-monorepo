package dk.example.feedback.dto

import dk.example.feedback.model.enumerations.Role


data class SessionDto(
    val role: Role?,
    val accountInfo: AccountInfoDto,
    val participantEvents: List<ParticipantEventDto>,
    val managerData: ManagerDataDto?
) {
    data class ManagerDataDto(
        val managerEvents: List<ManagerEventDto>,
    )
    data class AccountInfoDto(
        val name: String?,
        val email: String?,
        val phoneNumber: String?
    )
}
