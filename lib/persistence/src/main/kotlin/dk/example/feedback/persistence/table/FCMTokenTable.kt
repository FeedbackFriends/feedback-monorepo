package dk.example.feedback.persistence.table

import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IdTable
import org.jetbrains.exposed.sql.Column
import org.jetbrains.exposed.sql.ReferenceOption

object FCMTokenTable : IdTable<String>("fcm_token") {
    val account = reference("account_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
    val value = varchar("value", 255)
    override val id: Column<EntityID<String>> = value.entityId()
}
