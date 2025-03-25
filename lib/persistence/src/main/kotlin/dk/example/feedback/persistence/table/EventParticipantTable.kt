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
 * Table definition for event participants.
 *
 * This table represents the many-to-many relationship between events and accounts,
 * tracking which participants are associated with which events. It includes metadata
 * about the participant's engagement with the event, specifically their feedback submission status.
 *
 * The table uses a composite primary key consisting of both the event and participant IDs,
 * ensuring that a participant can only be associated with an event once.
 *
 * @property event Foreign key reference to the associated event from [EventTable].
 *                 When an event is deleted, all related participant entries are automatically
 *                 removed due to the CASCADE delete option.
 * @property participant Foreign key reference to the participant's account from [AccountTable].
 *                       When a participant is deleted, all their event associations are automatically
 *                       removed due to the CASCADE delete option.
 * @property feedbackSubmitted Boolean flag indicating whether the participant has submitted feedback
 *                            for the event. Defaults to false when a participant is first associated
 *                            with an event.
 * @property dateCreated Timestamp capturing when the participant entry was created.
 *                      Automatically set to the current time when a new participant is added
 *                      to an event.
 */
object EventParticipantTable : Table("event_participant") {
    val event = reference("event_id", EventTable.id, onDelete = ReferenceOption.CASCADE)
    val participant = reference("participant_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
    val feedbackSubmitted = bool("feedback_submitted").default(false)
    val dateCreated = timestampWithTimeZone("created_at").clientDefault { OffsetDateTime.now() }
    override val primaryKey = PrimaryKey(event, participant)
}


