package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.table.NewFeedbackNotificationTable.account
import dk.example.feedback.persistence.table.NewFeedbackNotificationTable.session
import dk.example.feedback.persistence.table.NewFeedbackNotificationTable.id
import dk.example.feedback.persistence.table.NewFeedbackNotificationTable.lastFeedbackAt
import dk.example.feedback.persistence.table.NewFeedbackNotificationTable.newFeedback
import java.util.*
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IdTable
import org.jetbrains.exposed.sql.Column
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone

/**
 * Table for tracking unprocessed feedback notifications per session.
 *
 * This table acts as a notification queue, holding entries for sessions that have received new feedback submissions
 * that have not yet been acknowledged or processed by the session owner. Each session can appear only once in this table.
 * When the owner checks their feedback, or when scheduled processing occurs, the entry is removed and its data
 * is archived in [NotificationHistoryTable].
 *
 * Relationships:
 * - Each row references a specific session ([SessionTable]) and the account ([AccountTable]) that submitted the feedback.
 * - Deleting a session or account cascades and removes corresponding notification entries.
 *
 * Table lifecycle:
 * - Entry is created when new feedback is submitted for a session.
 * - Entry is deleted when feedback is processed/acknowledged by the owner or by scheduled cleanup.
 *
 * Columns:
 * @property session Foreign key to [SessionTable.id]. Also serves as the table's primary key (one entry per session).
 * @property account Foreign key to [AccountTable.id] for the feedback submitter. Entry is deleted if the account is deleted.
 * @property lastFeedbackAt Timestamp (with timezone) of the most recent feedback submission for the session.
 * @property newFeedback Number of new feedback submissions since the last owner check or processing.
 * @property id      Alias for [session], the primary key of the table.
 */
object NewFeedbackNotificationTable : IdTable<UUID>("new_feedback_notification") {
    val session = reference("session_id", SessionTable.id, onDelete = ReferenceOption.CASCADE)
    val event = session
    val account = reference("account_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
    val lastFeedbackAt = timestampWithTimeZone("last_feedback_at")
    val newFeedback = integer("new_feedback")
    override val id: Column<EntityID<UUID>> = session
}
