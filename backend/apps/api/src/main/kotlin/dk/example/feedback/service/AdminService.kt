package dk.example.feedback.service

import com.fasterxml.jackson.databind.ObjectMapper
import dk.example.feedback.config.FeedbackConfig
import dk.example.feedback.controller.AdminController.MockTokenDto
import dk.example.feedback.controller.AdminController.SignInFirebaseResponseDto
import dk.example.feedback.firebase.FirebaseAdminService
import dk.example.feedback.firebase.FirebaseService
import dk.example.feedback.model.enumerations.Role
import dk.example.feedback.persistence.repo.AccountRepo
import org.slf4j.LoggerFactory
import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Service
import org.springframework.web.client.RestTemplate
import org.springframework.web.client.postForEntity

@Service
class AdminService(
    val feedbackConfig: FeedbackConfig,
    val accountRepo: AccountRepo,
    val firebaseAdminService: FirebaseAdminService,
    val firebaseService: FirebaseService,
    val objectMapper: ObjectMapper,
) {

    private val logger = LoggerFactory.getLogger(AdminService::class.java)

    fun getMockToken(role: Role?, uid: String): MockTokenDto {

        accountRepo.createOrGetAccount(
            name = "Mock",
            email = "Mock@gmail.com",
            phoneNumber = "27630505",
            accountId = uid,
        )

        firebaseAdminService.createUserIfMissing(
            uid = uid,
            email = "mock@mock.dk",
            displayName = "Mocked displayname"
        )
        try {
            firebaseService.setRole(userId = uid, requestedRole = role)
        } catch (e: Exception) {
            logger.debug("Firebase: Failed to set custom claims for role with value {}", role)
        }
        val token = firebaseAdminService.createCustomToken(uid = uid)
        return signInWithCustomToken(token)
    }

    fun signInWithCustomToken(token: String): MockTokenDto {
        val apiKey = feedbackConfig.firebaseApiKey
        val url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=$apiKey"
        val body = objectMapper.writeValueAsString(
            mapOf(
                "token" to token,
                "returnSecureToken" to true,
            )
        )

        val headers = HttpHeaders().apply {
            contentType = MediaType.APPLICATION_JSON
            accept = listOf(MediaType.APPLICATION_JSON)
        }

        val restTemplate = RestTemplate()
        val response: ResponseEntity<SignInFirebaseResponseDto> = restTemplate.postForEntity(
            url = url,
            request = HttpEntity(body, headers)
        )

        if (response.statusCode.is2xxSuccessful) {
            return MockTokenDto(firebaseResponse = response.body!!, token = token)
        }
        throw RuntimeException("Failed to sign in with custom token")
    }
}
