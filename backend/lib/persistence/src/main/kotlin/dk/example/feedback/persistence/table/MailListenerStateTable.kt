package dk.example.feedback.persistence.table

import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IdTable
import org.jetbrains.exposed.sql.Column
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone

object MailListenerStateTable : IdTable<String>("mail_listener_state") {
    val mailboxId = varchar("mailbox_id", 512)
    val lastProcessedUid = long("last_processed_uid")
    val lastProcessedMessageId = varchar("last_processed_message_id", 512).nullable()
    val updatedAt = timestampWithTimeZone("updated_at")
    override val id: Column<EntityID<String>> = mailboxId.entityId()
}
