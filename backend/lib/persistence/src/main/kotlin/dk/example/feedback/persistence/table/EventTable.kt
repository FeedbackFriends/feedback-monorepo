package dk.example.feedback.persistence.table

import dk.example.feedback.model.enumerations.CalendarProvider
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
 * Table for storing events.
 *
 * Each row represents an event that can receive feedback. Stores metadata such as title, agenda, schedule, location, and the organizing manager.
 *
 * Relationships:
 * - References [AccountTable] (manager).
 * - Linked to questions ([QuestionTable]) and participants ([EventParticipantTable]).
 * - Deleting a manager cascades and removes their events.
 *
 * Columns:
 * @property title Title of the event.
 * @property agenda Optional agenda/description for the event.
 * @property startDate Timestamp when the event starts.
 * @property durationInMinutes Duration of the event in minutes.
 * @property location Optional location (physical or virtual).
 * @property manager Foreign key to [AccountTable.id] for the event organizer.
 * @property createdFromMailListener Flag indicating if the event originated from the mail listener.
 */
object EventTable: CommonColumnsTbl("event") {
    val title = text("title")
    val agenda = text("agenda").nullable()
    val startDate = timestampWithTimeZone("start_date")
    val durationInMinutes = integer("duration_in_minutes")
    val location = text("location").nullable().default(null)
    val createdFromMailListener = bool("created_from_mail_listener").default(false)
    val manager = reference("manager_id", AccountTable, onDelete = ReferenceOption.CASCADE)
    val calendarProvider = enumerationByName("calendar_provider", 255, CalendarProvider::class).nullable()
    val calendarEventId = text("calendar_event_id").nullable()
}
