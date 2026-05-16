package dk.example.feedback.tests

import dk.example.feedback.config.SecurityConfig
import dk.example.feedback.controller.AdminController.MockTokenDto
import dk.example.feedback.controller.AdminController.SignInFirebaseResponseDto
import dk.example.feedback.service.AdminService
import dk.example.feedback.utils.TestConfig
import org.junit.jupiter.api.Test
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.context.annotation.Import
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt
import org.springframework.test.context.TestPropertySource
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@SpringBootTest
@AutoConfigureMockMvc
@Import(TestConfig::class, SecurityConfig::class)
@TestPropertySource(
    properties = [
        "spring.datasource.url=jdbc:h2:mem:adminsecurity;MODE=PostgreSQL;DATABASE_TO_UPPER=false",
        "feedback.enable-test-admin-endpoints=false",
        "feedback.admin-emails=nicolaidam96@gmail.com",
    ],
)
class AdminSecurityAccessTest(
    @Autowired private val mockMvc: MockMvc,
) {
    @MockBean
    lateinit var adminService: AdminService

    private val tokenDto = MockTokenDto(
        firebaseResponse = SignInFirebaseResponseDto(
            idToken = "id-token",
            refreshToken = "refresh-token",
            expiresIn = "3600",
        ),
        token = "custom-token",
    )

    @Test
    fun `admin endpoint denies unauthenticated request when test admin endpoints are disabled`() {
        mockMvc.perform(post("/admin/seed-manager-empty"))
            .andExpect(status().is4xxClientError)

        verify(adminService, never()).seedManagerEmpty()
    }

    @Test
    fun `admin endpoint denies authenticated non-admin email when test admin endpoints are disabled`() {
        mockMvc.perform(
            post("/admin/seed-manager-empty")
                .with(jwt().jwt { it.claim("email", "not-admin@example.com") }),
        ).andExpect(status().isForbidden)

        verify(adminService, never()).seedManagerEmpty()
    }

    @Test
    fun `admin endpoint allows authenticated configured admin email when test admin endpoints are disabled`() {
        `when`(adminService.seedManagerEmpty()).thenReturn(tokenDto)

        mockMvc.perform(
            post("/admin/seed-manager-empty")
                .with(jwt().jwt { it.claim("email", "nicolaidam96@gmail.com") }),
        ).andExpect(status().isOk)

        verify(adminService).seedManagerEmpty()
    }

    @Test
    fun `database reset endpoint allows configured admin email when test admin endpoints are disabled`() {
        mockMvc.perform(
            post("/admin/reset")
                .with(jwt().jwt { it.claim("email", "nicolaidam96@gmail.com") }),
        ).andExpect(status().isOk)

        verify(adminService).resetDatabase()
    }
}
