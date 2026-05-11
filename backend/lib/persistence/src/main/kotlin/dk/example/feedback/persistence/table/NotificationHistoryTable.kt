package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import org.jetbrains.exposed.sql.ReferenceOption

/**
 * Table for archiving notification history per event.
 *
 * Each row represents a historical notification entry, recording the number of new
 * feedback submissions for a event at a specific time.
 *
 * Relationships:
 * - References [EventTable] (event) and [AccountTable] (account).
 * - Deleting a event or account cascades and removes corresponding notification history entries.
 *
 * Columns:
 * @property event Foreign key to [EventTable.id].
 * @property account Foreign key to [AccountTable.id] for the feedback submitter.
 * @property newFeedback Number of new feedback submissions at the recorded time.
 * @property seenByManager Whether the event manager has seen this notification history entry.
 */
object NotificationHistoryTable : CommonColumnsTbl("notification_history") {
    val event = reference("event_id", EventTable.id, onDelete = ReferenceOption.CASCADE)
    val account = reference("account_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
    val newFeedback = integer("new_feedback")
    val seenByManager = bool("seen_by_manager")
}
