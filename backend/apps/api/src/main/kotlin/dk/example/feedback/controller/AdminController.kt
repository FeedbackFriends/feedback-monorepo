package dk.example.feedback.controller

import dk.example.feedback.firebase.FeedbackReceivedNotification
import dk.example.feedback.firebase.FirebaseService
import dk.example.feedback.service.AdminService
import io.swagger.v3.oas.annotations.tags.Tag
import java.util.UUID
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
        val token: String,
    )

    data class SignInFirebaseResponseDto(
        val idToken: String,
        val refreshToken: String,
        val expiresIn: String,
    )

    data class AdminLoginRequestDto(
        val id: String,
    )

    @PostMapping("/login")
    fun login(@RequestBody input: AdminLoginRequestDto): MockTokenDto {
        return adminService.login(id = input.id)
    }

    @PostMapping("/seed-manager-empty")
    fun seedManagerEmpty(): MockTokenDto {
        return adminService.seedManagerEmpty()
    }

    @PostMapping("/seed-empty-account")
    fun seedEmptyAccount(): MockTokenDto {
        return adminService.seedEmptyAccount()
    }

    @PostMapping("/seed-manager-with-data")
    fun seedManagerWithData(): MockTokenDto {
        return adminService.seedManagerWithData()
    }

    @PostMapping("/seed-participant-empty")
    fun seedParticipantEmpty(): MockTokenDto {
        return adminService.seedParticipantEmpty()
    }

    @PostMapping("/seed-participant-with-data")
    fun seedParticipantWithData(): MockTokenDto {
        return adminService.seedParticipantWithData()
    }

    @PostMapping("/reset")
    fun resetDatabase() {
        adminService.resetDatabase()
    }

    data class SendNotificationInput(
        val fcmToken: String,
        val title: String,
        val newFeedback: Int,
        val eventId: UUID,
    )

    @PutMapping("/mock-new-feedback-notification")
    suspend fun sendNotification(
        @RequestBody input: SendNotificationInput,
    ) {
        firebaseService.pushFeedbackReceivedNotifications(
            listOf(
                FeedbackReceivedNotification(
                    fcmToken = input.fcmToken,
                    newFeedback = input.newFeedback,
                    eventTitle = input.title,
                    eventId = input.eventId,
                ),
            ),
        )
    }
}
