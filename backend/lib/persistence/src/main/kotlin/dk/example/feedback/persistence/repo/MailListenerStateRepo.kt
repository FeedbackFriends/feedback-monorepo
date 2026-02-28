package dk.example.feedback.persistence.repo

import dk.example.feedback.persistence.table.MailListenerStateTable
import java.time.OffsetDateTime
import java.time.ZoneOffset
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.sql.insertIgnore
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.update
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional

@Component
@Transactional
class MailListenerStateRepo {

    fun getState(mailboxId: String): MailListenerState? {
        return MailListenerStateTable
            .selectAll()
            .where { MailListenerStateTable.id eq mailboxId }
            .firstOrNull()
            ?.let { row ->
                MailListenerState(
                    lastProcessedReceivedTime = row[MailListenerStateTable.lastProcessedUid],
                )
            }
    }

    fun updateState(mailboxId: String, receivedTime: Long) {
        val now = OffsetDateTime.now(ZoneOffset.UTC)
        MailListenerStateTable.insertIgnore {
            it[id] = EntityID(mailboxId, MailListenerStateTable)
            it[MailListenerStateTable.lastProcessedUid] = receivedTime
            it[MailListenerStateTable.updatedAt] = now
        }
        MailListenerStateTable.update({ MailListenerStateTable.id eq mailboxId }) {
            it[MailListenerStateTable.lastProcessedUid] = receivedTime
            it[MailListenerStateTable.updatedAt] = now
        }
    }
}

data class MailListenerState(
    val lastProcessedReceivedTime: Long,
)
