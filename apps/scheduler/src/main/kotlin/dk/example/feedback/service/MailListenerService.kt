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
import org.springframework.context.SmartLifecycle
import org.springframework.stereotype.Service
import java.time.OffsetDateTime
import java.util.Properties
import java.util.concurrent.Executors
import java.util.concurrent.Future
import java.util.concurrent.atomic.AtomicBoolean

@Service
class MailListenerService(
    private val feedbackConfig: FeedbackConfig,
    private val eventRepo: EventRepo,
    private val accountRepo: AccountRepo,
    private val pinCodeGenerator: PinCodeGenerator = PinCodeGenerator(eventRepo),
) : SmartLifecycle {

    private val logger = LoggerFactory.getLogger(MailListenerService::class.java)
    private val mailSettings get() = feedbackConfig.mail
    private val running = AtomicBoolean(false)
    private val executor = Executors.newSingleThreadExecutor { runnable ->
        Thread(runnable, "imap-listener").apply { isDaemon = true }
    }
    @Volatile private var listenerFuture: Future<*>? = null
    @Volatile private var store: Store? = null
    @Volatile private var folder: IMAPFolder? = null

    override fun start() {
        if (!running.compareAndSet(false, true)) return

        logger.info("Starting IMAP listener for host={} folder={}", mailSettings.host, mailSettings.folder)
        listenerFuture = executor.submit { listenLoop() }
    }

    override fun stop() {
        stop { }
    }

    override fun stop(callback: Runnable) {
        if (running.compareAndSet(true, false)) {
            logger.info("Stopping IMAP listener")
            listenerFuture?.cancel(true)
            closeResources()
        }
        callback.run()
    }

    override fun isRunning(): Boolean = running.get()
    override fun isAutoStartup(): Boolean = true
    override fun getPhase(): Int = 0

    private fun listenLoop() {
        var attempt = 0
        while (running.get()) {
            try {
                connectAndListen()
                attempt = 0
            } catch (ex: Exception) {
                attempt++
                val delay = reconnectDelayFor(attempt)
                logger.warn(
                    "IMAP listener error (attempt={}): {}; reconnecting in {} ms",
                    attempt,
                    ex.message,
                    delay,
                    ex,
                )
                sleepWithCatch(delay)
            } finally {
                closeResources()
            }
        }
    }

    private fun reconnectDelayFor(attempt: Int): Long = when {
        attempt <= 1 -> 1_000L
        attempt == 2 -> 5_000L
        else -> 10_000L
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

        while (running.get() && store?.isConnected == true) {
            try {
                folder?.idle()
            } catch (ex: MessagingException) {
                if (running.get()) {
                    logger.warn("IMAP idle interrupted, reconnecting", ex)
                } else {
                    logger.info("IMAP idle interrupted due to shutdown request")
                }
                break
            }
        }
    }

    private fun persistEvent(calendarInvite: CalendarInvite, metadata: MessageMetadata) {
        val generatedPincode = pinCodeGenerator.generate()
        val account = accountRepo.getAccountFromEmail(emailInput = calendarInvite.managerEmail)
        if (account == null) {
            logger.warn(
                "No account found for managerEmail={}, skipping invite subject={} messageId={}",
                calendarInvite.managerEmail,
                metadata.subject,
                metadata.messageId,
            )
            return
        }
        logger.info(
            "Persisting event from calendar invite title={} date={} managerEmail={} subject={} messageId={}",
            calendarInvite.title,
            calendarInvite.date,
            calendarInvite.managerEmail,
            metadata.subject,
            metadata.messageId,
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
                "Event persisted id={} titleLength={} agendaLength={} locationLength={} subject={} messageId={}",
                event.id,
                calendarInvite.title.length,
                calendarInvite.agenda?.length ?: 0,
                calendarInvite.location?.length ?: 0,
                metadata.subject,
                metadata.messageId,
            )
        }.onFailure { ex ->
            logger.warn(
                "Failed to persist calendar invite titleLength={} agendaLength={} locationLength={} provider={} managerEmail={} subject={} messageId={}",
                calendarInvite.title.length,
                calendarInvite.agenda?.length ?: 0,
                calendarInvite.location?.length ?: 0,
                calendarInvite.calendarProvider,
                calendarInvite.managerEmail,
                metadata.subject,
                metadata.messageId,
                ex,
            )
            throw ex
        }
    }

    private fun closeResources() {
        try {
            folder?.close()
        } catch (ex: Exception) {
            logger.debug("Failed closing IMAP folder", ex)
        } finally {
            folder = null
        }

        try {
            store?.close()
        } catch (ex: Exception) {
            logger.debug("Failed closing IMAP store", ex)
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
        val metadata = message.toMetadata()
        logger.info(
            "Received email id={} from={} subject={}",
            metadata.messageId,
            metadata.from,
            metadata.subject,
        )
        runCatching { parseCalendarInvites(message, metadata) }
            .onFailure {
                logger.warn(
                    "Failed to parse calendar invites for subject={} messageId={}",
                    metadata.subject,
                    metadata.messageId,
                    it,
                )
            }
    }

    private fun parseCalendarInvites(message: Message, metadata: MessageMetadata) {
        when {
            message.isMimeType("multipart/*") -> {
                val content = message.content
                if (content is Multipart) parseMultipartInvites(content, metadata)
            }
            message.isMimeType("text/calendar") -> {
                message.inputStream.use { stream ->
                    persistEvent(CalendarInviteParser.parse(stream), metadata)
                }
            }
            // Some providers hand back text/calendar as shared input streams without multipart.
            message.contentType.contains("text/calendar", ignoreCase = true) -> {
                message.inputStream.use { stream ->
                    persistEvent(CalendarInviteParser.parse(stream), metadata)
                }
            }
            else -> logger.debug(
                "No calendar content detected for subject={} type={} messageId={}",
                metadata.subject,
                message.contentType,
                metadata.messageId,
            )
        }
    }

    private fun parseMultipartInvites(multipart: Multipart, metadata: MessageMetadata) {
        repeat(multipart.count) { index ->
            val bodyPart = multipart.getBodyPart(index)
            if (bodyPart.isCalendarAttachment()) {
                runCatching {
                    bodyPart.inputStream.use { stream ->
                        CalendarInviteParser.parse(stream)
                    }
                }.onSuccess { invite ->
                    persistEvent(invite, metadata)
                }.onFailure {
                    logger.warn(
                        "Failed to parse calendar invite from attachment {} subject={} messageId={}",
                        bodyPart.fileName,
                        metadata.subject,
                        metadata.messageId,
                        it,
                    )
                }
            } else if (bodyPart.isMimeType("multipart/*") && bodyPart.content is Multipart) {
                parseMultipartInvites(bodyPart.content as Multipart, metadata)
            } else {
                logger.debug(
                    "Skipping non-calendar part at index={} type={} disposition={} fileName={} messageId={}",
                    index,
                    bodyPart.contentType,
                    bodyPart.disposition,
                    bodyPart.fileName,
                    metadata.messageId,
                )
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

    private fun Message.toMetadata(): MessageMetadata = MessageMetadata(
        subject = runCatching { subject }.getOrNull(),
        from = runCatching { from?.joinToString() }.getOrNull(),
        messageId = runCatching { getHeader("Message-ID")?.firstOrNull() }.getOrNull(),
    )
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

data class MessageMetadata(
    val subject: String?,
    val from: String?,
    val messageId: String?,
)
