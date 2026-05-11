package dk.example.feedback.service

import com.fasterxml.jackson.databind.ObjectMapper
import dk.example.feedback.config.FeedbackConfig
import dk.example.feedback.controller.AdminController.MockTokenDto
import dk.example.feedback.controller.AdminController.SignInFirebaseResponseDto
import dk.example.feedback.firebase.FirebaseAdminService
import dk.example.feedback.firebase.FirebaseService
import dk.example.feedback.model.enumerations.Role
import dk.example.feedback.persistence.repo.AccountRepo
import dk.example.feedback.persistence.repo.MockRepo
import javax.sql.DataSource
import liquibase.Contexts
import liquibase.LabelExpression
import liquibase.Liquibase
import liquibase.database.DatabaseFactory
import liquibase.database.jvm.JdbcConnection
import liquibase.resource.ClassLoaderResourceAccessor
import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import org.springframework.web.client.RestTemplate
import org.springframework.web.client.postForEntity
import org.springframework.web.server.ResponseStatusException

@Service
class AdminService(
    val feedbackConfig: FeedbackConfig,
    val accountRepo: AccountRepo,
    val firebaseAdminService: FirebaseAdminService,
    val firebaseService: FirebaseService,
    val objectMapper: ObjectMapper,
    val mockRepo: MockRepo,
    val dataSource: DataSource,
    @Value("\${spring.liquibase.change-log:classpath:db/changelog/db.changelog-master.yaml}")
    val liquibaseChangeLog: String,
) {
    companion object {
        private const val firebaseOnlyEmptyId = "mock-firebase-only-empty"
        private const val managerEmptyId = "mock-manager-empty"
        private const val managerWithDataId = "mock-manager-with-data"
        private const val participantEmptyId = "mock-participant-empty"
        private const val participantWithDataId = "mock-participant-with-data"
        private val seededFirebaseUserIds = setOf(
            firebaseOnlyEmptyId,
            managerEmptyId,
            managerWithDataId,
            participantEmptyId,
            participantWithDataId,
        )
    }

    fun login(id: String): MockTokenDto {
        ensureTestAdminEndpointsEnabled()
        val token = firebaseAdminService.createCustomToken(uid = id)
        return signInWithCustomToken(token = token)
    }

    fun seedManagerEmpty(): MockTokenDto {
        ensureTestAdminEndpointsEnabled()
        resetSeedState(seedId = managerEmptyId)
        prepareMockIdentity(uid = managerEmptyId, role = Role.Manager)
        return signInFor(uid = managerEmptyId)
    }

    fun seedEmptyAccount(): MockTokenDto {
        ensureTestAdminEndpointsEnabled()
        resetSeedState(seedId = firebaseOnlyEmptyId)
        firebaseAdminService.createUserIfMissing(
            uid = firebaseOnlyEmptyId,
            email = "$firebaseOnlyEmptyId@email.dk",
            displayName = "Mock Firebase Only",
        )
        return signInFor(uid = firebaseOnlyEmptyId)
    }

    fun seedManagerWithData(): MockTokenDto {
        ensureTestAdminEndpointsEnabled()
        mockRepo.resetManagerWithData(managerId = managerWithDataId)
        resetSeedState(
            seedId = managerWithDataId,
            accountIds = setOf(
                managerWithDataId,
                "$managerWithDataId-participant",
            ),
        )
        prepareMockIdentity(uid = managerWithDataId, role = Role.Manager)
        mockRepo.insertManagerWithData(managerId = managerWithDataId)
        return signInFor(uid = managerWithDataId)
    }

    fun seedParticipantEmpty(): MockTokenDto {
        ensureTestAdminEndpointsEnabled()
        resetSeedState(seedId = participantEmptyId)
        prepareMockIdentity(uid = participantEmptyId, role = Role.Participant)
        return signInFor(uid = participantEmptyId)
    }

    fun seedParticipantWithData(): MockTokenDto {
        ensureTestAdminEndpointsEnabled()
        mockRepo.resetParticipantWithData(participantId = participantWithDataId)
        resetSeedState(
            seedId = participantWithDataId,
            accountIds = setOf(
                participantWithDataId,
                "$participantWithDataId-manager",
            ),
        )
        prepareMockIdentity(uid = participantWithDataId, role = Role.Participant)
        mockRepo.insertParticipantWithData(participantId = participantWithDataId)
        return signInFor(uid = participantWithDataId)
    }

    fun resetDatabase() {
        ensureDatabaseResetEnabled()
        firebaseAdminService.deleteUsers(uids = seededFirebaseUserIds)
        dataSource.connection.use { connection ->
            val database = DatabaseFactory.getInstance()
                .findCorrectDatabaseImplementation(JdbcConnection(connection))
            val changeLog = liquibaseChangeLog.removePrefix("classpath:")
            Liquibase(changeLog, ClassLoaderResourceAccessor(javaClass.classLoader), database).use { liquibase ->
                liquibase.dropAll()
                liquibase.update(Contexts(), LabelExpression())
            }
        }
    }

    private fun ensureTestAdminEndpointsEnabled() {
        if (!feedbackConfig.enableTestAdminEndpoints) {
            throw ResponseStatusException(HttpStatus.NOT_FOUND)
        }
    }

    private fun ensureDatabaseResetEnabled() {
        ensureTestAdminEndpointsEnabled()
        if (!feedbackConfig.enableTestAdminDatabaseReset) {
            throw ResponseStatusException(HttpStatus.NOT_FOUND)
        }
    }

    private fun prepareMockIdentity(uid: String, role: Role) {
        accountRepo.createOrGetAccount(
            name = "Mock",
            email = "$uid@email.dk",
            phoneNumber = "27630505",
            accountId = uid,
        )
        firebaseAdminService.createUserIfMissing(
            uid = uid,
            email = "$uid@email.dk",
            displayName = "Mocked $role",
        )
        firebaseService.setRole(userId = uid, requestedRole = role)
    }

    private fun resetSeedState(seedId: String, accountIds: Set<String> = setOf(seedId)) {
        firebaseAdminService.deleteUsers(uids = setOf(seedId))
        accountIds.forEach { accountId ->
            accountRepo.deleteAccountIfExists(accountId = accountId)
        }
    }

    private fun signInFor(uid: String): MockTokenDto {
        val token = firebaseAdminService.createCustomToken(uid = uid)
        return signInWithCustomToken(token = token)
    }

    fun signInWithCustomToken(token: String): MockTokenDto {
        val apiKey = feedbackConfig.firebaseApiKey
        val url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=$apiKey"
        val body = objectMapper.writeValueAsString(
            mapOf(
                "token" to token,
                "returnSecureToken" to true,
            ),
        )

        val headers = HttpHeaders().apply {
            contentType = MediaType.APPLICATION_JSON
            accept = listOf(MediaType.APPLICATION_JSON)
        }

        val restTemplate = RestTemplate()
        val response: ResponseEntity<SignInFirebaseResponseDto> = restTemplate.postForEntity(
            url = url,
            request = HttpEntity(body, headers),
        )

        if (response.statusCode.is2xxSuccessful) {
            return MockTokenDto(firebaseResponse = response.body!!, token = token)
        }
        throw RuntimeException("Failed to sign in with custom token")
    }
}
