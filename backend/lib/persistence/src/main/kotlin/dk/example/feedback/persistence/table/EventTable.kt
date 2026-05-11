package dk.example.feedback.persistence.table

import dk.example.feedback.model.enumerations.CalendarProvider
import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone

/**
 * Table for storing feedback events.
 *
 * Each row represents a concrete event that can receive feedback.
 *
 * Relationships:
 * - References [ActivityTable] (activity) and [AccountTable] (manager).
 * - Linked to questions ([QuestionTable]) and participants ([EventParticipantTable]).
 * - Deleting a manager cascades and removes their events.
 *
 * Columns:
 * @property startDate Timestamp when the event starts.
 * @property durationInMinutes Duration of the event in minutes.
 * @property location Optional location (physical or virtual).
 * @property manager Foreign key to [AccountTable.id] for the event owner.
 * @property activity Foreign key to [ActivityTable.id] for the parent activity.
 * @property createdFromMailListener Flag indicating if the event originated from the mail listener.
 */
object EventTable : CommonColumnsTbl("event") {
    val startDate = timestampWithTimeZone("start_date")
    val durationInMinutes = integer("duration_in_minutes")
    val location = text("location").nullable().default(null)
    val createdFromMailListener = bool("created_from_mail_listener").default(false)
    val manager = reference("manager_id", AccountTable, onDelete = ReferenceOption.CASCADE)
    val activity = reference("activity_id", ActivityTable, onDelete = ReferenceOption.CASCADE)
    val calendarProvider = enumerationByName("calendar_provider", 255, CalendarProvider::class).nullable()
    val calendarEventId = text("calendar_event_id").nullable()

    init {
        uniqueIndex("uk_event_activity_start_date", activity, startDate)
    }
}
