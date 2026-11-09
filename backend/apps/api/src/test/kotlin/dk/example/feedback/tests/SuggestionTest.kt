package dk.example.feedback.tests

import com.fasterxml.jackson.databind.ObjectMapper
import dk.example.feedback.config.SecurityConfig
import dk.example.feedback.model.exceptions.ForbiddenResourceAccessException
import dk.example.feedback.model.exceptions.TeamConflictException
import dk.example.feedback.model.exceptions.TeamNotFoundException
import dk.example.feedback.persistence.repo.AccountRepo
import dk.example.feedback.persistence.repo.SuggestionRepo
import dk.example.feedback.persistence.repo.TeamRepo
import dk.example.feedback.utils.TestConfig
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.Import
import org.springframework.http.MediaType
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt
import org.springframework.test.context.TestPropertySource
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.*
import java.util.UUID
import java.util.concurrent.Callable
import java.util.concurrent.Executors

@SpringBootTest
@AutoConfigureMockMvc
@Import(TestConfig::class, SecurityConfig::class)
@TestPropertySource(properties = ["spring.datasource.url=jdbc:h2:mem:suggestions;MODE=PostgreSQL;DATABASE_TO_UPPER=false"])
class SuggestionTest(
    @Autowired private val suggestions: SuggestionRepo,
    @Autowired private val teams: TeamRepo,
    @Autowired private val accounts: AccountRepo,
    @Autowired private val mvc: MockMvc,
    @Autowired private val mapper: ObjectMapper,
) {
    private fun account() = UUID.randomUUID().toString().also { accounts.createOrGetAccount(null, null, null, it) }
    private fun team(owner: String) = UUID.randomUUID().also { teams.createOrganization(owner, UUID.randomUUID(), "Acme", it, "IT") }
    private fun member(owner: String, team: UUID): String = account().also {
        val request = UUID.randomUUID()
        teams.join(it, request, teams.management(owner, team).inviteCode, "Employee")
        teams.decide(owner, team, request, true)
    }

    @Test
    fun `only approved current team members participate and responses contain no identities`() {
        val owner = account(); val team = team(owner); val author = member(owner, team); val other = member(owner, team)
        val id = UUID.randomUUID()
        val input = mapOf("id" to id, "problem" to " Meetings ", "impact" to " Focus ", "solution" to " ")
        fun create(actor: String) = mvc.perform(post("/teams/$team/suggestions").with(jwt().jwt { it.subject(actor) })
            .contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(input)))
        create(owner).andExpect(status().isForbidden)
        create(account()).andExpect(status().isForbidden)
        create(author).andExpect(status().isOk).andExpect(jsonPath("$[0].problem").value("Meetings"))
        mvc.perform(get("/teams/$team/suggestions")).andExpect(status().isUnauthorized)
        val body = mvc.perform(get("/teams/$team/suggestions").with(jwt().jwt { it.subject(other) }))
            .andExpect(status().isOk).andExpect(jsonPath("$[0].mine").value(false)).andReturn().response.contentAsString
        val fields = mapper.readTree(body)[0].fieldNames().asSequence().toSet()
        assertEquals(setOf("id", "problem", "impact", "solution", "supportCount", "supportedByMe", "mine"), fields)
        assertFalse(body.contains(author))
        val otherOwner = account(); val otherTeam = team(otherOwner); val outsider = member(otherOwner, otherTeam)
        assertThrows(ForbiddenResourceAccessException::class.java) { suggestions.list(outsider, team) }
        teams.remove(owner, team, other)
        assertThrows(ForbiddenResourceAccessException::class.java) { suggestions.support(other, team, id, true) }
        mvc.perform(post("/teams/$team/suggestions").with(jwt().jwt { it.subject(author) }).contentType(MediaType.APPLICATION_JSON)
            .content(mapper.writeValueAsString(input + ("problem" to " ")))).andExpect(status().isBadRequest)
        mvc.perform(post("/teams/$team/suggestions").with(jwt().jwt { it.subject(author) }).contentType(MediaType.APPLICATION_JSON)
            .content(mapper.writeValueAsString(input + ("impact" to "x".repeat(1001))))).andExpect(status().isBadRequest)
    }

    @Test
    fun `creation retries support retries and concurrent duplicate support stay idempotent`() {
        val owner = account(); val team = team(owner); val author = member(owner, team); val voter = member(owner, team)
        val id = UUID.randomUUID()
        repeat(2) { suggestions.create(author, team, id, "Meetings", "Focus", null) }
        assertEquals(1, suggestions.list(author, team).size)
        assertThrows(TeamConflictException::class.java) { suggestions.create(author, team, id, "Changed", "Focus", null) }
        assertThrows(ForbiddenResourceAccessException::class.java) { suggestions.create(voter, team, id, "Meetings", "Focus", null) }
        Executors.newFixedThreadPool(4).use { executor ->
            executor.invokeAll((1..4).map { Callable { suggestions.support(voter, team, id, true) } }).forEach { it.get() }
        }
        var item = suggestions.list(voter, team).single()
        assertEquals(1L, item.supportCount); assertTrue(item.supportedByMe); assertFalse(item.mine)
        item = suggestions.list(author, team).single()
        assertTrue(item.mine); assertFalse(item.supportedByMe)
        repeat(2) { suggestions.support(voter, team, id, false) }
        assertEquals(0L, suggestions.list(author, team).single().supportCount)
        val anotherOwner = account(); val anotherTeam = team(anotherOwner); val outsider = member(anotherOwner, anotherTeam)
        assertThrows(TeamNotFoundException::class.java) { suggestions.support(outsider, anotherTeam, id, true) }
    }

    @Test
    fun `withdrawal removes content and cannot be undone by delayed create or support`() {
        val owner = account(); val team = team(owner); val author = member(owner, team); val voter = member(owner, team)
        val id = UUID.randomUUID()
        suggestions.create(author, team, id, "Meetings", "Focus", null)
        suggestions.support(voter, team, id, true)
        assertThrows(ForbiddenResourceAccessException::class.java) { suggestions.withdraw(voter, team, id) }
        repeat(2) { assertTrue(suggestions.withdraw(author, team, id).isEmpty()) }
        assertTrue(suggestions.list(voter, team).isEmpty())
        assertThrows(TeamConflictException::class.java) { suggestions.create(author, team, id, "Meetings", "Focus", null) }
        assertThrows(TeamNotFoundException::class.java) { suggestions.support(voter, team, id, true) }
    }
    @Test
    fun `members report anonymously and only current team leaders can review keep or remove content`() {
        val owner = account(); val team = team(owner); val author = member(owner, team); val reporter = member(owner, team)
        val leader = account()
        val invitation = teams.inviteLeader(owner, team, UUID.randomUUID(), "leader@example.com").invitations.single()
        teams.acceptLeadership(leader, invitation.code, "leader@example.com")
        val foreignOwner = account(); val foreignTeam = team(foreignOwner); val outsider = member(foreignOwner, foreignTeam)
        val id = UUID.randomUUID()
        suggestions.create(author, team, id, "Identifying content", "Impact", "Solution")
        val reportPath = "/teams/$team/suggestions/$id/report"
        mvc.perform(post(reportPath)).andExpect(status().isUnauthorized)
        mvc.perform(post(reportPath).with(jwt().jwt { it.subject(owner) })).andExpect(status().isForbidden)
        mvc.perform(post(reportPath).with(jwt().jwt { it.subject(outsider) })).andExpect(status().isForbidden)
        repeat(2) { mvc.perform(post(reportPath).with(jwt().jwt { it.subject(reporter) })).andExpect(status().isOk) }
        assertEquals(1, suggestions.list(author, team).size) // Reporting queues review, not automatic censorship.
        val reviewPath = "/teams/$team/suggestions/reports"
        mvc.perform(get(reviewPath).with(jwt().jwt { it.subject(reporter) })).andExpect(status().isForbidden)
        mvc.perform(get(reviewPath).with(jwt().jwt { it.subject(foreignOwner) })).andExpect(status().isForbidden)
        val json = mvc.perform(get(reviewPath).with(jwt().jwt { it.subject(leader) }))
            .andExpect(status().isOk).andReturn().response.contentAsString
        assertEquals(setOf("id", "problem", "impact", "solution"), mapper.readTree(json)[0].fieldNames().asSequence().toSet())
        assertFalse(json.contains(author)); assertFalse(json.contains(reporter))
        val moderationPath = "/teams/$team/suggestions/$id/moderation"
        fun moderate(actor: String, remove: Boolean) = mvc.perform(post(moderationPath).with(jwt().jwt { it.subject(actor) })
            .contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(mapOf("remove" to remove))))
        moderate(reporter, true).andExpect(status().isForbidden)
        moderate(foreignOwner, true).andExpect(status().isForbidden)
        moderate(leader, false).andExpect(status().isOk).andExpect(jsonPath("$.length()").value(0))
        assertEquals(1, suggestions.list(author, team).size)
        suggestions.report(reporter, team, id)
        suggestions.support(reporter, team, id, true)
        repeat(2) { moderate(owner, true).andExpect(status().isOk).andExpect(jsonPath("$.length()").value(0)) }
        assertTrue(suggestions.list(author, team).isEmpty())
        assertThrows(TeamConflictException::class.java) { suggestions.create(author, team, id, "Identifying content", "Impact", "Solution") }
        assertThrows(TeamNotFoundException::class.java) { suggestions.report(reporter, team, id) }
        teams.removeLeader(owner, team, leader)
        mvc.perform(get(reviewPath).with(jwt().jwt { it.subject(leader) })).andExpect(status().isForbidden)
        teams.remove(owner, team, reporter)
        mvc.perform(post(reportPath).with(jwt().jwt { it.subject(reporter) })).andExpect(status().isForbidden)
    }

}
