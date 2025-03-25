package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.table.NewFeedbackNotificationTable.account
import dk.example.feedback.persistence.table.NewFeedbackNotificationTable.event
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
 * Table definition for tracking new feedback entries.
 *
 * This table serves as a temporary storage for feedback that has not yet been
 * processed or shown to event owners. It acts as a notification queue, tracking
 * which events have new feedback and how many submissions have been received
 * since the last time the owner checked.
 *
 * The table uses the event ID as its primary key, ensuring that there is only
 * one entry per event. When feedback is processed (either through owner fetch
 * or scheduled tasks), the entry is removed from this table and its information
 * is transferred to the [ActivityTable] for historical tracking.
 *
 * @property event Foreign key reference to the event in [EventTable]. Also serves
 *                 as the primary key of this table, ensuring one entry per event.
 *                 When an event is deleted, its entry is automatically removed
 *                 due to the CASCADE delete option.
 * @property account Foreign key reference to the account in [AccountTable] that
 *                   submitted the feedback. When an account is deleted, their
 *                   entries are automatically removed due to the CASCADE delete option.
 * @property lastFeedbackAt Timestamp with time zone indicating when the most recent
 *                         feedback was submitted for this event. Used to track
 *                         the freshness of the feedback.
 * @property newFeedback Integer representing the number of new feedback submissions
 *                      received since the last time the event owner checked or
 *                      since the last scheduled processing.
 * @property id The primary key of the table, which is the event reference.
 *             This ensures one entry per event.
 */
object NewFeedbackNotificationTable : IdTable<UUID>("new_feedback_notification") {
    val event = reference("event_id", EventTable.id, onDelete = ReferenceOption.CASCADE)
    val account = reference("account_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
    val lastFeedbackAt = timestampWithTimeZone("last_feedback_at")
    val newFeedback = integer("new_feedback")
    override val id: Column<EntityID<UUID>> = event
}

