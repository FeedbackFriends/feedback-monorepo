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
import net.fortuna.ical4j.data.CalendarBuilder
import net.fortuna.ical4j.model.Parameter
import net.fortuna.ical4j.model.Property
import net.fortuna.ical4j.model.TimeZoneRegistry
import net.fortuna.ical4j.model.TimeZoneRegistryFactory
import net.fortuna.ical4j.model.component.VEvent
import net.fortuna.ical4j.model.parameter.TzId
import net.fortuna.ical4j.model.property.Attendee
import net.fortuna.ical4j.model.property.DateProperty
import net.fortuna.ical4j.model.property.Description
import net.fortuna.ical4j.model.property.Duration
import net.fortuna.ical4j.model.property.DtEnd
import net.fortuna.ical4j.model.property.DtStart
import net.fortuna.ical4j.model.property.Location
import net.fortuna.ical4j.model.property.Organizer
import net.fortuna.ical4j.model.property.Summary
import org.eclipse.angus.mail.imap.IMAPFolder
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import java.io.InputStream
import java.time.Instant
import java.time.OffsetDateTime
import java.time.ZoneOffset
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
            "Parsed calendar invite: {}",
            mapOf(
                "title" to invite.title,
                "agenda" to invite.agenda,
                "date" to invite.date,
                "durationMinutes" to invite.durationInMinutes,
                "location" to invite.location,
                "managerEmail" to invite.managerEmail,
                "attendees" to invite.attendingEmails,
            ),
        )
    }

    private fun BodyPart.isCalendarAttachment(): Boolean {
        val isAttachment = disposition?.equals(Part.ATTACHMENT, ignoreCase = true) == true || fileName != null
        return isAttachment && isMimeType("text/calendar")
    }
}

internal data class CalendarInvite(
    val title: String,
    val agenda: String?,
    val date: OffsetDateTime,
    val durationInMinutes: Int,
    val location: String?,
    val managerEmail: String,
    val attendingEmails: List<String>,
)

internal object CalendarInviteParser {
    private val builder = CalendarBuilder()
    private val timeZoneRegistry = TimeZoneRegistryFactory.getInstance().createRegistry()

    fun parse(inputStream: InputStream): CalendarInvite {
        val calendar = builder.build(inputStream)
        val event = calendar.components
            .filterIsInstance<VEvent>()
            .firstOrNull() ?: throw IllegalArgumentException("No VEVENT found in calendar invite")

        val start = (event.getProperty(Property.DTSTART) as? DtStart)
            ?.toOffsetDateTime(timeZoneRegistry)
            ?: throw IllegalArgumentException("Missing DTSTART in calendar invite")

        val end = (event.getProperty(Property.DTEND) as? DtEnd)
            ?.toOffsetDateTime(timeZoneRegistry)

        val durationMinutes = (event.getProperty(Property.DURATION) as? Duration).toMinutes()
            ?: end?.let { java.time.Duration.between(start, it).toMinutes().toInt() }
            ?: 0

        val organizerEmail = (event.getProperty(Property.ORGANIZER) as? Organizer).email()
            ?: throw IllegalArgumentException("Missing organizer in calendar invite")

        return CalendarInvite(
            title = (event.getProperty(Property.SUMMARY) as? Summary)?.value.orEmpty(),
            agenda = (event.getProperty(Property.DESCRIPTION) as? Description)?.value,
            date = start,
            durationInMinutes = durationMinutes,
            location = (event.getProperty(Property.LOCATION) as? Location)?.value,
            managerEmail = organizerEmail,
            attendingEmails = event.attendeeEmails(excludeEmail = organizerEmail),
        )
    }

    private fun Duration?.toMinutes(): Int? = this?.duration?.let {
        runCatching { java.time.Duration.from(it).toMinutes().toInt() }.getOrNull()
    }

    private fun Organizer?.email(): String? =
        this?.calAddress?.schemeSpecificPart
            ?.removePrefix("mailto:")
            ?.removePrefix("MAILTO:")
            ?.trim()
            ?.takeIf { it.isNotEmpty() }

    private fun VEvent.attendeeEmails(excludeEmail: String?): List<String> =
        properties.getProperties<Attendee>(Property.ATTENDEE)
            .mapNotNull { attendee ->
                attendee.calAddress?.schemeSpecificPart
                    ?.removePrefix("mailto:")
                    ?.removePrefix("MAILTO:")
                    ?.trim()
                    ?.takeIf { it.isNotEmpty() }
            }.filterNot { email -> excludeEmail != null && email.equals(excludeEmail, ignoreCase = true) }

    private fun DtStart.toOffsetDateTime(timeZoneRegistry: TimeZoneRegistry): OffsetDateTime? =
        toOffsetDateTimeInternal(timeZoneRegistry)

    private fun DtEnd.toOffsetDateTime(timeZoneRegistry: TimeZoneRegistry): OffsetDateTime? =
        toOffsetDateTimeInternal(timeZoneRegistry)

    private fun DtStart.toOffsetDateTimeInternal(timeZoneRegistry: TimeZoneRegistry): OffsetDateTime? =
        (this as DateProperty).toOffsetDateTime(timeZoneRegistry)

    private fun DtEnd.toOffsetDateTimeInternal(timeZoneRegistry: TimeZoneRegistry): OffsetDateTime? =
        (this as DateProperty).toOffsetDateTime(timeZoneRegistry)

    private fun DateProperty.toOffsetDateTime(timeZoneRegistry: TimeZoneRegistry): OffsetDateTime? {
        val zone = timeZone?.let { tz ->
            runCatching { tz.toZoneId() }.getOrNull()
                ?: ZoneOffset.ofTotalSeconds(tz.getOffset(date?.time ?: System.currentTimeMillis()) / 1000)
        }
            ?: (parameters.getParameter(Parameter.TZID) as? TzId)
                ?.value
                ?.let { zoneId ->
                    timeZoneRegistry.getTimeZone(zoneId)?.let { tz ->
                        runCatching { tz.toZoneId() }.getOrNull()
                    }
                }
            ?: ZoneOffset.UTC
        val dateValue = date ?: return null
        val instant = Instant.ofEpochMilli(dateValue.time)
        return instant.atZone(zone).toOffsetDateTime()
    }
}
