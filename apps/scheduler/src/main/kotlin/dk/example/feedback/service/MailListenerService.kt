package dk.example.feedback.service

import jakarta.mail.BodyPart
import jakarta.mail.Folder
import jakarta.mail.Message
import jakarta.mail.MessagingException
import jakarta.mail.Multipart
import jakarta.mail.Part
import jakarta.mail.Session
import jakarta.mail.Store
import jakarta.mail.event.MessageCountAdapter
import jakarta.mail.event.MessageCountEvent
import org.eclipse.angus.mail.imap.IMAPFolder
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import java.io.InputStream
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.OffsetDateTime
import java.time.ZoneId
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import java.util.Properties
import javax.annotation.PostConstruct
import javax.annotation.PreDestroy
import kotlin.concurrent.thread

@Service
class MailListenerService(
    @Value("\${mail.host}") private val host: String,
    @Value("\${mail.port:993}") private val port: Int,
    @Value("\${mail.username}") private val username: String,
    @Value("\${mail.password}") private val password: String,
    @Value("\${mail.folder:INBOX}") private val folderName: String,
) {

    private val logger = LoggerFactory.getLogger(MailListenerService::class.java)
    private var store: Store? = null
    private var folder: IMAPFolder? = null
    @Volatile
    private var running = true

    @PostConstruct
    fun startListener() {
        thread(name = "imap-listener", isDaemon = true) {
            while (running) {
                try {
                    connectAndListen()
                } catch (ex: Exception) {
                    logger.warn("IMAP listener error, retrying in 10 seconds", ex)
                    sleepWithCatch(10_000L)
                } finally {
                    closeResources()
                }
            }
        }
    }

    private fun connectAndListen() {
        val properties = Properties().apply {
            put("mail.store.protocol", "imaps")
            put("mail.imaps.host", host)
            put("mail.imaps.port", "$port")
            put("mail.imaps.ssl.enable", "true")
        }

        val session = Session.getInstance(properties, null)
        store = session.getStore("imaps").apply { connect(host, port, username, password) }

        folder = (store?.getFolder(folderName) as? IMAPFolder)?.apply {
            open(Folder.READ_ONLY)
            addMessageCountListener(object : MessageCountAdapter() {
                override fun messagesAdded(event: MessageCountEvent) {
                    event.messages.forEach { message ->
                        processMessage(message)
                    }
                }
            })
        } ?: throw MessagingException("Folder $folderName is not an IMAP folder")

        while (running && store?.isConnected == true) {
            try {
                folder?.idle()
            } catch (ex: MessagingException) {
                logger.warn("IMAP idle interrupted, reconnecting", ex)
                break
            }
        }
    }

    private fun closeResources() {
        try {
            folder?.close()
        } catch (_: Exception) {
        } finally {
            folder = null
        }

        try {
            store?.close()
        } catch (_: Exception) {
        } finally {
            store = null
        }
    }

    private fun sleepWithCatch(delayMillis: Long) {
        try {
            Thread.sleep(delayMillis)
        } catch (_: InterruptedException) {
            Thread.currentThread().interrupt()
        }
    }

    @PreDestroy
    fun shutdown() {
        running = false
        closeResources()
    }

    private fun processMessage(message: Message) {
        logger.info(
            "Received email from={} subject={}",
            message.from?.joinToString(),
            message.subject,
        )
        runCatching { parseCalendarInvites(message) }
            .onFailure {
                logger.warn("Failed to parse calendar invites for subject={}", message.subject, it)
            }
    }

    private fun parseCalendarInvites(message: Message) {
        val content = message.content
        when (content) {
            is Multipart -> parseMultipartInvites(content)
            is String -> if (message.isMimeType("text/calendar")) {
                content.byteInputStream().use { stream ->
                    logCalendarInvite(CalendarInviteParser.parse(stream))
                }
            }
        }
    }

    private fun parseMultipartInvites(multipart: Multipart) {
        repeat(multipart.count) { index ->
            val bodyPart = multipart.getBodyPart(index)
            if (bodyPart.isCalendarAttachment()) {
                runCatching {
                    bodyPart.inputStream.use { stream ->
                        CalendarInviteParser.parse(stream)
                    }
                }.onSuccess { invite -> logCalendarInvite(invite) }
                    .onFailure {
                        logger.warn("Failed to parse calendar invite from attachment {}", bodyPart.fileName, it)
                    }
            }
        }
    }

    private fun logCalendarInvite(invite: CalendarInvite) {
        logger.info(
            "Calendar invite parsed date={} title={} description={} attendees={}",
            invite.formattedStart(),
            invite.summary.orEmpty(),
            invite.description.orEmpty(),
            invite.attendees.joinToString(),
        )
    }

    private fun BodyPart.isCalendarAttachment(): Boolean {
        val isAttachment = disposition?.equals(Part.ATTACHMENT, ignoreCase = true) == true || fileName != null
        return isAttachment && isMimeType("text/calendar")
    }
}

