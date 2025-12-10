package dk.example.feedback.service

import jakarta.mail.Folder
import jakarta.mail.Message
import jakarta.mail.MessagingException
import jakarta.mail.Multipart
import jakarta.mail.Session
import jakarta.mail.Store
import jakarta.mail.event.MessageCountAdapter
import jakarta.mail.event.MessageCountEvent
import jakarta.mail.internet.MimeMultipart
import org.eclipse.angus.mail.imap.IMAPFolder
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
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
                        logger.info(
                            "Received email from={} subject={} body={}",
                            message.from?.joinToString(),
                            message.subject,
                            extractText(message)
                        )
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

    private fun extractText(message: Message): String {
        return try {
            when (val content = message.content) {
                is String -> content
                is Multipart -> extractTextFromMultipart(content)
                else -> content?.toString() ?: ""
            }
        } catch (ex: Exception) {
            logger.warn("Failed to read email body", ex)
            ""
        }
    }

    private fun extractTextFromMultipart(multipart: Multipart): String {
        val builder = StringBuilder()
        for (i in 0 until multipart.count) {
            val part = multipart.getBodyPart(i)
            when (val content = part.content) {
                is String -> builder.appendLine(content)
                is MimeMultipart -> builder.appendLine(extractTextFromMultipart(content))
                is Multipart -> builder.appendLine(extractTextFromMultipart(content))
            }
        }
        return builder.toString().trim()
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
}
