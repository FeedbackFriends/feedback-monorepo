package dk.example.feedback.tests

import com.fasterxml.jackson.databind.ObjectMapper
import dk.example.feedback.config.SecurityConfig
import dk.example.feedback.model.enumerations.SupportSubmissionKind
import dk.example.feedback.model.enumerations.Emoji
import dk.example.feedback.payloads.SupportClientMetadataInput
import dk.example.feedback.payloads.SupportSubmissionInput
import dk.example.feedback.persistence.repo.AccountRepo
import dk.example.feedback.service.SupportSubmissionService
import dk.example.feedback.utils.TestConfig
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.Import
import org.springframework.http.MediaType
import javax.sql.DataSource
import java.sql.ResultSet
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt
import org.springframework.test.context.TestPropertySource
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import java.util.UUID
import java.util.concurrent.Callable
import java.util.concurrent.Executors

@SpringBootTest
@AutoConfigureMockMvc
@Import(TestConfig::class, SecurityConfig::class)
@TestPropertySource(properties = ["spring.datasource.url=jdbc:h2:mem:supportsubmissions;MODE=PostgreSQL;DATABASE_TO_UPPER=false"])
class SupportSubmissionTest(
    @Autowired private val mvc: MockMvc,
    @Autowired private val mapper: ObjectMapper,
    @Autowired private val accounts: AccountRepo,
    @Autowired private val service: SupportSubmissionService,
    @Autowired private val dataSource: DataSource,
) {
    private val account = UUID.randomUUID().toString()
    private val other = UUID.randomUUID().toString()
    private val metadata = SupportClientMetadataInput("1.2", "42", "27.2")

    @BeforeEach
    fun createAccounts() {
        for (id in listOf(account, other)) accounts.createOrGetAccount(null, null, null, id)
    }

    @AfterEach
    fun removeAccounts() {
        accounts.deleteAccountIfExists(account)
        accounts.deleteAccountIfExists(other)
    }

    @Test
    fun `anonymous and owner submissions persist separately without meeting side effects and retries return original receipt`() {
        val before = listOf("feedback", "event_participant", "new_feedback_notification").associateWith(::count)
        val version = accounts.getAccount(account).bootstrapVersion
        for ((kind, role) in listOf("ProductFeedback" to null, "BugReport" to "manager")) {
            val id = UUID.randomUUID()
            val input = mapOf(
                "id" to id, "kind" to kind, "message" to "  Useful description  ",
                "metadata" to metadata, "contactEmail" to "reply@example.com",
            )
            val first = submit(input, account, role).andExpect(status().isOk).andReturn().response.contentAsString
            val repeated = submit(input, account, role).andExpect(status().isOk).andReturn().response.contentAsString
            assertEquals(first, repeated)
            assertEquals(id.toString(), mapper.readTree(first)["id"].asText())
            assertEquals(1L, query("SELECT COUNT(*) FROM support_submission WHERE id = ?", id) { it.getLong(1) })
            assertEquals("Useful description", query("SELECT message FROM support_submission WHERE id = ?", id) { it.getString(1) })
        }
        before.forEach { (table, rows) -> assertEquals(rows, count(table)) }
        assertEquals(version, accounts.getAccount(account).bootstrapVersion)
    }

    @Test
    fun `changed content conflicts and another account cannot reuse a submission id`() {
        val input = SupportSubmissionInput(UUID.randomUUID(), SupportSubmissionKind.BugReport, message = "Details", metadata = metadata)
        submit(input).andExpect(status().isOk)
        submit(input.copy(message = "Changed")).andExpect(status().isConflict)
        submit(input, other).andExpect(status().isForbidden)
        assertEquals(1L, query("SELECT COUNT(*) FROM support_submission WHERE id = ?", input.id) { it.getLong(1) })
    }

    @Test
    fun `missing auth whitespace limits email and metadata are validated`() {
        val valid = SupportSubmissionInput(UUID.randomUUID(), SupportSubmissionKind.BugReport, message = "Details", metadata = metadata)
        mvc.perform(post("/support/submissions").contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(valid)))
            .andExpect(status().isUnauthorized)
        val invalid = listOf(
            valid.copy(message = " \n "), valid.copy(message = "a".repeat(5001)),
            valid.copy(expectedBehavior = "a".repeat(5001)), valid.copy(contactEmail = "invalid"),
            valid.copy(metadata = metadata.copy(osVersion = " ")),
            valid.copy(metadata = metadata.copy(appBuild = "a".repeat(101))),
            valid.copy(rating = Emoji.Happy),
            valid.copy(kind = SupportSubmissionKind.ProductFeedback, message = null),
        )
        invalid.forEach { submit(it).andExpect(status().isBadRequest) }
        assertEquals(0L, query("SELECT COUNT(*) FROM support_submission WHERE account_id = ?", account) { it.getLong(1) })
    }

    @Test
    fun `rating-only feedback and the maximum valid message are accepted`() {
        val feedback = SupportSubmissionInput(
            UUID.randomUUID(), SupportSubmissionKind.ProductFeedback, rating = Emoji.Happy, metadata = metadata,
        )
        submit(feedback).andExpect(status().isOk)
        assertEquals("Happy", query("SELECT rating FROM support_submission WHERE id = ?", feedback.id) { it.getString(1) })
        assertEquals(null, query("SELECT message FROM support_submission WHERE id = ?", feedback.id) { it.getString(1) })
        val bug = feedback.copy(id = UUID.randomUUID(), kind = SupportSubmissionKind.BugReport, rating = null, message = "a".repeat(5000))
        submit(bug).andExpect(status().isOk)
        assertEquals(5000, query("SELECT message FROM support_submission WHERE id = ?", bug.id) { it.getString(1).length })
    }

    @Test
    fun `concurrent retries create one record and deletion cascades through the applied migration`() {
        val input = SupportSubmissionInput(UUID.randomUUID(), SupportSubmissionKind.BugReport, message = "Details", metadata = metadata)
        val receipts = Executors.newFixedThreadPool(2).use { executor ->
            executor.invokeAll(List(2) { Callable { service.submit(input, account) } }).map { it.get() }
        }
        assertEquals(receipts[0], receipts[1])
        assertEquals(1L, query("SELECT COUNT(*) FROM support_submission WHERE id = ?", input.id) { it.getLong(1) })
        accounts.deleteAccount(account)
        assertEquals(0L, query("SELECT COUNT(*) FROM support_submission WHERE id = ?", input.id) { it.getLong(1) })
    }

    private fun count(table: String): Long = query("SELECT COUNT(*) FROM $table") { it.getLong(1) }

    private fun <T> query(sql: String, vararg parameters: Any, read: (ResultSet) -> T): T = dataSource.connection.use { connection ->
        connection.prepareStatement(sql).use { statement ->
            parameters.forEachIndexed { index, value -> statement.setObject(index + 1, value) }
            statement.executeQuery().use { rows ->
                check(rows.next())
                read(rows)
            }
        }
    }

    private fun submit(input: Any, actor: String = account, role: String? = null) = mvc.perform(
        post("/support/submissions").with(jwt().jwt { builder ->
            builder.subject(actor)
            if (role != null) builder.claim("role", role)
        }).contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(input)),
    )
}
