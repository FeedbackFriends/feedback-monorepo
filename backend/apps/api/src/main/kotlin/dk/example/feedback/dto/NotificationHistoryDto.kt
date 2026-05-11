package dk.example.feedback.dto

import io.swagger.v3.oas.annotations.media.Schema
import java.time.OffsetDateTime
import java.util.*

@Schema(description = "Manager notification history summary for newly received feedback.")
data class NotificationHistoryDto(
    val items: List<NotificationHistoryItem>,
    @field:Schema(description = "Total unseen notification items for the manager.")
    val unseenTotal: Int,
)

@Schema(description = "Single notification history item linked to an activity event.")
data class NotificationHistoryItem(
    @field:Schema(description = "Stable identifier for the notification history item.")
    val id: UUID,
    @field:Schema(description = "Timestamp when the notification was created.")
    val date: OffsetDateTime,
    val eventTitle: String,
    @field:Schema(description = "Identifier of the related event or event.")
    val eventId: UUID,
    val newFeedbackCount: Int,
    val seenByManager: Boolean,
)
