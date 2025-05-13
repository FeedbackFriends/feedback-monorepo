package dk.example.feedback.persistence.table

import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IdTable
import org.jetbrains.exposed.sql.Column
import org.jetbrains.exposed.sql.ReferenceOption

object FCMTokenTable : IdTable<String>("fcm_token") {
    override val id: Column<EntityID<String>> = varchar("value", 255).entityId().uniqueIndex()
    val account = reference("account_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
}
