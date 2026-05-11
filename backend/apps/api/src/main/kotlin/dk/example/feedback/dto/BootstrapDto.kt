package dk.example.feedback.dto

import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.enumerations.Role
import io.swagger.v3.oas.annotations.media.Schema
import java.time.OffsetDateTime
import java.util.UUID

@Schema(description = "Bootstrap response payload for authenticated clients.")
data class BootstrapDto(
    @field:Schema(description = "Resolved role for the authenticated account.")
    val role: Role?,
    val accountInfo: AccountInfoDto,
    val participantEvents: List<ParticipantEventDto>,
    val managerData: ManagerDataDto?,
) {
    @Schema(description = "Manager-only bootstrap section with activities and analytics.")
    data class ManagerDataDto(
        val activities: List<ActivityDto>,
        val notificationHistory: NotificationHistoryDto,
        @field:Schema(description = "Hash used by clients to detect manager data updates.")
        val bootstrapHash: UUID,
        val questionAnalytics: List<ManagerQuestionAnalyticsDto>,
    )

    @Schema(description = "Authenticated account profile metadata.")
    data class AccountInfoDto(
        val name: String?,
        val email: String?,
        val phoneNumber: String?,
    )
}

@Schema(description = "Per-question analytics aggregated across manager events.")
data class ManagerQuestionAnalyticsDto(
    @field:Schema(description = "Canonical question identifier across event snapshots.")
    val questionId: UUID,
    @field:Schema(description = "Latest question text used for the canonical question.")
    val questionText: String,
    @field:Schema(description = "Feedback format for this question.")
    val feedbackType: FeedbackType,
    val eventCount: Int,
    val responseCount: Int,
    @field:Schema(description = "Timestamp when this question was most recently asked.")
    val latestAskedAt: OffsetDateTime?,
    val overallSummary: QuestionFeedbackSummaryDto?,
    val timeline: List<QuestionTrendPointDto>,
)

@Schema(description = "Single event trend point for question analytics.")
data class QuestionTrendPointDto(
    @field:Schema(description = "Identifier of the event represented by this trend point.")
    val eventId: UUID,
    @field:Schema(description = "Event timestamp represented by this trend point.")
    val eventDate: OffsetDateTime,
    val responseCount: Int,
    val summary: QuestionFeedbackSummaryDto?,
)
