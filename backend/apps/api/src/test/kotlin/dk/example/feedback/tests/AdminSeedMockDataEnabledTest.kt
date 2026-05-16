package dk.example.feedback.tests

import dk.example.feedback.controller.AdminController.MockTokenDto
import dk.example.feedback.controller.AdminController.SignInFirebaseResponseDto
import dk.example.feedback.config.SecurityConfig
import dk.example.feedback.service.AdminService
import dk.example.feedback.utils.TestConfig
import org.junit.jupiter.api.Test
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.context.annotation.Import
import org.mockito.ArgumentMatchers.anyString
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import org.springframework.test.context.TestPropertySource
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@SpringBootTest
@AutoConfigureMockMvc
@Import(TestConfig::class, SecurityConfig::class)
@TestPropertySource(
    properties = [
        "spring.datasource.url=jdbc:h2:mem:adminseedenabled;MODE=PostgreSQL;DATABASE_TO_UPPER=false",
        "feedback.enable-test-admin-endpoints=true",
        "feedback.enable-test-admin-database-reset=true",
    ],
)
class AdminSeedMockDataEnabledTest(
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
    fun `manager empty seed endpoint returns success`() {
        `when`(adminService.seedManagerEmpty()).thenReturn(tokenDto)

        mockMvc.perform(MockMvcRequestBuilders.post("/admin/seed-manager-empty"))
            .andExpect(status().isOk)

        verify(adminService).seedManagerEmpty()
    }

    @Test
    fun `empty account seed endpoint returns success`() {
        `when`(adminService.seedEmptyAccount()).thenReturn(tokenDto)

        mockMvc.perform(MockMvcRequestBuilders.post("/admin/seed-empty-account"))
            .andExpect(status().isOk)

        verify(adminService).seedEmptyAccount()
    }

    @Test
    fun `manager with data seed endpoint returns success`() {
        `when`(adminService.seedManagerWithData()).thenReturn(tokenDto)

        mockMvc.perform(MockMvcRequestBuilders.post("/admin/seed-manager-with-data"))
            .andExpect(status().isOk)

        verify(adminService).seedManagerWithData()
    }

    @Test
    fun `participant empty seed endpoint returns success`() {
        `when`(adminService.seedParticipantEmpty()).thenReturn(tokenDto)

        mockMvc.perform(MockMvcRequestBuilders.post("/admin/seed-participant-empty"))
            .andExpect(status().isOk)

        verify(adminService).seedParticipantEmpty()
    }

    @Test
    fun `participant with data seed endpoint returns success`() {
        `when`(adminService.seedParticipantWithData()).thenReturn(tokenDto)

        mockMvc.perform(MockMvcRequestBuilders.post("/admin/seed-participant-with-data"))
            .andExpect(status().isOk)

        verify(adminService).seedParticipantWithData()
    }

    @Test
    fun `admin login endpoint accepts id only`() {
        `when`(adminService.login(anyString())).thenReturn(tokenDto)

        mockMvc.perform(
            MockMvcRequestBuilders.post("/admin/login")
                .contentType("application/json")
                .content("""{"id":"mock-manager-empty"}"""),
        ).andExpect(status().isOk)

        verify(adminService).login("mock-manager-empty")
    }

    @Test
    fun `database reset endpoint returns success when enabled`() {
        mockMvc.perform(MockMvcRequestBuilders.post("/admin/reset"))
            .andExpect(status().isOk)

        verify(adminService).resetDatabase()
    }
}
