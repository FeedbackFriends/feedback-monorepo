package dk.example.feedback.controller

import dk.example.feedback.firebase.FeedbackReceivedNotification
import dk.example.feedback.firebase.FirebaseService
import dk.example.feedback.model.enumerations.Role
import dk.example.feedback.service.AdminService
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController


@RestController
@Tag(name = "Admin")
@RequestMapping("/admin")
class AdminController(
    val adminService: AdminService,
    val firebaseService: FirebaseService,
) {

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
        val role: Role?,
        val id: String,
    )

    @PostMapping("/mock-id-token")
    fun mockIdToken(@RequestBody input: MockIdTokenRequestDto): MockTokenDto {
        return adminService.getMockToken(role = input.role, uid = input.id)
    }

    data class SendNotificationInput(
        val fcmToken: String,
        val title: String,
        val newFeedback: Int,
    )

    @PutMapping("/push-new-feedback-notification")
    suspend fun sendNotification(
        @RequestBody input: SendNotificationInput,
    ) {
        firebaseService.pushFeedbackReceivedNotifications(
            listOf(
                FeedbackReceivedNotification(
                    fcmToken = input.fcmToken,
                    newFeedback = input.newFeedback,
                    eventTitle = input.title
                )
            )
        )
    }
}

