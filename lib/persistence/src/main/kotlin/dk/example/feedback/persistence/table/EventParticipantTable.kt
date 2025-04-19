package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.table.EventParticipantTable.dateCreated
import dk.example.feedback.persistence.table.EventParticipantTable.event
import dk.example.feedback.persistence.table.EventParticipantTable.feedbackSubmitted
import dk.example.feedback.persistence.table.EventParticipantTable.participant
import java.time.OffsetDateTime
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone

/**
 * Table for managing event participants and their engagement.
 *
 * Represents the many-to-many relationship between events and accounts (participants).
 * Tracks which users are invited to or have joined an event, and whether they submitted feedback.
 *
 * Relationships:
 * - References [EventTable] (event) and [AccountTable] (participant).
 * - Deleting an event or participant cascades and removes corresponding entries.
 *
 * Columns:
 * @property event Foreign key to [EventTable.id].
 * @property participant Foreign key to [AccountTable.id].
 * @property feedbackSubmitted Whether the participant submitted feedback for the event.
 * @property dateCreated Timestamp when the participant was associated with the event.
 */
object EventParticipantTable : Table("event_participant") {
    val event = reference("event_id", EventTable.id, onDelete = ReferenceOption.CASCADE)
    val participant = reference("participant_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
    val feedbackSubmitted = bool("feedback_submitted").default(false)
    val dateCreated = timestampWithTimeZone("created_at").clientDefault { OffsetDateTime.now() }
    override val primaryKey = PrimaryKey(event, participant)
}
