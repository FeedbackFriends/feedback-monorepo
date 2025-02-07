package dk.example.feedback.controller

import ControllerPaths
import com.google.firebase.auth.ExportedUserRecord
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseAuthException
import com.google.firebase.auth.UserRecord
import dk.example.feedback.config.FeedbackConfig
import dk.example.feedback.model.*
import dk.example.feedback.persistence.repo.AccountRepo
import dk.example.feedback.service.AccountService
import dk.example.feedback.service.Claim
import dk.example.feedback.service.EventService
import dk.example.feedback.service.FirebaseService
import java.util.*
import org.slf4j.LoggerFactory
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import org.springframework.web.client.RestTemplate
import org.springframework.web.client.postForEntity


@RestController
@RequestMapping(ControllerPaths.AdminUrl)
class AdminController(val accountService: AccountService, val feedbackConfig: FeedbackConfig, val eventService: EventService, val firebaseService: FirebaseService, val accountRepo: AccountRepo) {

    private val logger = LoggerFactory.getLogger(AdminController::class.java)

    //
//    @GetMapping("/get-all-accounts")
//    fun getAllAccounts(): List<AccountEntity> {
//        return service.getAllAccounts()
//    }
//
//    @PostMapping("/create-event")
//    fun createEvent(@RequestBody createEventInput: EventInput): ManagerEventDto {
//        TODO()
////        return eventService.createOrUpdate(createEventInput = createEventInput, userId = "userId")
//    }
//
    @GetMapping("/all-users")
    fun allUsers(): List<ExportedUserRecord> {
        val users = FirebaseAuth.getInstance().listUsers(null).values.toList()
        return users
    }
//
//    data class OrganizationDto(
//        val id: UUID,
//        val name: String,
//        val maximumMembers: Int,
//        val owner: OwnerDto
//    )
//
//    data class OwnerDto(
//        val name: String,
//        val phone: String,
//        val email: String,
//    )
//
//    @PostMapping("/create-organization")
//    fun create(@RequestBody organizationDto: OrganizationDto) {
//        val generatedPassword = UUID.randomUUID().toString()
//        val owner = UserRecord.CreateRequest()
//            .setEmail(organizationDto.owner.email)
//            .setPassword(generatedPassword)
//            .setDisplayName(organizationDto.owner.name)
//            .setPhoneNumber(organizationDto.owner.phone)
//        FirebaseAuth.getInstance().createUser(owner)
//        // save user in database with organizationDto.owner.email as foreign key
//
//    }
//
//    @PostMapping("/change_owner")
//    fun changeOwner(@RequestBody organizationDto: OrganizationDto) {
//        // delete owner
//        // cretae new owner
//
//    }

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



    @PostMapping(path = ["/user-claims/{uid}"])
    @Throws(FirebaseAuthException::class)
    fun setUserClaims(
        @PathVariable uid: String,
        @RequestBody requestedClaims: Claim
    ) {
        firebaseService.setUserClaims(uid, requestedClaims)
    }

    data class FirebaseRequestDto(
        val token: String,
        val returnSecureToken: Boolean
    )

    data class FirebaseResponseDto (
        val idToken: String,
        val refreshToken: String,
        val expiresIn: String
    )

    data class MockTokenResponse(
        val firebaseResponse: FirebaseResponseDto,
        val token: String
    )

    data class MockIdTokenRequestDto(
        val claim: Claim?
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
            FirebaseAuth.getInstance().setCustomUserClaims(uid, mapOf("custom_claims" to input.claim?.name))
        } catch (e: Exception) {
            logger.info("Firebase: Failed to set custom claims")
        }
        val token = FirebaseAuth.getInstance().createCustomToken(uid)
        return signInWithCustomToken(token)
    }

    fun signInWithCustomToken(token: String): MockTokenResponse {
        val apiKey = feedbackConfig.firebaseApiKey
        val url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=$apiKey"

        val body = FirebaseRequestDto(
            token = token,
            returnSecureToken = true
        )

        val restTemplate = RestTemplate()
        val response: ResponseEntity<FirebaseResponseDto> = restTemplate.postForEntity(url = url, request = body)

        if (response.statusCode.is2xxSuccessful) {
            return MockTokenResponse(firebaseResponse = response.body!!, token = token)
        }
        throw RuntimeException("Failed to sign in with custom token")
    }
}

