package dk.example.feedback.model.dto

import dk.example.feedback.service.Claim

data class SessionDto(
    val claim: Claim?,
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
