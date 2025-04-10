package dk.example.feedback.dto

import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.enumerations.Role
import java.time.OffsetDateTime

data class SessionDto(
    val role: Role?,
    val accountInfo: AccountInfoDto,
    val participantEvents: List<ParticipantEventDto>,
    val managerData: ManagerDataDto?,
) {
    data class ManagerDataDto(
        val managerEvents: List<ManagerEventDto>,
        val activity: ActivityDto,
        val recentlyUsedQuestions: List<RecentlyUsedQuestions>,
    )
    data class AccountInfoDto(
        val name: String?,
        val email: String?,
        val phoneNumber: String?
    )
    data class RecentlyUsedQuestions(
        val questionText: String,
        val feedbackType: FeedbackType,
        val updatedAt: OffsetDateTime,
    )
}