internal data class CalendarInvite(
    val start: ZonedDateTime?,
    val summary: String?,
    val description: String?,
    val attendees: List<String>,
) {
    fun formattedStart(): String = start?.format(DateTimeFormatter.ISO_OFFSET_DATE_TIME) ?: "unknown"
}

internal object CalendarInviteParser {
    private val localDateTimeFormatter = DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmmss")
    private val offsetDateTimeFormatter = DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmmssX")

    fun parse(inputStream: InputStream): CalendarInvite {
        val lines = inputStream.bufferedReader().use { reader ->
            unfoldLines(reader.readLines())
        }
        var summary: String? = null
        var description: String? = null
        var start: ZonedDateTime? = null
        val attendees = mutableListOf<String>()

        lines.forEach { line ->
            when {
                line.startsWith("SUMMARY", ignoreCase = true) -> summary = line.substringAfter(":", "").trim()
                line.startsWith("DESCRIPTION", ignoreCase = true) -> {
                    val raw = line.substringAfter(":", "")
                    description = unescapeText(raw).trim()
                }
                line.startsWith("DTSTART", ignoreCase = true) -> {
                    val meta = line.substringBefore(":", "")
                    val value = line.substringAfter(":", "")
                    start = parseStartDate(meta, value)
                }
                line.startsWith("ATTENDEE", ignoreCase = true) -> {
                    val attendeeValue = line.substringAfter(":", "")
                    extractEmail(attendeeValue)?.let { attendees += it }
                }
            }
        }

        return CalendarInvite(start, summary, description, attendees)
    }

    private fun parseStartDate(meta: String, value: String): ZonedDateTime? {
        val zoneId = meta.substringAfter("TZID=", "").takeIf { it.isNotBlank() }
        return parseDateTime(value, zoneId)
    }

    private fun parseDateTime(value: String, zoneId: String?): ZonedDateTime? {
        val zone = zoneId?.let { safeZone(it) } ?: ZoneId.systemDefault()
        return when {
            value.endsWith("Z") -> runCatching {
                OffsetDateTime.parse(value, offsetDateTimeFormatter).atZoneSameInstant(zone)
            }.getOrNull()
            value.length == 8 -> runCatching {
                LocalDate.parse(value, DateTimeFormatter.BASIC_ISO_DATE).atStartOfDay(zone)
            }.getOrNull()
            else -> runCatching {
                LocalDateTime.parse(value, localDateTimeFormatter).atZone(zone)
            }.getOrNull()
        }
    }

    private fun safeZone(zoneId: String): ZoneId =
        runCatching { ZoneId.of(zoneId) }.getOrDefault(ZoneId.systemDefault())

    private fun extractEmail(attendeeValue: String): String? {
        val mailtoIndex = attendeeValue.lowercase().indexOf("mailto:")
        val email = if (mailtoIndex >= 0) {
            attendeeValue.substring(mailtoIndex + "mailto:".length)
        } else {
            attendeeValue
        }
        return email.trim().takeIf { it.isNotBlank() }
    }

    private fun unescapeText(value: String): String =
        value.replace("\\n", "\n").replace("\\,", ",")

    private fun unfoldLines(lines: List<String>): List<String> {
        val unfolded = mutableListOf<String>()
        lines.forEach { raw ->
            val line = raw.trimEnd('\r')
            if (line.startsWith(" ") || line.startsWith("\t")) {
                if (unfolded.isNotEmpty()) {
                    unfolded[unfolded.lastIndex] = unfolded.last() + line.trimStart()
                }
            } else {
                unfolded.add(line)
            }
        }
        return unfolded
    }
}
