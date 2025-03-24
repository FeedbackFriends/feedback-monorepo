package dk.example.feedback.controller

import dk.example.feedback.firebase.FirebaseService
import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.model.enumerations.Role
import dk.example.feedback.service.AdminService
import io.swagger.v3.oas.annotations.tags.Tag
import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController


@RestController
@Tag(name = "Admin")
@RequestMapping("/admin")
class AdminController(
    val adminService: AdminService,
    val firebaseService: FirebaseService,
//    val notificationService: NotificationService,
) {

    private val logger = LoggerFactory.getLogger(AdminController::class.java)

    data class MockTokenDto(
        val firebaseResponse: SignInFirebaseResponseDto,
        val token: String
    )

    data class SignInFirebaseResponseDto(
        val idToken: String,
        val refreshToken: String,
        val expiresIn: String
    )

    data class MockIdTokenRequestDto(
        val role: Role?
    )

    @PostMapping("/mock-id-token")
    fun mockIdToken(@RequestBody input: MockIdTokenRequestDto): MockTokenDto {
        return adminService.getMockToken(role = input.role, uid = "mock_id")
    }

    data class SendNotificationInput(
        val fcmToken: String,
        val title: String,
        val body: String,
    )

//    @PutMapping("/send-mock-notification")
//    suspend fun sendNotification(
//        @RequestBody input: SendNotificationInput,
//    ) {
//        firebaseService.sendFeedbackReceivedNotifications(
//            listOf(
//                FeedbackReceivedNotification(
//                    title = input.title,
//                    body = input.body,
//                    fcmToken = input.fcmToken,
//                    data = mapOf()
//                )
//            )
//        )
//    }

    data class FeedbackReceivedNotificationInput(
        val eventEntity: EventEntity,
        val fcmToken: String,
    )

//    @PutMapping("/mock-feedback-received-notification")
//    suspend fun sendFeedbackReceivedNotification(
//        @RequestBody input: FeedbackReceivedNotificationInput
//    ) {
//        notificationService.sendPushNotificationToOrganizerThatFeedbackIsReceived(
//            event = input.eventEntity,
//            fcmToken = input.fcmToken
//        )
//    }
}

