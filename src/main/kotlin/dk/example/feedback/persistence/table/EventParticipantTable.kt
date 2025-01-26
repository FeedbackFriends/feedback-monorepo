package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import org.jetbrains.exposed.sql.ReferenceOption

object EventParticipantTable: CommonColumnsTbl("event_participant") {
    val event = reference("event_id", EventTable.id, ReferenceOption.CASCADE)
    val participant = reference("participant_id", AccountTable.id, ReferenceOption.CASCADE)

    //    val feedback = reference("feedback_id", FeedbackTable.id, ReferenceOption.SET_NULL).nullable()
    val feedbackSubmitted = bool("feedback_submitted").default(false)
}
