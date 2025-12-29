package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.table.PinCodeTable.code
import dk.example.feedback.persistence.table.PinCodeTable.event
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IdTable
import org.jetbrains.exposed.sql.Column
import org.jetbrains.exposed.sql.ReferenceOption

/**
 * Table for managing event pin codes.
 *
 * Each row links a unique pin code to an event, providing access control for participants.
 *
 * Relationships:
 * - References [EventTable] (event).
 * - Deleting an event cascades and removes its pin codes.
 *
 * Columns:
 * @property code The pin code string (primary key).
 * @property event Foreign key to [EventTable.id].
 */
object PinCodeTable : IdTable<String>("pin_code") {
    val code = varchar("code", 255)
    val event = reference("event_id", EventTable, onDelete = ReferenceOption.CASCADE)
    override val id: Column<EntityID<String>> = code.entityId()
}
