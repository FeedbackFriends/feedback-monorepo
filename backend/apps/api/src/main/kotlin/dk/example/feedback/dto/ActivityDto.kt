package dk.example.feedback.dto

import dk.example.feedback.model.database.FeedbackEntity
import dk.example.feedback.model.enumerations.ActivityRunMode
import dk.example.feedback.model.enumerations.CalendarProvider
import dk.example.feedback.model.enumerations.FeedbackType
import io.swagger.v3.oas.annotations.media.Schema
import java.time.OffsetDateTime
import java.util.UUID

@Schema(
    description = "Manager-facing activity with configuration, active questions, event history, and trend analytics.",
)
data class ActivityDto(
    @field:Schema(description = "Stable identifier for the activity.")
    val id: UUID,
    @field:Schema(description = "Display title shown to managers and participants.")
    val title: String,
    val agenda: String?,
    val owner: OwnerDto,
    @field:Schema(description = "Run mode that controls how events are joined and processed.")
    val runMode: ActivityRunMode,
    val sendEmails: Boolean,
    val invitedEmails: List<String>,
    val events: List<EventDto>,
    val currentQuestions: List<QuestionDto>,
    val trend: ActivityTrendDto,
)

@Schema(
    description = "Activity trend computed from comparable event ratings normalized to the 0-5 scale.",
)
data class ActivityTrendDto(
    @field:Schema(description = "Trend direction across comparable events.")
    val direction: ActivityTrendDirectionDto,
    @field:Schema(description = "UI indicator derived from the trend direction.")
    val indicator: ActivityIndicatorDto,
    @field:Schema(description = "Metric used to compute the trend.")
    val metric: ActivityTrendMetricDto,
    val latestValue: Double?,
    val previousValue: Double?,
    val delta: Double?,
    @field:Schema(description = "Number of events used for trend comparison.")
    val comparedEventCount: Int,
)

enum class ActivityTrendDirectionDto {
    improving,
    stable,
    declining,
    insufficient_data,
}

enum class ActivityIndicatorDto {
    positive,
    neutral,
    negative,
}

enum class ActivityTrendMetricDto {
    average_rating,
}

@Schema(
    description = "Manager-facing event summary with schedule, join details, and question snapshot.",
)
data class EventDto(
    @field:Schema(description = "Stable identifier for the event.")
    val id: UUID,
    @field:Schema(description = "Scheduled start timestamp for the event.")
    val date: OffsetDateTime,
    val durationInMinutes: Int,
    val location: String?,
    @field:Schema(description = "Participant join code for submitting feedback.")
    val pinCode: String?,
    val createdFromMailListener: Boolean,
    val calendarProvider: CalendarProvider?,
    val calendarEventId: String?,
    @field:Schema(description = "Average rating normalized to 0-5 when comparable feedback exists.")
    val averageRating: Double?,
    val overallFeedbackSummary: OverallFeedbackSummaryDto?,
    val questionsSnapshot: List<QuestionDto>,
)

@Schema(description = "Owner identity attached to activities and events.")
data class OwnerDto(
    @field:Schema(description = "Account identifier for the owner.")
    val id: String,
    val name: String?,
    val email: String?,
)

@Schema(description = "Question reference used in activity and event snapshots.")
data class QuestionDto(
    @field:Schema(description = "Stable identifier for the question.")
    val id: UUID,
    @field:Schema(description = "Question text shown to participants.")
    val text: String
)

@Schema(
    description = "Detailed event view with participant list and question-level feedback breakdown.",
)
data class EventDetailDto(
    @field:Schema(description = "Stable identifier for the event.")
    val id: UUID,
    @field:Schema(description = "Scheduled start timestamp for the event.")
    val date: OffsetDateTime,
    @field:Schema(description = "Participant join code for the event.")
    val pinCode: String?,
    val durationInMinutes: Int,
    val location: String?,
    val calendarProvider: CalendarProvider?,
    val owner: OwnerDto,
    val overallFeedbackSummary: OverallFeedbackSummaryDto?,
    val participants: List<ParticipantSummaryDto>,
    val questions: List<EventQuestionDto>
)

@Schema(description = "Feedback results for a single question in a specific event.")
data class EventQuestionDto(
    @field:Schema(description = "Stable identifier for the question instance.")
    val id: UUID,
    @field:Schema(description = "Question text used in the event snapshot.")
    val text: String,
    @field:Schema(description = "Feedback format expected for this question.")
    val feedbackType: FeedbackType,
    val feedback: List<FeedbackEntity>,
    val summary: QuestionFeedbackSummaryDto?
)
