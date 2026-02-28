package dk.example.feedback.mail

import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import dk.example.feedback.FeedbackConfig
import java.net.URI
import org.slf4j.LoggerFactory
import org.springframework.boot.web.client.RestTemplateBuilder
import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpMethod
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Component
import org.springframework.web.client.RestTemplate
import org.springframework.web.util.UriComponentsBuilder

@Component
class ZohoMailClient(
    restTemplateBuilder: RestTemplateBuilder,
    private val objectMapper: ObjectMapper,
    private val feedbackConfig: FeedbackConfig,
    private val authTokenProvider: ZohoAuthTokenProvider,
) {

    private val logger = LoggerFactory.getLogger(ZohoMailClient::class.java)
    private val restTemplate: RestTemplate = restTemplateBuilder.build()

    fun listMessages(folderId: String, start: Int, limit: Int): List<ZohoMessageSummary> {
        val uri = UriComponentsBuilder.fromHttpUrl("${baseUrl()}/accounts/${accountId()}/messages/view")
            .queryParam("folderId", folderId)
            .queryParam("start", start)
            .queryParam("limit", limit)
            .build(true)
            .toUri()

        logger.debug(
            "Fetching Zoho message list folderId={} start={} limit={} uri={}",
            folderId,
            start,
            limit,
            uri,
        )
        val node = getJson(uri)
        val messages = parseMessageSummaries(node)
        logger.debug(
            "Fetched Zoho message list folderId={} start={} limit={} count={}",
            folderId,
            start,
            limit,
            messages.size,
        )
        return messages
    }

    fun getAttachmentInfo(folderId: String, messageId: String): List<ZohoAttachment> {
        logger.debug("Fetching Zoho attachment info messageId={}", messageId)
        val uri = UriComponentsBuilder
            .fromHttpUrl("${baseUrl()}/accounts/${accountId()}/folders/$folderId/messages/$messageId/attachmentinfo")
            .queryParam("includeInline", true)
            .build(true)
            .toUri()
        val node = getJson(uri)
        return parseAttachmentInfo(node)
    }

    fun downloadAttachment(folderId: String, messageId: String, attachmentId: String): ByteArray {
        val uri = URI.create(
            "${baseUrl()}/accounts/${accountId()}/folders/$folderId/messages/$messageId/attachments/$attachmentId",
        )
        logger.debug(
            "Downloading Zoho attachment folderId={} messageId={} attachmentId={}",
            folderId,
            messageId,
            attachmentId,
        )
        val response = exchangeWithAuth(
            uri,
            HttpMethod.GET,
            ByteArray::class.java,
            accept = listOf(MediaType.APPLICATION_OCTET_STREAM),
        )
        return response.body ?: ByteArray(0)
    }

    fun archiveMessage(messageId: String) {
        val uri = URI.create("${baseUrl()}/accounts/${accountId()}/updatemessage")
        val payload = mapOf(
            "mode" to "archiveMails",
            "messageId" to listOf(messageId),
        )
        logger.debug("Archiving Zoho message messageId={}", messageId)
        exchangeWithAuth(
            uri,
            HttpMethod.PUT,
            payload,
            String::class.java,
            accept = listOf(MediaType.APPLICATION_JSON),
            contentType = MediaType.APPLICATION_JSON,
        )
    }

    private fun baseUrl(): String = feedbackConfig.mail.apiBaseUrl.trimEnd('/')
    private fun accountId(): String = feedbackConfig.mail.accountId

    private fun getJson(uri: URI): JsonNode {
        val response = exchangeWithAuth(uri, HttpMethod.GET, String::class.java)
        val body = response.body ?: "{}"
        return objectMapper.readTree(body)
    }

    private fun <T> exchangeWithAuth(
        uri: URI,
        method: HttpMethod,
        responseType: Class<T>,
    ): ResponseEntity<T> = exchangeWithAuth(
        uri,
        method,
        responseType,
        accept = listOf(MediaType.APPLICATION_JSON),
    )

    private fun <T> exchangeWithAuth(
        uri: URI,
        method: HttpMethod,
        responseType: Class<T>,
        accept: List<MediaType>,
    ): ResponseEntity<T> {
        val request = HttpEntity<Any>(HttpHeaders().apply {
            set(HttpHeaders.AUTHORIZATION, "Zoho-oauthtoken ${authTokenProvider.getAccessToken()}")
            this.accept = accept
        })

        logger.debug("Zoho request start method={} uri={}", method, uri)
        val response = restTemplate.exchange(uri, method, request, responseType)
        logger.debug("Zoho request complete method={} uri={} status={}", method, uri, response.statusCode.value())
        logResponseMetadata(method, uri, response, responseType)
        return response
    }

    private fun <T> exchangeWithAuth(
        uri: URI,
        method: HttpMethod,
        body: Any,
        responseType: Class<T>,
        accept: List<MediaType>,
        contentType: MediaType,
    ): ResponseEntity<T> {
        val request = HttpEntity(body, HttpHeaders().apply {
            set(HttpHeaders.AUTHORIZATION, "Zoho-oauthtoken ${authTokenProvider.getAccessToken()}")
            this.accept = accept
            this.contentType = contentType
        })

        logger.debug("Zoho request start method={} uri={}", method, uri)
        val response = restTemplate.exchange(uri, method, request, responseType)
        logger.debug("Zoho request complete method={} uri={} status={}", method, uri, response.statusCode.value())
        logResponseMetadata(method, uri, response, responseType)
        return response
    }

    private fun <T> logResponseMetadata(
        method: HttpMethod,
        uri: URI,
        response: ResponseEntity<T>,
        responseType: Class<T>,
    ) {
        when (responseType) {
            String::class.java -> {
                val size = (response.body as? String)?.length ?: 0
                logger.debug(
                    "Zoho response metadata method={} uri={} status={} bodyChars={}",
                    method,
                    uri,
                    response.statusCode.value(),
                    size,
                )
            }
            ByteArray::class.java -> {
                val size = (response.body as? ByteArray)?.size ?: 0
                logger.debug(
                    "Zoho response metadata method={} uri={} status={} bytes={}",
                    method,
                    uri,
                    response.statusCode.value(),
                    size,
                )
            }
            else -> {
                logger.debug(
                    "Zoho response metadata method={} uri={} status={} type={}",
                    method,
                    uri,
                    response.statusCode.value(),
                    responseType.simpleName,
                )
            }
        }
    }

    private fun parseMessageSummaries(node: JsonNode): List<ZohoMessageSummary> {
        val dataNode = node.path("data")
        val arrayNode = when {
            dataNode.isArray -> dataNode
            node.path("messages").isArray -> node.path("messages")
            else -> dataNode
        }

        if (!arrayNode.isArray) return emptyList()
        return arrayNode.mapNotNull { item ->
            val messageId = item.path("messageId").asText(null) ?: return@mapNotNull null
            val receivedTime = readReceivedTime(item)
            ZohoMessageSummary(
                messageId = messageId,
                receivedTime = receivedTime,
                subject = item.path("subject").asText(null),
                fromAddress = item.path("fromAddress").asText(null),
                hasAttachment = readHasAttachment(item),
            )
        }
    }

    private fun parseAttachmentInfo(node: JsonNode): List<ZohoAttachment> {
        val payload = node.path("data").takeIf { it.isObject } ?: node
        val attachments = parseAttachmentArray(payload.path("attachments"))
        val inline = parseAttachmentArray(payload.path("inline"))
        if (attachments.isEmpty() && inline.isEmpty()) return emptyList()
        return (attachments + inline).distinctBy { it.attachmentId }
    }

    private fun parseAttachmentArray(node: JsonNode): List<ZohoAttachment> {
        val entries = when {
            node.isArray -> node.toList()
            node.isObject -> node.fields().asSequence().map { it.value }.toList()
            else -> emptyList()
        }
        return entries.mapNotNull { attachment ->
            val attachmentId = readText(attachment, "attachmentId", "id") ?: return@mapNotNull null
            ZohoAttachment(
                attachmentId = attachmentId,
                fileName = readText(attachment, "attachmentName", "fileName", "name"),
                contentType = readText(attachment, "contentType", "mimeType", "type"),
            )
        }
    }

    private fun readReceivedTime(node: JsonNode): Long {
        val directNode = node.path("receivedTime")
        val direct = directNode.asLong(0)
        if (direct > 0) return direct
        directNode.asText(null)?.toLongOrNull()?.let { if (it > 0) return it }

        val fallbackNode = node.path("receivedTimeMillis")
        val fallback = fallbackNode.asLong(0)
        if (fallback > 0) return fallback
        fallbackNode.asText(null)?.toLongOrNull()?.let { if (it > 0) return it }

        val dateNode = node.path("date")
        val date = dateNode.asLong(0)
        if (date > 0) return date
        dateNode.asText(null)?.toLongOrNull()?.let { if (it > 0) return it }
        return 0
    }

    private fun readHasAttachment(node: JsonNode): Boolean? {
        val valueNode = node.path("hasAttachment")
        if (valueNode.isMissingNode || valueNode.isNull) return null
        if (valueNode.isBoolean) return valueNode.asBoolean()
        if (valueNode.isNumber) return valueNode.asInt(0) != 0
        val text = valueNode.asText(null) ?: return null
        return text == "1" || text.equals("true", ignoreCase = true)
    }

    private fun readText(node: JsonNode, vararg fieldNames: String): String? {
        readTextFromNode(node, *fieldNames)?.let { return it }
        val messageNode = node.path("message")
        if (messageNode.isObject) {
            return readTextFromNode(messageNode, *fieldNames)
        }
        return null
    }

    private fun readTextFromNode(node: JsonNode, vararg fieldNames: String): String? {
        fieldNames.forEach { fieldName ->
            val valueNode = node.path(fieldName)
            if (!valueNode.isMissingNode && !valueNode.isNull && valueNode.isValueNode) {
                return valueNode.asText(null)
            }
        }
        return null
    }

}

data class ZohoMessageSummary(
    val messageId: String,
    val receivedTime: Long,
    val subject: String?,
    val fromAddress: String?,
    val hasAttachment: Boolean?,
)

data class ZohoAttachment(
    val attachmentId: String,
    val fileName: String?,
    val contentType: String?,
)
