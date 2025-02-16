package dk.example.feedback.controller

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.UserRecord
import dk.example.feedback.config.FeedbackConfig
import dk.example.feedback.persistence.repo.AccountRepo
import dk.example.feedback.service.AccountService
import dk.example.feedback.service.EventService
import dk.example.feedback.service.FirebaseService
import dk.example.feedback.service.Role
import io.swagger.v3.oas.annotations.tags.Tag
import org.slf4j.LoggerFactory
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.client.RestTemplate
import org.springframework.web.client.postForEntity


@RestController
@Tag(name = "Admin")
@RequestMapping("/admin")
class AdminController(
    val accountService: AccountService,
    val feedbackConfig: FeedbackConfig,
    val eventService: EventService,
    val firebaseService: FirebaseService,
    val accountRepo: AccountRepo
) {

    private val logger = LoggerFactory.getLogger(AdminController::class.java)

//    @PostMapping("/send-notification")
//    fun mockNotification(@RequestBody fcmToken: String?) {
//        val message = Message.builder()
////            .setNotification(
////                Message.Notification("title", "body")
////            )
//            .putData("score", "850")
//            .putData("time", "2:45")
//            .setToken(fcmToken)
//            .build()
//        val response = FirebaseMessaging.getInstance().send(message)
//    }



    data class MockTokenResponse(
        val firebaseResponse: SignInFirebaseResponseDto,
        val token: String
    )

    data class MockIdTokenRequestDto(
        val role: Role?
    )

    @PostMapping("/mockIdToken")
    fun mockIdToken(@RequestBody input: MockIdTokenRequestDto): MockTokenResponse {

        val uid = "mock_id"


        accountRepo.createOrGetAccount(
            name = "Mock",
            email = "Mock@gmail.com",
            phoneNumber = "27630505",
            accountId = uid
        )


        val createUserRequest = UserRecord.CreateRequest()
            .setUid(uid)
            .setEmail("mock@mock.dk")
            .setDisplayName("Mocked displayname")

        try {
            logger.info("Firebase: Creating user")
            FirebaseAuth.getInstance().createUser(createUserRequest)
        } catch (e: Exception) {
            logger.info("Firebase: User already exists so will sign in")
        }
        try {
            FirebaseAuth.getInstance().setCustomUserClaims(uid, mapOf("role" to input.role?.name))
        } catch (e: Exception) {
            logger.info("Firebase: Failed to set custom claims for role with value ${input.role}")
        }
        val token = FirebaseAuth.getInstance().createCustomToken(uid)
        return signInWithCustomToken(token)
    }

    data class SignInFirebaseRequestDto(
        val token: String,
        val returnSecureToken: Boolean
    )

    data class SignInFirebaseResponseDto(
        val idToken: String,
        val refreshToken: String,
        val expiresIn: String
    )

    fun signInWithCustomToken(token: String): MockTokenResponse {
        val apiKey = feedbackConfig.firebaseApiKey
        val url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=$apiKey"


        val body = SignInFirebaseRequestDto(
            token = token,
            returnSecureToken = true
        )

        val restTemplate = RestTemplate()
        val response: ResponseEntity<SignInFirebaseResponseDto> = restTemplate.postForEntity(url = url, request = body)

        if (response.statusCode.is2xxSuccessful) {
            return MockTokenResponse(firebaseResponse = response.body!!, token = token)
        }
        throw RuntimeException("Failed to sign in with custom token")
    }
}

