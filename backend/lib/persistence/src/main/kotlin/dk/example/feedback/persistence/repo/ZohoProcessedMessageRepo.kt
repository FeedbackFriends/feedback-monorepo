package dk.example.feedback.persistence.repo

import dk.example.feedback.persistence.table.ZohoProcessedMessageTable
import java.sql.SQLException
import java.time.OffsetDateTime
import java.time.ZoneOffset
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.isNull
import org.jetbrains.exposed.sql.SqlExpressionBuilder.less
import org.jetbrains.exposed.sql.and
import org.jetbrains.exposed.sql.deleteWhere
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.update
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional

@Component
@Transactional
class ZohoProcessedMessageRepo {

    private val logger = LoggerFactory.getLogger(ZohoProcessedMessageRepo::class.java)
    private val claimTtlMinutes = 10L

    fun getMessage(messageId: String): ZohoProcessedMessage? {
        val row = ZohoProcessedMessageTable
            .selectAll()
            .where { ZohoProcessedMessageTable.id eq messageId }
            .firstOrNull()
            ?: return null
        return ZohoProcessedMessage(
            messageId = row[ZohoProcessedMessageTable.id].value,
            processedAt = row[ZohoProcessedMessageTable.processedAt],
            status = row[ZohoProcessedMessageTable.status],
            statusMessage = row[ZohoProcessedMessageTable.statusMessage],
            archiveStatus = row[ZohoProcessedMessageTable.archiveStatus],
            archiveMessage = row[ZohoProcessedMessageTable.archiveMessage],
            archivedAt = row[ZohoProcessedMessageTable.archivedAt],
        )
    }

    fun tryClaim(
        messageId: String,
        mailboxId: String,
        receivedTime: Long,
        subject: String?,
        fromAddress: String?,
        hasAttachment: Boolean?,
        status: String,
    ): Boolean {
        val now = OffsetDateTime.now(ZoneOffset.UTC)
        return runCatching {
            ZohoProcessedMessageTable.insert {
                it[id] = EntityID(messageId, ZohoProcessedMessageTable)
                it[this.mailboxId] = mailboxId
                it[this.receivedTime] = receivedTime
                it[this.subject] = subject
                it[this.fromAddress] = fromAddress
                it[this.hasAttachment] = hasAttachment
                it[this.status] = status
                it[this.createdAt] = now
                it[this.processedAt] = null
            }
            true
        }.getOrElse { ex ->
            if (ex.isUniqueViolation()) {
                val reclaimed = reclaimStaleClaim(
                    messageId = messageId,
                    mailboxId = mailboxId,
                    receivedTime = receivedTime,
                    subject = subject,
                    fromAddress = fromAddress,
                    hasAttachment = hasAttachment,
                    status = status,
                )
                if (reclaimed) {
                    logger.warn("Reclaimed stale Zoho message claim messageId={}", messageId)
                }
                reclaimed
            } else {
                throw ex
            }
        }
    }

    fun markProcessed(messageId: String, status: String, statusMessage: String?) {
        val now = OffsetDateTime.now(ZoneOffset.UTC)
        ZohoProcessedMessageTable.update({ ZohoProcessedMessageTable.id eq messageId }) {
            it[processedAt] = now
            it[this.status] = status
            it[this.statusMessage] = statusMessage
        }
    }

    fun markArchiveStatus(messageId: String, status: ArchiveStatus, statusMessage: String?) {
        val now = OffsetDateTime.now(ZoneOffset.UTC)
        ZohoProcessedMessageTable.update({ ZohoProcessedMessageTable.id eq messageId }) {
            it[archiveStatus] = status.name
            it[archiveMessage] = statusMessage
            if (status == ArchiveStatus.SUCCESS) {
                it[archivedAt] = now
            }
        }
    }

    fun releaseClaim(messageId: String) {
        ZohoProcessedMessageTable.deleteWhere {
            (ZohoProcessedMessageTable.id eq messageId) and ZohoProcessedMessageTable.processedAt.isNull()
        }
    }

    private fun reclaimStaleClaim(
        messageId: String,
        mailboxId: String,
        receivedTime: Long,
        subject: String?,
        fromAddress: String?,
        hasAttachment: Boolean?,
        status: String,
    ): Boolean {
        val now = OffsetDateTime.now(ZoneOffset.UTC)
        val cutoff = now.minusMinutes(claimTtlMinutes)
        val updated = ZohoProcessedMessageTable.update({
            (ZohoProcessedMessageTable.id eq messageId) and
                ZohoProcessedMessageTable.processedAt.isNull() and
                (ZohoProcessedMessageTable.createdAt less cutoff)
        }) {
            it[this.mailboxId] = mailboxId
            it[this.receivedTime] = receivedTime
            it[this.subject] = subject
            it[this.fromAddress] = fromAddress
            it[this.hasAttachment] = hasAttachment
            it[this.status] = status
            it[this.createdAt] = now
        }
        return updated > 0
    }
}

data class ZohoProcessedMessage(
    val messageId: String,
    val processedAt: OffsetDateTime?,
    val status: String?,
    val statusMessage: String?,
    val archiveStatus: String?,
    val archiveMessage: String?,
    val archivedAt: OffsetDateTime?,
)

enum class ArchiveStatus {
    SUCCESS,
    FAILED,
}

private fun Throwable.isUniqueViolation(): Boolean {
    val state = when (this) {
        is SQLException -> this.sqlState
        else -> (cause as? SQLException)?.sqlState
    }
    return state == "23505"
}
