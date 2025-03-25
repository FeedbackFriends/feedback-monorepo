package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.table.AccountTable.createdAt
import dk.example.feedback.persistence.table.AccountTable.email
import dk.example.feedback.persistence.table.AccountTable.fcmToken
import dk.example.feedback.persistence.table.AccountTable.id
import dk.example.feedback.persistence.table.AccountTable.name
import dk.example.feedback.persistence.table.AccountTable.phoneNumber
import dk.example.feedback.persistence.table.AccountTable.ratingPrompted
import dk.example.feedback.persistence.table.AccountTable.updatedAt
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IdTable
import org.jetbrains.exposed.sql.Column
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone

/**
 * Exposed table definition for user accounts.
 *
 * @property id Unique identifier for the account. This is a UID provided by Firebase Authentication.
 * @property name Optional name of the user. Non-null if the user is not anonymous.
 * @property fcmToken Optional Firebase Cloud Messaging token for push notifications.
 * @property email Optional email of the user. Non-null if the user is not anonymous.
 * @property phoneNumber Optional phone number of the user.
 * @property createdAt Timestamp when the account was created.
 * @property updatedAt Timestamp when the account was last updated.
 * @property ratingPrompted Boolean flag indicating whether the user has been prompted for an app rating.
 */
object AccountTable: IdTable<String>("account") {

    override val id: Column<EntityID<String>> = varchar("id", 255).entityId()
    override val primaryKey = PrimaryKey(id)

    val name = varchar("name", 255).nullable()
    val fcmToken = varchar("fcm_token", 255).nullable()
    val email = varchar("email", 255).nullable()
    val phoneNumber = varchar("phone_number", 255).nullable()
    val createdAt = timestampWithTimeZone("created_at")
    val updatedAt = timestampWithTimeZone("updated_at")
    val ratingPrompted = bool("rating_prompted")
}
