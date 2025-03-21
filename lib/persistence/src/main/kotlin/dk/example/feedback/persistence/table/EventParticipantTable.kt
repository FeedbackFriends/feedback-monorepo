package dk.example.feedback.persistence.table

import java.time.OffsetDateTime
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone

object EventParticipantTable : Table("event_participant") {
    val event = reference("event_id", EventTable.id, onDelete = ReferenceOption.CASCADE)
    val participant = reference("participant_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
    val feedbackSubmitted = bool("feedback_submitted").default(false)
    val dateCreated = timestampWithTimeZone("created_at").clientDefault { OffsetDateTime.now() }
    override val primaryKey = PrimaryKey(event, participant)
}


