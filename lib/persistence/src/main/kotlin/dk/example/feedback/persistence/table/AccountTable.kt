package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.table.AccountTable.createdAt
import dk.example.feedback.persistence.table.AccountTable.email
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
 * Table for storing user accounts.
 *
 * Each row represents a unique user, identified by a UID from Firebase Authentication. Stores user metadata and notification tokens.
 *
 * Relationships:
 * - Referenced by events, feedback, and other tables as the account owner or participant.
 * - Deleting an account cascades to related entries in dependent tables.
 *
 * Columns:
 * @property id Unique account identifier (Firebase UID). Primary key.
 * @property name Optional display name for the user.
 * @property email Optional email address.
 * @property phoneNumber Optional phone number.
 * @property createdAt Timestamp when the account was created.
 * @property updatedAt Timestamp when the account was last updated.
 * @property ratingPrompted Whether the user has been prompted for an app rating.
 */
object AccountTable: IdTable<String>("account") {

    override val id: Column<EntityID<String>> = varchar("id", 255).entityId()
    override val primaryKey = PrimaryKey(id)

    val name = varchar("name", 255).nullable()
    val email = varchar("email", 255).nullable()
    val phoneNumber = varchar("phone_number", 255).nullable()
    val createdAt = timestampWithTimeZone("created_at")
    val updatedAt = timestampWithTimeZone("updated_at")
    val ratingPrompted = bool("rating_prompted")
}


