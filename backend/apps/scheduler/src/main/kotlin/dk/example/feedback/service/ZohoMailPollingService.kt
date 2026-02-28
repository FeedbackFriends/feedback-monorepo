package dk.example.feedback.service

import dk.example.feedback.FeedbackConfig
import dk.example.feedback.ical.CalendarInvite
import dk.example.feedback.ical.CalendarInviteParser
import dk.example.feedback.mail.ZohoAttachment
import dk.example.feedback.mail.ZohoMailClient
import dk.example.feedback.mail.ZohoMessageSummary
import dk.example.feedback.persistence.pincodegenerator.PinCodeGenerator
import dk.example.feedback.persistence.repo.AccountRepo
import dk.example.feedback.persistence.repo.ArchiveStatus
import dk.example.feedback.persistence.repo.EventRepo
import dk.example.feedback.persistence.repo.MailListenerState
import dk.example.feedback.persistence.repo.MailListenerStateRepo
import dk.example.feedback.persistence.repo.ZohoProcessedMessage
import dk.example.feedback.persistence.repo.ZohoProcessedMessageRepo
import java.util.concurrent.atomic.AtomicBoolean
import org.slf4j.LoggerFactory
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Service

@Service
class ZohoMailPollingService(
    private val feedbackConfig: FeedbackConfig,
    private val zohoMailClient: ZohoMailClient,
    private val eventRepo: EventRepo,
    private val accountRepo: AccountRepo,
    private val mailListenerStateRepo: MailListenerStateRepo,
    private val processedMessageRepo: ZohoProcessedMessageRepo,
    private val pinCodeGenerator: PinCodeGenerator = PinCodeGenerator(eventRepo),
) {

    private val logger = LoggerFactory.getLogger(ZohoMailPollingService::class.java)
    private val running = AtomicBoolean(false)

    @Scheduled(fixedDelayString = "\${feedback.mail.poll-interval-ms:10000}")
    fun pollMailbox() {
        val settings = feedbackConfig.mail
        if (!settings.enabled) return
        if (settings.accountId.isBlank() || settings.folderId.isBlank()) {
            logger.warn("Zoho mail polling disabled: accountId or folderId missing")
            return
        }
        if (!running.compareAndSet(false, true)) {
            logger.debug("Skipping Zoho mail poll; previous run still active")
            return
        }
        try {
            logger.debug("Starting Zoho mail poll accountId={} folderId={}", settings.accountId, settings.folderId)
            pollOnce(settings)
        } finally {
            running.set(false)
        }
    }

    private fun pollOnce(settings: FeedbackConfig.MailSettings) {
        val mailboxId = mailboxStateId(settings)
        val state = mailListenerStateRepo.getState(mailboxId) ?: initializeState(mailboxId)
        logger.info(
            "Polling Zoho mailbox mailboxId={} lastProcessedReceivedTime={}",
            mailboxId,
            state.lastProcessedReceivedTime,
        )
        val fetchResult = fetchNewMessages(settings, state)
        if (fetchResult.messages.isEmpty()) {
            logger.debug(
                "No new Zoho messages mailboxId={} cursorReached={}",
                mailboxId,
                fetchResult.cursorReached,
            )
            return
        }

        val sortedMessages = fetchResult.messages.sortedWith(messageComparator())
        logger.info("Processing {} Zoho messages from mailbox={}", sortedMessages.size, mailboxId)

        var maxReceivedTime: Long? = null
        sortedMessages.forEach { message ->
            val existing = processedMessageRepo.getMessage(message.messageId)
            if (existing?.processedAt != null) {
                if (shouldRetryArchive(existing)) {
                    attemptArchiveRetry(message.messageId)
                }
                logger.debug("Skipping Zoho message already processed messageId={}", message.messageId)
                return@forEach
            }
            if (message.receivedTime < state.lastProcessedReceivedTime) {
                logger.trace(
                    "Skipping Zoho message older than cursor messageId={} receivedTime={} cursor={}",
                    message.messageId,
                    message.receivedTime,
                    state.lastProcessedReceivedTime,
                )
                return@forEach
            }
            if (
                !processedMessageRepo.tryClaim(
                    messageId = message.messageId,
                    mailboxId = mailboxId,
                    receivedTime = message.receivedTime,
                    subject = message.subject,
                    fromAddress = message.fromAddress,
                    hasAttachment = message.hasAttachment,
                    status = ZohoMessageStatus.CLAIMED.name,
                )
            ) {
                logger.debug("Skipping Zoho message already claimed messageId={} mailboxId={}", message.messageId, mailboxId)
                return@forEach
            }

            val outcome = runCatching { processMessage(settings.folderId, message) }
                .getOrElse { ex ->
                    logger.warn("Failed to process Zoho message messageId={} subject={}", message.messageId, message.subject, ex)
                    MessageProcessingOutcome.failed("processing_failed: ${ex.message ?: "unknown"}")
                }

            runCatching {
                processedMessageRepo.markProcessed(
                    messageId = message.messageId,
                    status = outcome.status.name,
                    statusMessage = outcome.detail,
                )
            }.getOrElse { ex ->
                logger.warn("Failed to store Zoho message outcome messageId={}", message.messageId, ex)
                return
            }

            val archiveResult = runCatching { zohoMailClient.archiveMessage(message.messageId) }
            val archiveFailed = archiveResult.isFailure
            if (archiveResult.isSuccess) {
                runCatching {
                    processedMessageRepo.markArchiveStatus(
                        messageId = message.messageId,
                        status = ArchiveStatus.SUCCESS,
                        statusMessage = null,
                    )
                }.onFailure { ex ->
                    logger.warn("Failed to store Zoho archive status messageId={}", message.messageId, ex)
                }
            } else {
                val ex = archiveResult.exceptionOrNull()
                logger.warn("Failed to archive Zoho message messageId={}", message.messageId, ex)
                runCatching {
                    processedMessageRepo.markArchiveStatus(
                        messageId = message.messageId,
                        status = ArchiveStatus.FAILED,
                        statusMessage = "archive_failed: ${ex?.message ?: "unknown"}",
                    )
                }.onFailure { updateEx ->
                    logger.warn("Failed to store Zoho archive failure messageId={}", message.messageId, updateEx)
                }
            }

            when (outcome.status) {
                ZohoMessageStatus.SUCCESS -> Unit
                ZohoMessageStatus.SKIPPED -> logger.info(
                    "Zoho message handled with status={} messageId={} subject={} detail={}",
                    outcome.status,
                    message.messageId,
                    message.subject,
                    outcome.detail,
                )
                else -> logger.warn(
                    "Zoho message handled with status={} messageId={} subject={} detail={}",
                    outcome.status,
                    message.messageId,
                    message.subject,
                    outcome.detail,
                )
            }
            if (archiveFailed) {
                logger.warn(
                    "Zoho message archive failed messageId={} subject={}",
                    message.messageId,
                    message.subject,
                )
            }
            if (maxReceivedTime == null || message.receivedTime > maxReceivedTime!!) {
                maxReceivedTime = message.receivedTime
            }
        }

        val checkpointTime = maxReceivedTime ?: return
        if (!fetchResult.cursorReached) {
            logger.error(
                "Zoho poll reached page limit before cursor; increase ZOHO_MAX_PAGES_PER_POLL to avoid skipping mail",
            )
            return
        }
        mailListenerStateRepo.updateState(mailboxId, receivedTime = checkpointTime)
    }

    private fun initializeState(mailboxId: String): MailListenerState {
        mailListenerStateRepo.updateState(mailboxId, receivedTime = 0L)
        logger.info("Initialized Zoho mailbox state mailboxId={} receivedTime=0", mailboxId)
        return MailListenerState(lastProcessedReceivedTime = 0L)
    }

    private fun fetchNewMessages(
        settings: FeedbackConfig.MailSettings,
        state: MailListenerState,
    ): FetchResult {
        val pageSize = settings.pageSize.coerceAtLeast(1)
        val maxPages = settings.maxPagesPerPoll.coerceAtLeast(1)
        val messages = mutableListOf<ZohoMessageSummary>()
        var start = 0
        var cursorReached = false

        logger.debug(
            "Fetching Zoho messages folderId={} lastProcessedReceivedTime={} pageSize={} maxPages={}",
            settings.folderId,
            state.lastProcessedReceivedTime,
            pageSize,
            maxPages,
        )
        repeat(maxPages) { pageIndex ->
            logger.debug("Requesting Zoho message page pageIndex={} start={} pageSize={}", pageIndex, start, pageSize)
            val page = runCatching {
                zohoMailClient.listMessages(settings.folderId, start = start, limit = pageSize)
            }.getOrElse { ex ->
                logger.warn(
                    "Zoho mail list failed folderId={} pageIndex={} start={}",
                    settings.folderId,
                    pageIndex,
                    start,
                    ex,
                )
                return FetchResult(messages = messages, cursorReached = false)
            }

            if (page.isEmpty()) {
                logger.debug("Zoho message page empty pageIndex={} start={}", pageIndex, start)
                return FetchResult(messages = messages, cursorReached = true)
            }
            messages += page

            val minReceivedTime = page.minOfOrNull { it.receivedTime } ?: 0L
            if (minReceivedTime < state.lastProcessedReceivedTime) {
                logger.debug(
                    "Zoho cursor reached pageIndex={} minReceivedTime={} cursor={}",
                    pageIndex,
                    minReceivedTime,
                    state.lastProcessedReceivedTime,
                )
                cursorReached = true
                return FetchResult(messages = messages, cursorReached = true)
            }

            start += pageSize
            if (page.size < pageSize) {
                logger.debug(
                    "Zoho message page smaller than pageSize pageIndex={} size={} pageSize={}",
                    pageIndex,
                    page.size,
                    pageSize,
                )
                cursorReached = true
                return FetchResult(messages = messages, cursorReached = true)
            }
        }

        return FetchResult(messages = messages, cursorReached = cursorReached)
    }

    private fun messageComparator(): Comparator<ZohoMessageSummary> =
        Comparator { first, second ->
            val timeCompare = first.receivedTime.compareTo(second.receivedTime)
            if (timeCompare != 0) return@Comparator timeCompare
            first.messageId.compareTo(second.messageId)
        }

    private fun processMessage(folderId: String, message: ZohoMessageSummary): MessageProcessingOutcome {
        val metadata = MessageMetadata(
            subject = message.subject,
            from = message.fromAddress,
            messageId = message.messageId,
        )

        logger.info(
            "Received Zoho email id={} from={} subject={} hasAttachment={}",
            metadata.messageId,
            metadata.from,
            metadata.subject,
            message.hasAttachment,
        )

        val attachments = runCatching { zohoMailClient.getAttachmentInfo(folderId, message.messageId) }
            .getOrElse { ex ->
                return MessageProcessingOutcome.failed("attachment_info_failed: ${ex.message ?: "unknown"}")
            }

        return parseCalendarInvites(folderId, message.messageId, attachments, metadata)
    }

    private fun parseCalendarInvites(
        folderId: String,
        messageId: String,
        attachments: List<ZohoAttachment>,
        metadata: MessageMetadata,
    ): MessageProcessingOutcome {
        val calendarAttachments = attachments.filter { it.isCalendarAttachment() }
        if (calendarAttachments.isEmpty()) {
            logger.debug(
                "No calendar attachment detected for messageId={} subject={} attachments={}",
                metadata.messageId,
                metadata.subject,
                attachments.size,
            )
            return MessageProcessingOutcome.skipped("no_calendar_attachment")
        }

        var anySuccess = false
        var skipDetail: String? = null
        calendarAttachments.forEach { attachment ->
            val bytes = zohoMailClient.downloadAttachment(folderId, messageId, attachment.attachmentId)
            val invite = runCatching {
                CalendarInviteParser.parse(bytes.inputStream())
            }.getOrElse { ex ->
                logger.warn(
                    "Failed to parse calendar invite attachment fileName={} messageId={}",
                    attachment.fileName,
                    metadata.messageId,
                    ex,
                )
                return MessageProcessingOutcome.failed("invite_parse_failed: ${attachment.fileName ?: "unknown"}")
            }
            val persistOutcome = runCatching { persistEvent(invite, metadata) }
                .getOrElse { ex ->
                    logger.warn(
                        "Failed to persist calendar invite subject={} messageId={}",
                        metadata.subject,
                        metadata.messageId,
                        ex,
                    )
                    return MessageProcessingOutcome.failed("persist_event_failed: ${ex.message ?: "unknown"}")
                }
            when (persistOutcome.status) {
                ZohoMessageStatus.SUCCESS -> anySuccess = true
                ZohoMessageStatus.SKIPPED -> skipDetail = persistOutcome.detail
                else -> return MessageProcessingOutcome.failed(persistOutcome.detail ?: "persist_event_failed")
            }
        }
        return if (anySuccess) {
            MessageProcessingOutcome.success()
        } else {
            MessageProcessingOutcome.skipped(skipDetail ?: "skipped")
        }
    }

    private fun shouldRetryArchive(existing: ZohoProcessedMessage): Boolean {
        val archiveStatus = existing.archiveStatus
        return archiveStatus == null ||
            archiveStatus == ArchiveStatus.FAILED.name ||
            existing.status == "ARCHIVE_FAILED"
    }

    private fun attemptArchiveRetry(messageId: String) {
        runCatching { zohoMailClient.archiveMessage(messageId) }
            .onSuccess {
                runCatching {
                    processedMessageRepo.markArchiveStatus(
                        messageId = messageId,
                        status = ArchiveStatus.SUCCESS,
                        statusMessage = null,
                    )
                }.onFailure { ex ->
                    logger.warn("Failed to store Zoho archive status messageId={}", messageId, ex)
                }
                logger.info("Archived Zoho message after retry messageId={}", messageId)
            }
            .onFailure { ex ->
                logger.warn("Failed to archive Zoho message after retry messageId={}", messageId, ex)
                runCatching {
                    processedMessageRepo.markArchiveStatus(
                        messageId = messageId,
                        status = ArchiveStatus.FAILED,
                        statusMessage = "archive_failed: ${ex.message ?: "unknown"}",
                    )
                }.onFailure { updateEx ->
                    logger.warn("Failed to store Zoho archive failure messageId={}", messageId, updateEx)
                }
            }
    }

    private fun ZohoAttachment.isCalendarAttachment(): Boolean {
        val fileNameLower = fileName?.lowercase()
        val contentTypeLower = contentType?.lowercase()
        return fileNameLower?.contains(".ics") == true ||
            contentTypeLower?.contains("text/calendar") == true ||
            contentTypeLower?.contains("application/ics") == true ||
            contentTypeLower?.contains("application/calendar") == true
    }

    private fun persistEvent(calendarInvite: CalendarInvite, metadata: MessageMetadata): MessageProcessingOutcome {
        val account = accountRepo.getAccountFromEmail(emailInput = calendarInvite.managerEmail)
        if (account == null) {
            logger.warn(
                "No account found for managerEmail={}, skipping invite subject={} messageId={}",
                calendarInvite.managerEmail,
                metadata.subject,
                metadata.messageId,
            )
            return MessageProcessingOutcome.skipped("no_account_for_manager_email")
        }

        val calendarEventId = calendarInvite.calendarEventId
        if (calendarEventId == null) {
            logger.debug(
                "Calendar invite missing UID, cannot de-duplicate subject={} messageId={}",
                metadata.subject,
                metadata.messageId,
            )
        }

        val existingEvent = calendarEventId?.let { eventRepo.getEventByCalendarEventId(account.id, it) }
        if (existingEvent != null) {
            logger.info(
                "Updating event from calendar invite id={} title={} date={} managerEmail={} calendarEventId={} subject={} messageId={}",
                existingEvent.id,
                calendarInvite.title,
                calendarInvite.date,
                calendarInvite.managerEmail,
                calendarEventId,
                metadata.subject,
                metadata.messageId,
            )
            runCatching {
                eventRepo.updateEventFromMailListener(
                    eventId = existingEvent.id,
                    title = calendarInvite.title,
                    agenda = calendarInvite.agenda,
                    date = calendarInvite.date,
                    location = calendarInvite.location,
                    durationInMinutes = calendarInvite.durationInMinutes,
                    invitedEmails = calendarInvite.attendingEmails,
                    calendarProvider = calendarInvite.calendarProvider,
                    calendarEventId = calendarEventId,
                )
            }.onSuccess { event ->
                accountRepo.updateSessionHash(accountId = account.id)
                logger.info(
                    "Event updated id={} titleLength={} agendaLength={} locationLength={} subject={} messageId={}",
                    event.id,
                    calendarInvite.title.length,
                    calendarInvite.agenda?.length ?: 0,
                    calendarInvite.location?.length ?: 0,
                    metadata.subject,
                    metadata.messageId,
                )
            }.onFailure { ex ->
                logger.warn(
                    "Failed to update calendar invite titleLength={} agendaLength={} locationLength={} provider={} managerEmail={} subject={} messageId={}",
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
            return MessageProcessingOutcome.success()
        }

        val generatedPincode = pinCodeGenerator.generate()
        logger.info(
            "Persisting event from calendar invite title={} date={} managerEmail={} calendarEventId={} subject={} messageId={}",
            calendarInvite.title,
            calendarInvite.date,
            calendarInvite.managerEmail,
            calendarEventId,
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
                calendarEventId = calendarEventId,
            )
        }.onSuccess { event ->
            accountRepo.updateSessionHash(accountId = account.id)
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
        return MessageProcessingOutcome.success()
    }

    private fun mailboxStateId(settings: FeedbackConfig.MailSettings): String {
        val mailbox = settings.mailboxAddress?.trim()?.lowercase() ?: "zoho"
        return "$mailbox:${settings.accountId}:${settings.folderId}"
    }
}

data class FetchResult(
    val messages: List<ZohoMessageSummary>,
    val cursorReached: Boolean,
)

data class MessageMetadata(
    val subject: String?,
    val from: String?,
    val messageId: String?,
)

enum class ZohoMessageStatus {
    CLAIMED,
    SUCCESS,
    SKIPPED,
    FAILED,
}

data class MessageProcessingOutcome(
    val status: ZohoMessageStatus,
    val detail: String? = null,
) {
    companion object {
        fun success(): MessageProcessingOutcome = MessageProcessingOutcome(ZohoMessageStatus.SUCCESS)

        fun skipped(detail: String): MessageProcessingOutcome =
            MessageProcessingOutcome(ZohoMessageStatus.SKIPPED, detail)

        fun failed(detail: String): MessageProcessingOutcome =
            MessageProcessingOutcome(ZohoMessageStatus.FAILED, detail)
    }

}
