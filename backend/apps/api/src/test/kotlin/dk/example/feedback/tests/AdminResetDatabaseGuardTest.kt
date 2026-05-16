package dk.example.feedback.tests

import dk.example.feedback.config.SecurityConfig
import dk.example.feedback.utils.TestConfig
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.Import
import org.springframework.test.context.TestPropertySource
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@SpringBootTest
@AutoConfigureMockMvc
@Import(TestConfig::class, SecurityConfig::class)
@TestPropertySource(
    properties = [
        "spring.datasource.url=jdbc:h2:mem:adminresetguard;MODE=PostgreSQL;DATABASE_TO_UPPER=false",
        "feedback.enable-test-admin-endpoints=true",
        "feedback.enable-test-admin-database-reset=false",
    ],
)
class AdminResetDatabaseGuardTest(
    @Autowired private val mockMvc: MockMvc,
) {
    @Test
    fun `reset database endpoint returns error when reset flag is disabled`() {
        mockMvc.perform(post("/admin/reset"))
            .andExpect(status().isInternalServerError)
    }
}
