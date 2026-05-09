package dk.example.feedback.persistence.table

import java.time.OffsetDateTime
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone

/**
 * Table for managing session participants and their engagement.
 *
 * Represents the many-to-many relationship between sessions and accounts (participants).
 * Tracks which users have joined a session and whether they submitted feedback.
 *
 * Relationships:
 * - References [SessionTable] (session) and [AccountTable] (participant).
 * - Deleting a session or participant cascades and removes corresponding entries.
 *
 * Columns:
 * @property session Foreign key to [SessionTable.id].
 * @property participant Foreign key to [AccountTable.id].
 * @property feedbackSubmitted Whether the participant submitted feedback for the session.
 * @property dateCreated Timestamp when the participant was associated with the session.
 */
object SessionParticipantTable : Table("session_participant") {
    val session = reference("session_id", SessionTable.id, onDelete = ReferenceOption.CASCADE)
    val event = session
    val participant = reference("participant_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
    val feedbackSubmitted = bool("feedback_submitted").default(false)
    val dateCreated = timestampWithTimeZone("created_at").clientDefault { OffsetDateTime.now() }
    override val primaryKey = PrimaryKey(session, participant)
}

typealias EventParticipantTable = SessionParticipantTable
