package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import dk.example.feedback.persistence.table.EventTable.agenda
import dk.example.feedback.persistence.table.EventTable.durationInMinutes
import dk.example.feedback.persistence.table.EventTable.location
import dk.example.feedback.persistence.table.EventTable.manager
import dk.example.feedback.persistence.table.EventTable.startDate
import dk.example.feedback.persistence.table.EventTable.title
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone

/**
 * Table definition for events in the feedback system.
 *
 * This table stores the details of events including basic information like title, agenda,
 * start time, duration, location, and the manager who organizes the event.
 * It inherits common columns from [CommonColumnsTbl] including:
 * - `id`: Unique identifier for the event
 * - `created_at`: Timestamp when the event was created
 * - `updated_at`: Timestamp when the event was last modified
 *
 * Each event is associated with a manager and can have multiple questions and participants.
 * The event's questions are managed through the [QuestionTable], and participants are tracked
 * through the [EventParticipantTable].
 *
 * @property title The title or name of the event. Maximum length: 255 characters.
 * @property agenda A short description or agenda for the event. Optional field with maximum length: 255 characters.
 * @property startDate The starting time of the event represented as a timestamp with time zone.
 *                    This determines when the event begins and when feedback collection can start.
 * @property durationInMinutes The duration of the event in minutes. Must be a positive integer.
 * @property location The physical or virtual location where the event is held. Optional field with maximum length: 255 characters.
 *                   If not specified, defaults to null.
 * @property manager Foreign key referencing the manager's account from [AccountTable]. When the manager is deleted,
 *                   all their events are automatically deleted due to the CASCADE delete option.
 */
object EventTable: CommonColumnsTbl("event") {
    val title = varchar("title", 255)
    val agenda = varchar("agenda", 255).nullable()
    val startDate = timestampWithTimeZone("start_date")
    val durationInMinutes = integer("duration_in_minutes")
    val location = varchar("location", 255).nullable().default(null)
    val manager = reference("manager_id", AccountTable, onDelete = ReferenceOption.CASCADE)
}
