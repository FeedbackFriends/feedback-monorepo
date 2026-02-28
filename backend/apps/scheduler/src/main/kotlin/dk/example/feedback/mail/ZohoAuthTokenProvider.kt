package dk.example.feedback.mail

import com.fasterxml.jackson.databind.ObjectMapper
import dk.example.feedback.FeedbackConfig
import java.time.Instant
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock
import org.slf4j.LoggerFactory
import org.springframework.boot.web.client.RestTemplateBuilder
import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.stereotype.Component
import org.springframework.util.LinkedMultiValueMap
import org.springframework.web.client.RestTemplate
import org.springframework.web.util.UriComponentsBuilder

@Component
class ZohoAuthTokenProvider(
    restTemplateBuilder: RestTemplateBuilder,
    private val objectMapper: ObjectMapper,
    private val feedbackConfig: FeedbackConfig,
) {

    private val logger = LoggerFactory.getLogger(ZohoAuthTokenProvider::class.java)
    private val restTemplate: RestTemplate = restTemplateBuilder.build()
    private val lock = ReentrantLock()

    @Volatile private var cachedToken: CachedToken? = null

    fun getAccessToken(): String {
        val current = cachedToken
        if (current != null && !current.isExpired()) {
            logger.debug("Using cached Zoho OAuth access token expiresAt={}", current.expiresAt)
            return current.value
        }

        val oauth = feedbackConfig.mail.oauth
        val refreshToken = oauth.refreshToken ?: error("Zoho OAuth refresh token is missing")
        val clientId = oauth.clientId ?: error("Zoho OAuth client id is missing")
        val clientSecret = oauth.clientSecret ?: error("Zoho OAuth client secret is missing")

        return lock.withLock {
            val lockedToken = cachedToken
            if (lockedToken != null && !lockedToken.isExpired()) {
                logger.debug("Using cached Zoho OAuth access token after lock expiresAt={}", lockedToken.expiresAt)
                return@withLock lockedToken.value
            }
            logger.info("Refreshing Zoho OAuth access token")
            refreshAccessToken(refreshToken, clientId, clientSecret)
        }
    }

    fun invalidate() {
        cachedToken = null
        logger.debug("Invalidated cached Zoho OAuth access token")
    }

    private fun refreshAccessToken(
        refreshToken: String,
        clientId: String,
        clientSecret: String,
    ): String {
        val oauth = feedbackConfig.mail.oauth
        val headers = HttpHeaders().apply {
            contentType = MediaType.APPLICATION_FORM_URLENCODED
            accept = listOf(MediaType.APPLICATION_JSON)
        }

        val requestBody = LinkedMultiValueMap<String, String>().apply {
            add("refresh_token", refreshToken)
            add("client_id", clientId)
            add("client_secret", clientSecret)
            add("grant_type", "refresh_token")
        }
        val request = HttpEntity(requestBody, headers)
        val uri = UriComponentsBuilder.fromHttpUrl(oauth.tokenUrl).build(true).toUri()
        logger.debug("Requesting Zoho OAuth token refresh tokenUrl={}", uri)
        val response = restTemplate.postForEntity(uri, request, String::class.java)
        val responseBody = response.body ?: error("Zoho OAuth refresh response is empty")
        logger.debug(
            "Zoho OAuth response status={} bodyChars={}",
            response.statusCode.value(),
            responseBody.length,
        )
        val node = objectMapper.readTree(responseBody)
        val accessToken = node.path("access_token").asText(null)
            ?: error("Zoho OAuth refresh response missing access_token")
        val expiresIn = node.path("expires_in").asLong(3600)
        val expiresAt = Instant.now().plusSeconds((expiresIn - 60).coerceAtLeast(60))

        cachedToken = CachedToken(accessToken, expiresAt)
        logger.info("Refreshed Zoho OAuth access token expiresAt={}", expiresAt)
        return accessToken
    }

}

private data class CachedToken(
    val value: String,
    val expiresAt: Instant,
) {
    fun isExpired(): Boolean = Instant.now().isAfter(expiresAt)
}
