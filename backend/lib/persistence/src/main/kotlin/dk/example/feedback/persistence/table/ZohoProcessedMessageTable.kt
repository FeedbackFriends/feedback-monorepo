package dk.example.feedback.persistence.table

import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IdTable
import org.jetbrains.exposed.sql.Column
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone

object ZohoProcessedMessageTable : IdTable<String>("zoho_processed_message") {
    val messageId = varchar("message_id", 512)
    val mailboxId = varchar("mailbox_id", 512)
    val receivedTime = long("received_time")
    val subject = varchar("subject", 512).nullable()
    val fromAddress = varchar("from_address", 512).nullable()
    val hasAttachment = bool("has_attachment").nullable()
    val status = varchar("status", 64).nullable()
    val statusMessage = text("status_message").nullable()
    val archiveStatus = varchar("archive_status", 64).nullable()
    val archiveMessage = text("archive_message").nullable()
    val archivedAt = timestampWithTimeZone("archived_at").nullable()
    val createdAt = timestampWithTimeZone("created_at")
    val processedAt = timestampWithTimeZone("processed_at").nullable()
    override val id: Column<EntityID<String>> = messageId.entityId()
}
