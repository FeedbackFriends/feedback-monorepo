package dk.example.feedback.persistence.table

import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IdTable
import org.jetbrains.exposed.sql.Column
import org.jetbrains.exposed.sql.ReferenceOption

object PinCodeTable : IdTable<String>("pin_code") {
    val pinCode = varchar("pin_code", 255)
    val event = reference("event_id", EventTable, onDelete = ReferenceOption.CASCADE)
    override val id: Column<EntityID<String>> = pinCode.entityId()
}
