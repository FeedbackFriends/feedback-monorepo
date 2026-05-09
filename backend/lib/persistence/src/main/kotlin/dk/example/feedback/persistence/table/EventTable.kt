package dk.example.feedback.persistence.table

import dk.example.feedback.model.enumerations.CalendarProvider
import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone

/**
 * Table for storing feedback sessions.
 *
 * Each row represents a concrete session that can receive feedback. Title and agenda are snapshots from the parent activity at
 * creation time so historical sessions remain stable when the activity changes later.
 *
 * Relationships:
 * - References [ActivityTable] (activity) and [AccountTable] (manager).
 * - Linked to questions ([QuestionTable]) and participants ([SessionParticipantTable]).
 * - Deleting a manager cascades and removes their sessions.
 *
 * Columns:
 * @property title Snapshot title of the session.
 * @property agenda Snapshot agenda/description of the session.
 * @property startDate Timestamp when the session starts.
 * @property durationInMinutes Duration of the session in minutes.
 * @property location Optional location (physical or virtual).
 * @property manager Foreign key to [AccountTable.id] for the session owner.
 * @property activity Foreign key to [ActivityTable.id] for the parent activity.
 * @property createdFromMailListener Flag indicating if the session originated from the mail listener.
 */
object SessionTable : CommonColumnsTbl("session") {
    val title = text("title")
    val agenda = text("agenda").nullable()
    val startDate = timestampWithTimeZone("start_date")
    val durationInMinutes = integer("duration_in_minutes")
    val location = text("location").nullable().default(null)
    val createdFromMailListener = bool("created_from_mail_listener").default(false)
    val manager = reference("manager_id", AccountTable, onDelete = ReferenceOption.CASCADE)
    val activity = reference("activity_id", ActivityTable, onDelete = ReferenceOption.CASCADE)
    val calendarProvider = enumerationByName("calendar_provider", 255, CalendarProvider::class).nullable()
    val calendarEventId = text("calendar_event_id").nullable()

    init {
        uniqueIndex("uk_session_activity_start_date", activity, startDate)
    }
}

typealias EventTable = SessionTable
