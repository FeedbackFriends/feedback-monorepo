package dk.example.feedback.dto

import java.time.OffsetDateTime
import java.util.*

data class ActivityDto(
    val items: List<ActivityItem>,
    val unseenTotal: Int,
)

data class ActivityItem(
    val id: UUID,
    val date: OffsetDateTime,
    val eventTitle: String,
    val eventId: UUID,
    val newFeedbackCount: Int,
    val seenBefore: Boolean,
)
