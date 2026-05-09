package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import org.jetbrains.exposed.sql.ReferenceOption

/**
 * Table for archiving notification history per session.
 *
 * Each row represents a historical notification entry, recording the number of new
 * feedback submissions for a session at a specific time.
 *
 * Relationships:
 * - References [SessionTable] (session) and [AccountTable] (account).
 * - Deleting a session or account cascades and removes corresponding notification history entries.
 *
 * Columns:
 * @property session Foreign key to [SessionTable.id].
 * @property account Foreign key to [AccountTable.id] for the feedback submitter.
 * @property newFeedback Number of new feedback submissions at the recorded time.
 * @property seenByManager Whether the session manager has seen this notification history entry.
 */
object NotificationHistoryTable : CommonColumnsTbl("notification_history") {
    val session = reference("session_id", SessionTable.id, onDelete = ReferenceOption.CASCADE)
    val event = session
    val account = reference("account_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
    val newFeedback = integer("new_feedback")
    val seenByManager = bool("seen_by_manager")
}
