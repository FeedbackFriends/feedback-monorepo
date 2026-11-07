package dk.example.feedback.tests

import com.fasterxml.jackson.databind.ObjectMapper
import dk.example.feedback.config.SecurityConfig
import dk.example.feedback.persistence.repo.AccountRepo
import dk.example.feedback.persistence.repo.TeamRepo
import dk.example.feedback.model.exceptions.TeamConflictException
import dk.example.feedback.model.exceptions.ForbiddenResourceAccessException
import dk.example.feedback.model.exceptions.TeamNotFoundException
import dk.example.feedback.model.team.TeamRequestStatus
import dk.example.feedback.utils.TestConfig
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.Import
import org.springframework.test.context.TestPropertySource
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.http.MediaType
import javax.sql.DataSource
import java.util.UUID
import java.util.concurrent.Callable
import java.util.concurrent.Executors

@SpringBootTest
@AutoConfigureMockMvc
@Import(TestConfig::class, SecurityConfig::class)
@TestPropertySource(properties = ["spring.datasource.url=jdbc:h2:mem:teams;MODE=PostgreSQL;DATABASE_TO_UPPER=false"])
class TeamTest(
    @Autowired private val repo: TeamRepo,
    @Autowired private val accounts: AccountRepo,
    @Autowired private val mvc: MockMvc,
    @Autowired private val mapper: ObjectMapper,
    @Autowired private val dataSource: DataSource,
) {
    private fun account(): String = UUID.randomUUID().toString().also { accounts.createOrGetAccount(null, null, null, it) }
    private fun team(owner: String): UUID = UUID.randomUUID().also {
        repo.createOrganization(owner, UUID.randomUUID(), "Organization", it, "IT")
    }

    @Test
    fun `rotation preserves pending requests approval creates one member removal denies access`() {
        val owner = account(); val employee = account(); val team = team(owner)
        val code = repo.management(owner, team).inviteCode
        val id = UUID.randomUUID()
        repo.join(employee, id, code, "Ada")
        assertThrows(ForbiddenResourceAccessException::class.java) { repo.requireMember(employee, team) }
        repo.rotateInvite(owner, team)
        assertThrows(TeamNotFoundException::class.java) { repo.resolveInvite(code) }
        assertEquals(id, repo.join(employee, id, code, "Ada").request?.id)
        repo.decide(owner, team, id, true)
        repo.decide(owner, team, id, true)
        assertEquals(1, repo.management(owner, team).memberCount)
        assertEquals(team, repo.requireMember(employee, team).id)
        repo.remove(owner, team, employee)
        assertNull(repo.context(employee).membership)
        assertThrows(ForbiddenResourceAccessException::class.java) { repo.requireMember(employee, team) }
        repo.decide(owner, team, id, true)
        assertNull(repo.context(employee).membership)
    }

    @Test
    fun `canceled rejected and superseded requests cannot be restored by delayed actions`() {
        val owner = account(); val employee = account(); val team = team(owner)
        val code = repo.management(owner, team).inviteCode
        val first = UUID.randomUUID()
        repo.join(employee, first, code, "Ada")
        repo.cancel(employee, first)
        assertNull(repo.context(employee).request)
        assertThrows(TeamConflictException::class.java) { repo.decide(owner, team, first, true) }
        val second = UUID.randomUUID()
        repo.join(employee, second, code, "Ada")
        repo.join(employee, first, code, "Ada")
        assertEquals(second, repo.context(employee).request?.id)
        assertThrows(TeamConflictException::class.java) { repo.decide(owner, team, first, true) }
        repo.decide(owner, team, second, false)
        assertEquals(TeamRequestStatus.Rejected, repo.context(employee).request?.status)
        repo.join(employee, UUID.randomUUID(), code, "Ada")
        assertEquals(TeamRequestStatus.Pending, repo.context(employee).request?.status)
    }

    @Test
    fun `concurrent requests for different teams permit only one pending team`() {
        val owner = account(); val employee = account(); val first = team(owner)
        val org = repo.context(owner).organization!!.id
        val second = repo.addTeam(owner, org, UUID.randomUUID(), "Marketing").id
        val codes = listOf(first, second).map { repo.management(owner, it).inviteCode }
        val results = Executors.newFixedThreadPool(2).use { executor ->
            executor.invokeAll(codes.map { code -> Callable {
                try { repo.join(employee, UUID.randomUUID(), code, "Ada"); true } catch (_: TeamConflictException) { false }
            } }).map { it.get() }
        }
        assertEquals(1, results.count { it })
        assertEquals(1, listOf(first, second).sumOf { repo.management(owner, it).pendingRequests.size })
    }

    @Test
    fun `API enforces Google creation and isolates management from employees and legacy managers`() {
        val owner = account(); val employee = account(); val team = team(owner)
        mvc.perform(get("/teams/context")).andExpect(status().isUnauthorized)
        mvc.perform(get("/teams/$team").with(jwt().jwt { it.subject(employee).claim("role", "Manager") }))
            .andExpect(status().isForbidden)
        val input = mapOf("id" to UUID.randomUUID(), "name" to "Acme", "teamId" to UUID.randomUUID(), "teamName" to "Product")
        mvc.perform(post("/teams/organizations").with(jwt().jwt { it.subject(employee) })
            .contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(input))).andExpect(status().isForbidden)
        mvc.perform(post("/teams/organizations").with(jwt().jwt {
            it.subject(employee).claim("firebase", mapOf("sign_in_provider" to "google.com"))
        }).contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(input))).andExpect(status().isOk)
    }
    private fun invite(owner: String, team: UUID, email: String): String =
        repo.inviteLeader(owner, team, UUID.randomUUID(), email).invitations.last().code

    @Test
    fun `assigned leaders have one team and revocation cannot be undone by consumed links`() {
        val owner = account(); val leader = account(); val other = account(); val first = team(owner)
        val org = repo.context(owner).organization!!.id
        val second = repo.addTeam(owner, org, UUID.randomUUID(), "Product").id
        val code = invite(owner, first, "ada@example.com")
        assertThrows(ForbiddenResourceAccessException::class.java) { repo.acceptLeadership(leader, code, "wrong@example.com") }
        val context = repo.acceptLeadership(leader, code, "ada@example.com")
        assertFalse(context.isOwner)
        assertEquals(org, context.organization!!.id)
        assertEquals(listOf(first), context.managedTeams.map { it.id })
        assertEquals(first, repo.management(leader, first).team.id)
        assertThrows(ForbiddenResourceAccessException::class.java) { repo.management(leader, second) }
        assertThrows(ForbiddenResourceAccessException::class.java) { repo.addTeam(leader, org, UUID.randomUUID(), "No") }
        assertThrows(ForbiddenResourceAccessException::class.java) { repo.leadership(leader, first) }
        assertThrows(TeamConflictException::class.java) { repo.join(leader, UUID.randomUUID(), repo.management(owner, first).inviteCode, "Ada") }
        repo.acceptLeadership(leader, code, "ada@example.com")
        repo.acceptLeadership(other, invite(owner, first, "bo@example.com"), "bo@example.com")
        assertEquals(2, repo.leadership(owner, first).leaders.size)
        val unusedCode = invite(owner, first, "ada@example.com")
        repo.removeLeader(owner, first, leader)
        assertThrows(TeamNotFoundException::class.java) { repo.acceptLeadership(leader, unusedCode, "ada@example.com") }
        assertNull(repo.context(leader).organization)
        assertThrows(ForbiddenResourceAccessException::class.java) { repo.management(leader, first) }
        assertThrows(TeamConflictException::class.java) { repo.acceptLeadership(leader, code, "ada@example.com") }
        assertEquals(first, repo.management(other, first).team.id)
        assertEquals(2, repo.context(owner).managedTeams.size)
        assertTrue(repo.context(owner).isOwner)
    }

    @Test
    fun `concurrent leader acceptance permits only one assigned team and cannot promote employees`() {
        val owner = account(); val leader = account(); val first = team(owner)
        val second = repo.addTeam(owner, repo.context(owner).organization!!.id, UUID.randomUUID(), "Product").id
        val codes = listOf(first, second).map { invite(owner, it, "ada@example.com") }
        val results = Executors.newFixedThreadPool(2).use { executor ->
            executor.invokeAll(codes.map { code -> Callable {
                try { repo.acceptLeadership(leader, code, "ada@example.com"); true } catch (_: TeamConflictException) { false }
            } }).map { it.get() }
        }
        assertEquals(1, results.count { it })
        val employee = account()
        val request = UUID.randomUUID()
        repo.join(employee, request, repo.management(owner, first).inviteCode, "Employee")
        val code = invite(owner, first, "employee@example.com")
        assertThrows(TeamConflictException::class.java) { repo.acceptLeadership(employee, code, "employee@example.com") }
        repo.decide(owner, first, request, true)
        assertThrows(TeamConflictException::class.java) { repo.acceptLeadership(employee, code, "employee@example.com") }
        repo.leave(employee, first)
        repo.acceptLeadership(employee, code, "employee@example.com")
    }

    @Test
    fun `leader invitations require verified matching Google email and owner only controls`() {
        val owner = account(); val leader = account(); val first = team(owner)
        val id = UUID.randomUUID()
        val code = repo.inviteLeader(owner, first, id, "ada@example.com").invitations.single().code
        assertEquals(code, repo.inviteLeader(owner, first, id, "ada@example.com").invitations.single().code)
        fun accept(email: String, verified: Boolean, provider: String) = mvc.perform(
            post("/teams/leader-invitations/accept").with(jwt().jwt {
                it.subject(leader).claim("email", email).claim("email_verified", verified)
                    .claim("firebase", mapOf("sign_in_provider" to provider))
            }).contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(mapOf("code" to code)))
        )
        accept("ada@example.com", false, "google.com").andExpect(status().isForbidden)
        accept("ada@example.com", true, "anonymous").andExpect(status().isForbidden)
        accept("wrong@example.com", true, "google.com").andExpect(status().isForbidden)
        accept("ADA@example.com", true, "google.com").andExpect(status().isOk)
        mvc.perform(post("/teams/$first/leaders/invitations").with(jwt().jwt { it.subject(leader) })
            .contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(mapOf("id" to UUID.randomUUID(), "email" to "bo@example.com"))))
            .andExpect(status().isForbidden)
        mvc.perform(delete("/teams/$first/leaders/$leader").with(jwt().jwt { it.subject(owner) })).andExpect(status().isOk)
        mvc.perform(get("/teams/$first").with(jwt().jwt { it.subject(leader).claim("role", "Manager") })).andExpect(status().isForbidden)
        val pending = repo.inviteLeader(owner, first, UUID.randomUUID(), "bo@example.com").invitations.single()
        repo.revokeLeaderInvite(owner, first, pending.id)
        assertThrows(TeamNotFoundException::class.java) { repo.leaderInvitation(pending.code) }
        assertThrows(TeamNotFoundException::class.java) { repo.acceptLeadership(account(), pending.code, "bo@example.com") }
    }

    @Test
    fun `expired leader invitation cannot be inspected or accepted`() {
        val owner = account(); val first = team(owner)
        val invitation = repo.inviteLeader(owner, first, UUID.randomUUID(), "ada@example.com").invitations.single()
        dataSource.connection.use { connection ->
            connection.prepareStatement("UPDATE team_leader_invitation SET expires_at = 0 WHERE id = ?").use { statement ->
                statement.setObject(1, invitation.id)
                statement.executeUpdate()
            }
        }
        assertThrows(TeamNotFoundException::class.java) { repo.leaderInvitation(invitation.code) }
        assertThrows(TeamNotFoundException::class.java) { repo.acceptLeadership(account(), invitation.code, "ada@example.com") }
    }

    @Test
    fun `invalid employee invitation explains how to recover in the requested language`() {
        val employee = account()
        listOf("da" to "Ugyldig invitationskode", "en" to "Invalid invitation code").forEach { (language, title) ->
            mvc.perform(post("/teams/requests").with(jwt().jwt { it.subject(employee) })
                .header("Accept-Language", language).contentType(MediaType.APPLICATION_JSON)
                .content(mapper.writeValueAsString(mapOf("id" to UUID.randomUUID(), "code" to "invalid", "name" to "Ada"))))
                .andExpect(status().isNotFound).andExpect(jsonPath("$.userTitle").value(title))
        }
    }

    @Test
    fun `all management routes enforce assigned team and owner boundaries`() {
        val owner = account(); val leader = account(); val first = team(owner)
        val second = repo.addTeam(owner, repo.context(owner).organization!!.id, UUID.randomUUID(), "Product").id
        repo.acceptLeadership(leader, invite(owner, first, "ada@example.com"), "ada@example.com")
        val requestId = UUID.randomUUID()
        listOf(
            get("/teams/$second"), post("/teams/$second/invite"),
            post("/teams/$second/requests/$requestId/approve"), post("/teams/$second/requests/$requestId/reject"),
            delete("/teams/$second/members/$leader"), get("/teams/$first/leaders"),
            delete("/teams/$first/leaders/invitations/$requestId"), delete("/teams/$first/leaders/$owner"),
        ).forEach { request ->
            mvc.perform(request).andExpect(status().isUnauthorized)
            mvc.perform(request.with(jwt().jwt { it.subject(leader).claim("role", "Manager") })).andExpect(status().isForbidden)
        }
        val input = mapper.writeValueAsString(mapOf("id" to UUID.randomUUID(), "email" to "bo@example.com"))
        mvc.perform(post("/teams/$first/leaders/invitations").with(jwt().jwt { it.subject(leader) })
            .contentType(MediaType.APPLICATION_JSON).content(input)).andExpect(status().isForbidden)
        mvc.perform(get("/teams/$first").with(jwt().jwt { it.subject(leader) })).andExpect(status().isOk)
    }

}
