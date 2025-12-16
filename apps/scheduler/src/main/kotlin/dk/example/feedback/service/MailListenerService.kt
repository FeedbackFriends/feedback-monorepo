package dk.example.feedback.service

import dk.example.feedback.FeedbackConfig
import dk.example.feedback.model.enumerations.CalendarProvider
import dk.example.feedback.persistence.pincodegenerator.PinCodeGenerator
import dk.example.feedback.persistence.repo.AccountRepo
import dk.example.feedback.persistence.repo.EventRepo
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
import org.springframework.stereotype.Service
import java.time.OffsetDateTime
import java.util.Properties
import javax.annotation.PostConstruct
import kotlin.concurrent.thread

@Service
class MailListenerService(
    private val feedbackConfig: FeedbackConfig,
    private val eventRepo: EventRepo,
    private val accountRepo: AccountRepo,
) {

    private val logger = LoggerFactory.getLogger(MailListenerService::class.java)
    private val mailSettings get() = feedbackConfig.mail
    private var store: Store? = null
    private var folder: IMAPFolder? = null
    @Volatile
    private var running = true

    @PostConstruct
    fun startListener() {
        logger.info("Starting IMAP listener for host={} folder={}", mailSettings.host, mailSettings.folder)
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
        val settings = mailSettings
        val properties = Properties().apply {
            put("mail.store.protocol", "imaps")
            put("mail.imaps.host", settings.host)
            put("mail.imaps.port", "${settings.port}")
            put("mail.imaps.ssl.enable", "true")
        }

        val session = Session.getInstance(properties, null)
        store = session.getStore("imaps").apply {
            connect(settings.host, settings.port, settings.username, settings.password)
        }
        logger.info("Connected to IMAP host={} port={} folder={}", settings.host, settings.port, settings.folder)

        folder = (store?.getFolder(settings.folder) as? IMAPFolder)?.apply {
            open(Folder.READ_ONLY)
            addMessageCountListener(object : MessageCountAdapter() {
                override fun messagesAdded(event: MessageCountEvent) {
                    event.messages.forEach { message ->
                        processMessage(message)
                    }
                }
            })
        } ?: throw MessagingException("Folder ${settings.folder} is not an IMAP folder")
        logger.info("IMAP folder {} opened; waiting for new messages", settings.folder)

        while (running && store?.isConnected == true) {
            try {
                folder?.idle()
            } catch (ex: MessagingException) {
                logger.warn("IMAP idle interrupted, reconnecting", ex)
                break
            }
        }
    }

    private fun persistsEvent(calendarInvite: CalendarInvite) {
        val generatedPincode = PinCodeGenerator(eventRepo = eventRepo).generate()
        val account = accountRepo.getAccountFromEmail(emailInput = calendarInvite.managerEmail)
        if (account == null) {
            logger.warn("Mail listener does not exist so event will not be persisted")
            return
        }
        logger.info(
            "Persisting event from calendar invite title={} date={} managerEmail={}",
            calendarInvite.title,
            calendarInvite.date,
            calendarInvite.managerEmail,
        )
        runCatching {
            eventRepo.persistEvent(
                title = calendarInvite.title,
                agenda = calendarInvite.agenda,
                date = calendarInvite.date,
                location = calendarInvite.location,
                durationInMinutes = calendarInvite.durationInMinutes,
                generatedPinCode = generatedPincode,
                questions = emptyList(),
                managerId = account.id,
                createdFromMailListener = true,
                invitedEmails = calendarInvite.attendingEmails,
                calendarProvider = calendarInvite.calendarProvider,
            )
        }.onSuccess { event ->
            logger.info(
                "Event persisted id={} titleLength={} agendaLength={} locationLength={}",
                event.id,
                calendarInvite.title.length,
                calendarInvite.agenda?.length ?: 0,
                calendarInvite.location?.length ?: 0,
            )
        }.onFailure { ex ->
            logger.warn(
                "Failed to persist calendar invite titleLength={} agendaLength={} locationLength={} provider={} managerEmail={}",
                calendarInvite.title.length,
                calendarInvite.agenda?.length ?: 0,
                calendarInvite.location?.length ?: 0,
                calendarInvite.calendarProvider,
                calendarInvite.managerEmail,
                ex,
            )
            throw ex
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
            logger.info("Disconnected from IMAP store and cleared folder references")
        }
    }

    private fun sleepWithCatch(delayMillis: Long) {
        try {
            Thread.sleep(delayMillis)
        } catch (_: InterruptedException) {
            Thread.currentThread().interrupt()
        }
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
        when {
            message.isMimeType("multipart/*") -> {
                val content = message.content
                if (content is Multipart) parseMultipartInvites(content)
            }
            message.isMimeType("text/calendar") -> {
                message.inputStream.use { stream ->
                    persistsEvent(CalendarInviteParser.parse(stream))
                }
            }
            // Some providers hand back text/calendar as shared input streams without multipart.
            message.contentType.contains("text/calendar", ignoreCase = true) -> {
                message.inputStream.use { stream ->
                    persistsEvent(CalendarInviteParser.parse(stream))
                }
            }
            else -> logger.debug("No calendar content detected for subject={}", message.subject)
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
                }.onSuccess { invite ->
                    persistsEvent(invite)
                }.onFailure {
                    logger.warn("Failed to parse calendar invite from attachment {}", bodyPart.fileName, it)
                }
            } else {
                logger.debug("Skipping non-calendar part at index={} type={}", index, bodyPart.contentType)
            }
        }
    }

    private fun BodyPart.isCalendarAttachment(): Boolean {
        val contentTypeLower = contentType.lowercase()
        val hasCalendarMime = isMimeType("text/calendar") ||
            contentTypeLower.contains("text/calendar") ||
            contentTypeLower.contains("application/ics") ||
            contentTypeLower.contains("application/calendar")
        if (!hasCalendarMime && fileName?.lowercase()?.endsWith(".ics") != true) return false
        // Accept both real attachments and inline calendar parts (some providers omit disposition/filename).
        return disposition?.equals(Part.ATTACHMENT, ignoreCase = true) == true ||
            fileName != null ||
            hasCalendarMime
    }
}

data class CalendarInvite(
    val title: String,
    val agenda: String?,
    val date: OffsetDateTime,
    val durationInMinutes: Int,
    val location: String?,
    val managerEmail: String,
    val attendingEmails: List<String>,
    val calendarProvider: CalendarProvider?,
)
