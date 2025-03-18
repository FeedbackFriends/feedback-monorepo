package dk.example.feedback.controller

import dk.example.feedback.model.enumerations.Role
import dk.example.feedback.service.AdminService
import dk.example.feedback.service.firebase.FirebaseNotification
import dk.example.feedback.service.firebase.FirebaseService
import io.swagger.v3.oas.annotations.tags.Tag
import org.slf4j.LoggerFactory
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
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
    private val firebaseService: FirebaseService
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
    suspend fun mockIdToken(@RequestBody input: MockIdTokenRequestDto): MockTokenDto {
        return adminService.getMockToken(role = input.role, uid = "mock_id")
    }

    data class SendNotificationInput(
        val fcmToken: String,
        val title: String,
        val body: String,
    )

    @PutMapping("/send-mock-notification")
    suspend fun sendNotification(
        @AuthenticationPrincipal principal: Jwt,
        @RequestBody input: SendNotificationInput,
    ) {
        firebaseService.sendNotifications(
            listOf(
                FirebaseNotification(
                    title = input.title,
                    body = input.body,
                    fcmToken = input.fcmToken,
                    data = mapOf()
                )
            )
        )
    }
}

