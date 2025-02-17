package dk.example.feedback.persistence.table

import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.Table

object EventParticipantTable : Table("event_participant") {
    val event = reference("event_id", EventTable.id, onDelete = ReferenceOption.CASCADE)
    val participant = reference("participant_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
    val feedbackSubmitted = bool("feedback_submitted").default(false)

    override val primaryKey = PrimaryKey(event, participant)

//    init {
//        // Explicitly create a unique index to ensure PostgreSQL recognizes it
//        uniqueIndex("unique_event_participant", event, participant)
//    }
}
