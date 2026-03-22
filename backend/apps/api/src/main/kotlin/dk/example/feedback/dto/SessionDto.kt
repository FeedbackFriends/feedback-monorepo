package dk.example.feedback.dto

import dk.example.feedback.model.enumerations.Role
import java.util.*

data class BootstrapDto(
    val role: Role?,
    val accountInfo: AccountInfoDto,
    val managerData: ManagerDataDto?,
) {
    data class ManagerDataDto(
        val feedbackFlows: List<FeedbackFlowDto>,
        val activity: ActivityDto,
        val sessionHash: UUID
    )
    data class AccountInfoDto(
        val name: String?,
        val email: String?,
        val phoneNumber: String?
    )
}
