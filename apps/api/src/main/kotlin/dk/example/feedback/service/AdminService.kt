package dk.example.feedback.service

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.UserRecord
import dk.example.feedback.config.FeedbackConfig
import dk.example.feedback.controller.AdminController.MockTokenDto

import dk.example.feedback.controller.AdminController.SignInFirebaseResponseDto
import dk.example.feedback.helpers.await
import dk.example.feedback.model.enumerations.Role
import dk.example.feedback.persistence.repo.AccountRepo
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.slf4j.LoggerFactory
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Service
import org.springframework.web.client.RestTemplate
import org.springframework.web.client.postForEntity

@Service
class AdminService(
    val feedbackConfig: FeedbackConfig,
    val accountRepo: AccountRepo,
) {

    private val logger = LoggerFactory.getLogger(AdminService::class.java)

    suspend fun getMockToken(role: Role?, uid: String): MockTokenDto {

        withContext(Dispatchers.IO) {
            accountRepo.createOrGetAccount(
                name = "Mock",
                email = "Mock@gmail.com",
                phoneNumber = "27630505",
                accountId = uid,
                fcmToken = null
            )
        }


        val createUserRequest = UserRecord.CreateRequest()
            .setUid(uid)
            .setEmail("mock@mock.dk")
            .setDisplayName("Mocked displayname")

        try {
            logger.debug("Firebase: Creating user")
            FirebaseAuth.getInstance().createUser(createUserRequest)
        } catch (e: Exception) {
            logger.debug("Firebase: User already exists so will sign in")
        }
        try {
            FirebaseAuth.getInstance().setCustomUserClaimsAsync(uid, mapOf("role" to role.toString())).await()
        } catch (e: Exception) {
            logger.debug("Firebase: Failed to set custom claims for role with value {}", role)
        }
        val token = FirebaseAuth.getInstance().createCustomTokenAsync(uid).await()
        return signInWithCustomToken(token)
    }

    fun signInWithCustomToken(token: String): MockTokenDto {
        val apiKey = feedbackConfig.firebaseApiKey
        val url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=$apiKey"

        data class SignInFirebaseRequestDto(
            val token: String,
            val returnSecureToken: Boolean
        )

        val body = SignInFirebaseRequestDto(
            token = token,
            returnSecureToken = true
        )

        val restTemplate = RestTemplate()
        val response: ResponseEntity<SignInFirebaseResponseDto> = restTemplate.postForEntity(url = url, request = body)

        if (response.statusCode.is2xxSuccessful) {
            return MockTokenDto(firebaseResponse = response.body!!, token = token)
        }
        throw RuntimeException("Failed to sign in with custom token")
    }
}
