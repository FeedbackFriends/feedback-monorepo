package dk.example.feedback.persistence.table

import dk.example.feedback.model.enumerations.SupportSubmissionKind
import dk.example.feedback.model.enumerations.Emoji
import org.jetbrains.exposed.dao.id.UUIDTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone

/** Product contact only. Deleting the account removes its contact text and metadata. */
object SupportSubmissionTable : UUIDTable("support_submission") {
    val account = reference("account_id", AccountTable, onDelete = ReferenceOption.CASCADE)
    val kind = enumerationByName("kind", 32, SupportSubmissionKind::class)
    val rating = enumerationByName("rating", 32, Emoji::class).nullable()
    val message = varchar("message", 5000).nullable()
    val expectedBehavior = varchar("expected_behavior", 5000).nullable()
    val contactEmail = varchar("contact_email", 254).nullable()
    val appVersion = varchar("app_version", 100)
    val appBuild = varchar("app_build", 100)
    val osVersion = varchar("os_version", 100)
    val createdAt = timestampWithTimeZone("created_at")
}
