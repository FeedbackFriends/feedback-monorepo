package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import dk.example.feedback.persistence.table.ActivityTable.account
import dk.example.feedback.persistence.table.ActivityTable.event
import dk.example.feedback.persistence.table.ActivityTable.newFeedback
import dk.example.feedback.persistence.table.ActivityTable.seenByManager
import org.jetbrains.exposed.sql.ReferenceOption

/**
 * Table for archiving feedback activity per event.
 *
 * Each row represents a historical activity entry, recording the number of new feedback submissions for an event at a specific time.
 * Used for analytics, reporting, and tracking feedback engagement over time.
 *
 * Relationships:
 * - References [EventTable] (event) and [AccountTable] (account).
 * - Deleting an event or account cascades and removes corresponding activity entries.
 *
 * Columns:
 * @property event Foreign key to [EventTable.id].
 * @property account Foreign key to [AccountTable.id] for the feedback submitter.
 * @property newFeedback Number of new feedback submissions at the recorded time.
 * @property seenByManager Whether the event manager has seen this activity entry.
 */
object ActivityTable : CommonColumnsTbl("activity") {
    val event = reference("event_id", EventTable.id, onDelete = ReferenceOption.CASCADE)
    val account = reference("account_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
    val newFeedback = integer("new_feedback")
    val seenByManager = bool("seen_by_manager")
}
