package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.table.PinCodeTable.code
import dk.example.feedback.persistence.table.PinCodeTable.event
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IdTable
import org.jetbrains.exposed.sql.Column
import org.jetbrains.exposed.sql.ReferenceOption

/**
 * Table definition for pin codes used to access events.
 *
 * This table manages the pin codes that are used to secure access to events.
 * Each pin code is uniquely associated with an event and serves as a security measure
 * to ensure only authorized participants can access the event.
 *
 * The table uses the pin code itself as the primary key, ensuring uniqueness across
 * all events in the system.
 *
 * @property code The actual pin code string. Maximum length: 255 characters.
 *                This field serves as both the primary key and the access credential.
 * @property event A foreign key reference to the associated event in [EventTable].
 *                 When an event is deleted, all associated pin codes are automatically
 *                 deleted due to the CASCADE delete option.
 */
object PinCodeTable : IdTable<String>("pin_code") {
    val code = varchar("code", 255)
    val event = reference("event_id", EventTable, onDelete = ReferenceOption.CASCADE)
    override val id: Column<EntityID<String>> = code.entityId()
}
