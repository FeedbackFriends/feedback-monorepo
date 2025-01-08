package dk.example.feedback.persistence.table

import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IdTable
import org.jetbrains.exposed.sql.Column
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone


object AccountTable: IdTable<String>("account") {

    override val id: Column<EntityID<String>> = varchar("id", 255).entityId()
    override val primaryKey = PrimaryKey(id)

    val name = varchar("name", 255).nullable() // is never null if user is not anonymous
    val fcmToken = varchar("fcm_token", 255).nullable()
    val email =  varchar("email", 255).nullable() // is never null if user is not anonymous
    val phoneNumber = varchar("phone_number", 255).nullable()
    val createdAt = timestampWithTimeZone("created_at")
    val updatedAt = timestampWithTimeZone("updated_at")
    val ratingPrompted = bool("rating_prompted").default(false)
}
