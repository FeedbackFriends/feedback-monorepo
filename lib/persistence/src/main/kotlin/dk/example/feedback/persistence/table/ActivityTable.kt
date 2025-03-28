package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import dk.example.feedback.persistence.table.ActivityTable.account
import dk.example.feedback.persistence.table.ActivityTable.event
import dk.example.feedback.persistence.table.ActivityTable.newFeedback
import dk.example.feedback.persistence.table.ActivityTable.seenByManager
import org.jetbrains.exposed.sql.ReferenceOption

/**
 * Table definition for tracking activity feed entries.
 *
 * This table maintains a chronological record of feedback activity for each event.
 * It tracks the number of new feedback submissions at specific points in time,
 * allowing for activity monitoring and analytics.
 *
 * The table uses a composite primary key consisting of the event ID and createdAt,
 * ensuring unique activity entries for each event at each timestamp.
 *
 * @property event Foreign key reference to the associated event from [EventTable].
 *                 When an event is deleted, all its activity feed entries are automatically
 *                 removed due to the CASCADE delete option.
 * @property account Foreign key reference to the account in [AccountTable] that
 *                   submitted the feedback. When an account is deleted, their
 *                   entries are automatically removed due to the CASCADE delete option.
 * @property newFeedback Integer representing the number of new feedback submissions
 *                      received for the event at the specified date.
 * @property seenByManager Boolean indicating whether the activity entry has been seen
 */
object ActivityTable : CommonColumnsTbl("activity") {
    val event = reference("event_id", EventTable.id, onDelete = ReferenceOption.CASCADE)
    val account = reference("account_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
    val newFeedback = integer("new_feedback")
    val seenByManager = bool("seen_by_manager")
}
