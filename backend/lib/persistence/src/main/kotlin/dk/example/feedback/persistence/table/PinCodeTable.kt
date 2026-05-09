package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.table.PinCodeTable.code
import dk.example.feedback.persistence.table.PinCodeTable.session
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IdTable
import org.jetbrains.exposed.sql.Column
import org.jetbrains.exposed.sql.ReferenceOption

/**
 * Table for managing session pin codes.
 *
 * Each row links a unique pin code to a session, providing access control for participants.
 *
 * Relationships:
 * - References [SessionTable] (session).
 * - Deleting a session cascades and removes its pin codes.
 *
 * Columns:
 * @property code The pin code string (primary key).
 * @property session Foreign key to [SessionTable.id].
 */
object PinCodeTable : IdTable<String>("pin_code") {
    val code = varchar("code", 255)
    val session = reference("session_id", SessionTable, onDelete = ReferenceOption.CASCADE)
    val event = session
    override val id: Column<EntityID<String>> = code.entityId()
}
