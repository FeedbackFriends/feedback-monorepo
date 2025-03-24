package dk.example.feedback.persistence.table

import java.util.*
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IdTable
import org.jetbrains.exposed.sql.Column
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone

object NewFeedbackTable : IdTable<UUID>("new_feedback") {
    val event = reference("event_id", EventTable.id, onDelete = ReferenceOption.CASCADE)
    val account = reference("account_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
    val lastFeedbackReceived = timestampWithTimeZone("last_feedback_received")
    val newFeedback = integer("new_feedback")
    override val id: Column<EntityID<UUID>> = event
}
