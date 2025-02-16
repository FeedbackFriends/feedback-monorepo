package dk.example.feedback.model.dto

import dk.example.feedback.service.Role

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
