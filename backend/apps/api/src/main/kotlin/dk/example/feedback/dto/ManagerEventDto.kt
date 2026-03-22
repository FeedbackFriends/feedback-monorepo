package dk.example.feedback.dto

import dk.example.feedback.model.database.FeedbackEntity
import dk.example.feedback.model.enumerations.CalendarProvider
import dk.example.feedback.model.enumerations.FeedbackType
import java.time.DayOfWeek
import java.time.OffsetDateTime
import java.util.*

data class FeedbackFlowDto(
    val id: UUID,
    val title: String,
    val owner: OwnerDto,
    val newFeedback: Boolean,
    val analytics: FlowAnalytics,
    val insights: FlowInsights,
    val sessions: List<SessionDto>, // keep limited (e.g. last 20)
    val sessionSettings: SessionSettings,
    val currentQuestions: List<QuestionDto> // 🔥 used for future sessions
)

data class FlowAnalytics(
    val averageRating: Double?,
    val trendStatus: GrowthStatus?,
    val lastSessionAt: OffsetDateTime?,
    val ratingTrend: List<RatingPoint>
)

data class RatingPoint(
    val value: Double,
    val timestamp: OffsetDateTime
)

data class FlowInsights(
    val summary: String?
)

data class SessionDto(
    val id: UUID,
    val averageRating: Double?,
    val ratingDelta: Double?,
    val summary: String?,
    val questionSummary: QuestionSummaryDto?,
    val questionsSnapshot: List<QuestionDto> // 🔥 key for history consistency
)

data class OwnerDto(
    val id: UUID,
    val name: String,
    val email: String
)

data class QuestionDto(
    val id: String,
    val text: String
)

data class QuestionSummaryDto(
    val positives: List<String>,
    val improvements: List<String>
)

data class SessionSettings(
    val source: SessionSource,
    val recurring: RecurringSettings? = null,
    val automation: AutomationSettings? = null
)

data class RecurringSettings(
    val frequency: Frequency,
    val dayOfWeek: DayOfWeek? = null,
    val dayOfMonth: Int? = null, // 1–31
    val time: String             // "14:00"
)

enum class Frequency {
    WEEKLY,
    MONTHLY
}

data class AutomationSettings(
    val botEmail: String,
    val isActive: Boolean
)

enum class SessionSource {
    MANUAL,
    RECURRING,
    CALENDAR_AUTOMATION
}

enum class GrowthStatus {
    IMPROVING,
    STABLE,
    NEEDS_ATTENTION
}

fun calculateGrowthStatus(scores: List<Double>): GrowthStatus? {
    if (scores.size < 3) return GrowthStatus.STABLE

    val first = scores.first()
    val last = scores.last()
    val trend = last - first

    return when {
        trend > 0.3 -> GrowthStatus.IMPROVING
        trend < -0.3 -> GrowthStatus.NEEDS_ATTENTION
        else -> GrowthStatus.STABLE
    }
}

data class SessionDetailDto(
    val id: UUID,
    val title: String,
    val agenda: String?,
    val date: OffsetDateTime,
    val pinCode: String?,
    val durationInMinutes: Int,
    val location: String?,
    val calendarProvider: CalendarProvider?,
    val isDraft: Boolean,
    val owner: OwnerDto,
    val overallFeedbackSummary: OverallFeedbackSummaryDto?,
    val invitedEmails: List<String>,
    val participants: List<ParticipantSummaryDto>,
    val questions: List<SessionQuestionDto>
)

data class SessionQuestionDto(
    val id: UUID,
    val text: String,
    val feedbackType: FeedbackType,
    val feedback: List<FeedbackEntity>,
    val summary: QuestionSummaryDto?
)