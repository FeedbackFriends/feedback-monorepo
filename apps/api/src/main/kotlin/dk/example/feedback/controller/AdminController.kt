package dk.example.feedback.controller

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
    val adminService: AdminService
) {

    private val logger = LoggerFactory.getLogger(AdminController::class.java)

    data class MockTokenResponse(
        val firebaseResponse: SignInFirebaseResponseDto,
        val token: String
    )

    data class MockIdTokenRequestDto(
        val role: Role?
    )

    @PostMapping("/mockIdToken")
    suspend fun mockIdToken(@RequestBody input: MockIdTokenRequestDto): MockTokenResponse {
        return adminService.getMockToken(role = input.role, uid = "mock_id")
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
}

