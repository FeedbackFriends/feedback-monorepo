package dk.example.feedback.service

import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import dk.example.feedback.config.FeedbackConfig
import dk.example.feedback.controller.AdminController.MockTokenDto
import dk.example.feedback.controller.AdminController.TestSessionDto
import dk.example.feedback.persistence.repo.AccountRepo
import dk.example.feedback.persistence.repo.MockRepo
import javax.sql.DataSource
import liquibase.Contexts
import liquibase.LabelExpression
import liquibase.Liquibase
import liquibase.database.DatabaseFactory
import liquibase.database.jvm.JdbcConnection
import liquibase.resource.ClassLoaderResourceAccessor
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import org.springframework.http.HttpStatus
import org.springframework.web.server.ResponseStatusException

@Service
class AdminService(
    private val feedbackConfig: FeedbackConfig,
    private val accountRepo: AccountRepo,
    private val sessions: SupabaseTestAccounts,
    private val objectMapper: ObjectMapper,
    private val mockRepo: MockRepo,
    private val dataSource: DataSource,
    @Value("\${spring.liquibase.change-log:classpath:db/changelog/db.changelog-master.yaml}")
    private val liquibaseChangeLog: String,
) {
    fun login(id: String): MockTokenDto = token(sessions.session(id))
    fun seedManagerEmpty(): MockTokenDto = seed("mock-manager-empty")
    fun seedEmptyAccount(): MockTokenDto = token(sessions.session("mock-firebase-only-empty"))
    fun seedManagerWithData(): MockTokenDto = seed("mock-manager-with-data", withData = true)
    fun seedParticipantEmpty(): MockTokenDto = seed(null, anonymous = true)
    fun seedParticipantWithData(): MockTokenDto = seed(null, anonymous = true, withData = true)

    private fun seed(label: String?, anonymous: Boolean = false, withData: Boolean = false): MockTokenDto {
        val session = sessions.session(label, anonymous)
        val id = "supabase:${session.required("user").required("id").asText()}"
        if (withData) {
            if (anonymous) mockRepo.resetParticipantWithData(participantId = id)
            else mockRepo.resetManagerWithData(managerId = id)
        }
        accountRepo.deleteAccountIfExists(id)
        accountRepo.createOrGetAccount("Mock", if (anonymous) null else session["user"]["email"].asText(), null, id)
        if (withData) {
            if (anonymous) mockRepo.insertParticipantWithData(participantId = id)
            else mockRepo.insertManagerWithData(managerId = id)
        }
        return token(session)
    }

    private fun token(session: JsonNode): MockTokenDto {
        val access = session.required("access_token").asText()
        val refresh = session.required("refresh_token").asText()
        return MockTokenDto(
            session = TestSessionDto(access, refresh, session.required("expires_in").asText()),
            token = objectMapper.writeValueAsString(mapOf("accessToken" to access, "refreshToken" to refresh)),
        )
    }

    fun resetDatabase() {
        if (!feedbackConfig.enableTestAdminEndpoints || !feedbackConfig.enableTestAdminDatabaseReset)
            throw ResponseStatusException(HttpStatus.NOT_FOUND)
        dataSource.connection.use { connection ->
            val database = DatabaseFactory.getInstance().findCorrectDatabaseImplementation(JdbcConnection(connection))
            Liquibase(liquibaseChangeLog.removePrefix("classpath:"), ClassLoaderResourceAccessor(javaClass.classLoader), database).use {
                it.dropAll()
                it.update(Contexts(), LabelExpression())
            }
        }
    }
}
