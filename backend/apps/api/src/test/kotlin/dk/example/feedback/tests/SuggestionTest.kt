package dk.example.feedback.tests

import com.fasterxml.jackson.databind.ObjectMapper
import dk.example.feedback.config.SecurityConfig
import dk.example.feedback.model.exceptions.ForbiddenResourceAccessException
import dk.example.feedback.model.exceptions.TeamConflictException
import dk.example.feedback.model.exceptions.TeamNotFoundException
import dk.example.feedback.model.team.*
import javax.sql.DataSource
import dk.example.feedback.persistence.repo.AccountRepo
import dk.example.feedback.persistence.repo.SuggestionRepo
import dk.example.feedback.persistence.repo.ImprovementNotificationRepo
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
    @Autowired private val notifications: ImprovementNotificationRepo,
    @Autowired private val teams: TeamRepo,
    @Autowired private val accounts: AccountRepo,
    @Autowired private val mvc: MockMvc,
    @Autowired private val mapper: ObjectMapper,
    @Autowired private val dataSource: DataSource,
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
        assertEquals(setOf("id", "problem", "impact", "solution", "hasFiveSupporters", "supportedByMe", "mine", "decisions", "trials", "evaluations", "outcomes"), fields)
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
        assertFalse(item.hasFiveSupporters); assertTrue(item.supportedByMe); assertFalse(item.mine)
        item = suggestions.list(author, team).single()
        assertTrue(item.mine); assertFalse(item.supportedByMe)
        repeat(2) { suggestions.support(voter, team, id, false) }
        assertFalse(suggestions.list(author, team).single().hasFiveSupporters)
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

    @Test
    fun `API hides exact totals and publishes authorized versioned retryable decisions`() {
        val owner = account(); val team = team(owner); val author = member(owner, team)
        val id = UUID.randomUUID()
        suggestions.create(author, team, id, "Meetings", "Focus", null)
        val voters = (1..6).map { member(owner, team) }
        voters.forEachIndexed { index, voter ->
            suggestions.support(voter, team, id, true)
            mvc.perform(get("/teams/$team/suggestions").with(jwt().jwt { it.subject(author) }))
                .andExpect(status().isOk).andExpect(jsonPath("$[0].hasFiveSupporters").value(index >= 4))
                .andExpect(jsonPath("$[0].supportCount").doesNotExist())
        }
        suggestions.support(voters[0], team, id, false)
        suggestions.support(voters[1], team, id, false)
        assertFalse(suggestions.list(author, team).single().hasFiveSupporters)
        val inbox = "/teams/$team/suggestions/inbox"
        mvc.perform(get(inbox).with(jwt().jwt { it.subject(author) })).andExpect(status().isForbidden)
        mvc.perform(get(inbox).with(jwt().jwt { it.subject(owner) })).andExpect(status().isOk)
            .andExpect(jsonPath("$.suggestions[0].supportCount").doesNotExist())
        val path = "/teams/$team/suggestions/$id/decisions"
        val first: Map<String, Any> = mapOf("id" to UUID.randomUUID(), "expectedRevision" to 0, "status" to "Planned",
            "explanation" to " We will shorten meetings ", "responsibleId" to owner, "responsibleName" to "Ada", "followUpDate" to "2099-01-01")
        fun publish(actor: String, input: Map<String, Any>) = mvc.perform(post(path).with(jwt().jwt { it.subject(actor) })
            .contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(input)))
        publish(author, first).andExpect(status().isForbidden)
        val stranger = account(); team(stranger)
        publish(stranger, first).andExpect(status().isForbidden)
        publish(owner, first + ("responsibleId" to stranger)).andExpect(status().isForbidden)
        publish(owner, first - "followUpDate").andExpect(status().isBadRequest)
        publish(owner, first + ("explanation" to " ")).andExpect(status().isBadRequest)
        publish(owner, first + ("followUpDate" to "bad-date")).andExpect(status().isBadRequest)
        publish(owner, first + ("followUpDate" to "+10000-01-01")).andExpect(status().isBadRequest)
        publish(owner, first + ("followUpDate" to "0000-01-01")).andExpect(status().isBadRequest)
        repeat(2) { publish(owner, first).andExpect(status().isOk)
            .andExpect(jsonPath("$.suggestions[0].decisions.length()").value(1)) }
        publish(owner, first + ("explanation" to "Changed retry")).andExpect(status().isConflict)
        publish(owner, first + ("id" to UUID.randomUUID())).andExpect(status().isConflict)
        val second = (first - "followUpDate") + mapOf("id" to UUID.randomUUID(), "expectedRevision" to 1,
            "status" to "Declined", "explanation" to "The customer requires this meeting")
        publish(owner, second).andExpect(status().isOk)
        val body = mvc.perform(get("/teams/$team/suggestions").with(jwt().jwt { it.subject(author) }))
            .andExpect(status().isOk).andExpect(jsonPath("$[0].decisions[0].status").value("Declined"))
            .andExpect(jsonPath("$[0].decisions[1].explanation").value("We will shorten meetings"))
            .andExpect(jsonPath("$[0].decisions[0].responsibleId").doesNotExist()).andReturn().response.contentAsString
        assertFalse(body.contains(owner)); assertFalse(body.contains(author))
        suggestions.withdraw(author, team, id)
        publish(owner, second).andExpect(status().isNotFound)
    }

    @Test
    fun `assignment requires current authority and revisions preserve names after departure`() {
        val owner = account(); val team = team(owner); val author = member(owner, team); val leader = account()
        val invite = teams.inviteLeader(owner, team, UUID.randomUUID(), "leader@example.com").invitations.single()
        teams.acceptLeadership(leader, invite.code, "leader@example.com")
        val id = UUID.randomUUID()
        suggestions.create(author, team, id, "Meetings", "Focus", null)
        assertEquals("leader@example.com", suggestions.inbox(owner, team).responsiblePeople.single { it.accountId == leader }.email)
        val decisionId = UUID.randomUUID()
        suggestions.publishDecision(leader, team, id, decisionId, 0,
            SuggestionDecisionStatus.Reviewing, "Looking into it", leader, "Grace", "2099-01-01")
        teams.removeLeader(owner, team, leader)
        assertEquals("Grace", suggestions.list(author, team).single().decisions.single().responsibleName)
        // An unchanged retry remains valid; this does not create a new assignment after departure.
        suggestions.publishDecision(owner, team, id, decisionId, 0,
            SuggestionDecisionStatus.Reviewing, "Looking into it", leader, "Grace", "2099-01-01")
        assertThrows(ForbiddenResourceAccessException::class.java) { suggestions.inbox(leader, team) }
        assertThrows(ForbiddenResourceAccessException::class.java) { suggestions.publishDecision(owner, team, id, UUID.randomUUID(), 1,
            SuggestionDecisionStatus.Planned, "Next step", leader, "Grace", "2099-01-01") }
        suggestions.publishDecision(owner, team, id, UUID.randomUUID(), 1,
            SuggestionDecisionStatus.Deferred, "Review next quarter", owner, "Ada", "2099-02-01")
        assertEquals(listOf("Ada", "Grace"), suggestions.list(author, team).single().decisions.map { it.responsibleName })
    }

    @Test
    fun `concurrent leaders cannot publish two revisions from the same observed version`() {
        val owner = account(); val team = team(owner); val author = member(owner, team); val leader = account()
        val invite = teams.inviteLeader(owner, team, UUID.randomUUID(), "concurrent@example.com").invitations.single()
        teams.acceptLeadership(leader, invite.code, "concurrent@example.com")
        val id = UUID.randomUUID()
        suggestions.create(author, team, id, "Meetings", "Focus", null)
        val start = java.util.concurrent.CountDownLatch(1)
        Executors.newFixedThreadPool(2).use { executor ->
            val futures = listOf(owner, leader).map { actor -> executor.submit(Callable {
                start.await()
                runCatching { suggestions.publishDecision(actor, team, id, UUID.randomUUID(), 0,
                    SuggestionDecisionStatus.Planned, "Shorter meetings", leader, "Grace", "2099-01-01") }
            }) }
            start.countDown()
            val results = futures.map { it.get(10, java.util.concurrent.TimeUnit.SECONDS) }
            assertEquals(1, results.count { it.isSuccess })
            assertTrue(results.single { it.isFailure }.exceptionOrNull() is TeamConflictException)
        }
        assertEquals(1, suggestions.list(author, team).single().decisions.single().revision)
        val otherOwner = account(); val otherTeam = team(otherOwner)
        assertThrows(TeamNotFoundException::class.java) { suggestions.publishDecision(otherOwner, otherTeam, id, UUID.randomUUID(), 0,
            SuggestionDecisionStatus.Declined, "No", otherOwner, "Other", null) }
    }

    @Test
    fun `trials require a planned decision enforce dates and hide assignment identities`() {
        val owner = account(); val team = team(owner); val author = member(owner, team)
        val id = UUID.randomUUID(); val decision = UUID.randomUUID()
        suggestions.create(author, team, id, "Meetings", "Focus", null)
        val input: Map<String, Any> = mapOf("id" to UUID.randomUUID(), "expectedRevision" to 0, "expectedDecisionId" to decision,
            "change" to "Meeting-free mornings", "intendedBenefit" to "Uninterrupted focus", "responsibleId" to owner,
            "responsibleName" to "Ada", "startDate" to "2099-01-01", "endDate" to "2099-02-01", "followUpDate" to "2099-02-02")
        val path = "/teams/$team/suggestions/$id/trials"
        fun publish(actor: String, value: Map<String, Any>) = mvc.perform(post(path).with(jwt().jwt { it.subject(actor) })
            .contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(value)))
        publish(owner, input).andExpect(status().isConflict)
        suggestions.publishDecision(owner, team, id, decision, 0, SuggestionDecisionStatus.Planned, "Try it", owner, "Ada", "2099-01-01")
        publish(author, input).andExpect(status().isForbidden)
        publish(account(), input).andExpect(status().isForbidden)
        publish(owner, input + ("endDate" to "2098-01-01")).andExpect(status().isBadRequest)
        publish(owner, input + ("followUpDate" to "2099-01-15")).andExpect(status().isBadRequest)
        publish(owner, input + ("startDate" to "0000-01-01")).andExpect(status().isBadRequest)
        publish(owner, input + ("change" to " ")).andExpect(status().isBadRequest)
        repeat(2) { publish(owner, input).andExpect(status().isOk).andExpect(jsonPath("$.suggestions[0].trials.length()").value(1)) }
        publish(owner, input + ("change" to "Changed retry")).andExpect(status().isConflict)
        publish(owner, input + ("id" to UUID.randomUUID())).andExpect(status().isConflict)
        val body = mvc.perform(get("/teams/$team/suggestions").with(jwt().jwt { it.subject(author) }))
            .andExpect(status().isOk).andExpect(jsonPath("$[0].trials[0].needsReassignment").value(false))
            .andExpect(jsonPath("$[0].trials[0].responsibleId").doesNotExist())
            .andExpect(jsonPath("$[0].trials[0].responsibleFingerprint").doesNotExist()).andReturn().response.contentAsString
        assertFalse(body.contains(owner))
        assertThrows(TeamConflictException::class.java) { suggestions.publishDecision(owner, team, id, UUID.randomUUID(), 1,
            SuggestionDecisionStatus.Declined, "No", owner, "Ada", null) }
        suggestions.withdraw(author, team, id)
        publish(owner, input).andExpect(status().isNotFound)
    }

    @Test
    fun `trial owner departure flags reassignment and retains immutable revisions and safe retries`() {
        val owner = account(); val team = team(owner); val author = member(owner, team); val leader = account()
        val invite = teams.inviteLeader(owner, team, UUID.randomUUID(), "trial@example.com").invitations.single()
        teams.acceptLeadership(leader, invite.code, "trial@example.com")
        val id = UUID.randomUUID(); val decision = UUID.randomUUID(); val trial = UUID.randomUUID()
        suggestions.create(author, team, id, "Meetings", "Focus", null)
        suggestions.publishDecision(owner, team, id, decision, 0, SuggestionDecisionStatus.Planned, "Try it", owner, "Ada", "2099-01-01")
        fun publish(receipt: UUID, revision: Int, responsible: String) = suggestions.publishTrial(owner, team, id, receipt, revision,
            decision, "Mornings", "Focus", responsible, "Grace", "2099-01-01", "2099-02-01", "2099-02-02")
        publish(trial, 0, leader)
        teams.removeLeader(owner, team, leader)
        assertTrue(suggestions.list(author, team).single().trials.single().needsReassignment)
        publish(trial, 0, leader)
        assertThrows(ForbiddenResourceAccessException::class.java) { publish(UUID.randomUUID(), 1, leader) }
        publish(UUID.randomUUID(), 1, owner)
        val history = suggestions.list(author, team).single().trials
        assertEquals(listOf(2, 1), history.map { it.revision })
        assertFalse(history.first().needsReassignment)
        assertEquals("Grace", history.last().responsibleName)
        val otherOwner = account(); val otherTeam = team(otherOwner)
        assertThrows(TeamNotFoundException::class.java) { suggestions.publishTrial(otherOwner, otherTeam, id, UUID.randomUUID(), 0,
            decision, "Mornings", "Focus", otherOwner, "Other", "2099-01-01", "2099-02-01", "2099-02-02") }
    }

    @Test
    fun `concurrent trial revisions cannot overwrite each other`() {
        val owner = account(); val team = team(owner); val author = member(owner, team); val leader = account()
        val invite = teams.inviteLeader(owner, team, UUID.randomUUID(), "trial-concurrency@example.com").invitations.single()
        teams.acceptLeadership(leader, invite.code, "trial-concurrency@example.com")
        val id = UUID.randomUUID(); val decision = UUID.randomUUID()
        suggestions.create(author, team, id, "Meetings", "Focus", null)
        suggestions.publishDecision(owner, team, id, decision, 0, SuggestionDecisionStatus.Planned, "Try it", owner, "Ada", "2099-01-01")
        val start = java.util.concurrent.CountDownLatch(1)
        Executors.newFixedThreadPool(2).use { executor ->
            val futures = listOf(owner, leader).map { actor -> executor.submit(Callable {
                start.await()
                runCatching { suggestions.publishTrial(actor, team, id, UUID.randomUUID(), 0, decision,
                    "Mornings", "Focus", owner, "Ada", "2099-01-01", "2099-02-01", "2099-02-02") }
            }) }
            start.countDown()
            val results = futures.map { it.get(10, java.util.concurrent.TimeUnit.SECONDS) }
            assertEquals(1, results.count { it.isSuccess })
            assertTrue(results.single { it.isFailure }.exceptionOrNull() is TeamConflictException)
        }
    }

    @Test
    fun `evaluations snapshot eligibility allow edits hide live results and freeze a private summary`() {
        val owner = account(); val team = team(owner); val author = member(owner, team)
        val voters = listOf(author) + (1..5).map { member(owner, team) }
        val id = UUID.randomUUID(); val decision = UUID.randomUUID(); val trial = UUID.randomUUID(); val evaluation = UUID.randomUUID()
        suggestions.create(author, team, id, "Meetings", "Focus", null)
        suggestions.publishDecision(owner, team, id, decision, 0, SuggestionDecisionStatus.Planned, "Try it", owner, "Ada", "2099-01-01")
        suggestions.publishTrial(owner, team, id, trial, 0, decision, "Mornings", "Focus", owner, "Ada", "2099-01-01", "2099-02-01", "2099-02-02")
        val deadline = System.currentTimeMillis() + 60000
        mvc.perform(post("/teams/$team/suggestions/$id/evaluations").with(jwt().jwt { it.subject(owner) })
            .contentType(MediaType.APPLICATION_JSON).content(mapper.writeValueAsString(mapOf(
                "id" to evaluation, "trialId" to trial, "closesAt" to Long.MAX_VALUE))))
            .andExpect(status().isBadRequest)
        repeat(2) { suggestions.openEvaluation(owner, team, id, evaluation, trial, deadline) }
        assertThrows(ForbiddenResourceAccessException::class.java) {
            suggestions.openEvaluation(author, team, id, UUID.randomUUID(), trial, deadline)
        }
        val late = member(owner, team)
        assertFalse(suggestions.list(late, team).single().evaluations.single().eligible)
        assertThrows(ForbiddenResourceAccessException::class.java) {
            suggestions.answerEvaluation(late, team, id, evaluation, EvaluationAnswer.Better)
        }
        voters.forEach { suggestions.answerEvaluation(it, team, id, evaluation, EvaluationAnswer.Better) }
        suggestions.answerEvaluation(author, team, id, evaluation, EvaluationAnswer.Worse)
        assertEquals(EvaluationAnswer.Worse, suggestions.list(author, team).single().evaluations.single().myAnswer)
        assertNull(suggestions.inbox(owner, team).suggestions.single().evaluations.single().summary)
        val json = mapper.writeValueAsString(suggestions.inbox(owner, team).suggestions.single().evaluations.single())
        assertFalse(json.contains(author)); assertFalse(json.contains("count", ignoreCase = true))
        teams.remove(owner, team, voters.last())
        assertThrows(ForbiddenResourceAccessException::class.java) {
            suggestions.answerEvaluation(voters.last(), team, id, evaluation, EvaluationAnswer.Worse)
        }
        dataSource.connection.use { connection -> connection.prepareStatement("UPDATE suggestion_evaluation SET closes_at = 1 WHERE id = ?").use { it.setObject(1, evaluation); it.executeUpdate() } }
        assertNull(suggestions.list(author, team).single().evaluations.single().summary)
        assertThrows(TeamConflictException::class.java) {
            suggestions.answerEvaluation(author, team, id, evaluation, EvaluationAnswer.Unchanged)
        }
        val outcome = UUID.randomUUID()
        repeat(2) { suggestions.publishOutcome(owner, team, id, outcome, trial, TrialOutcome.Adjust, "Try a shorter period") }
        notifications.dispatch { _, _, _ -> true }
        // A subsequent trial is a meaningful start even when its plan fields repeat.
        suggestions.publishTrial(owner, team, id, UUID.randomUUID(), 1, decision, "Mornings", "Focus", owner, "Ada",
            "2099-01-01", "2099-02-01", "2099-02-02")
        dataSource.connection.use { connection -> connection.prepareStatement("SELECT COUNT(*) FROM improvement_notification WHERE suggestion_id = ?").use {
            it.setObject(1, id)
            it.executeQuery().use { result -> assertTrue(result.next()); assertEquals(1, result.getInt(1)) }
        } }
        val result = suggestions.list(author, team).single()
        assertEquals(2, result.trials.size)
        assertEquals(trial, result.outcomes.single().trialId)
        assertEquals(EvaluationSummary.Improved, result.evaluations.single().summary)
        suggestions.withdraw(author, team, id)
        assertTrue(suggestions.list(author, team).isEmpty())
    }

    @Test
    fun `outcomes require closed evaluation but can publish with suppressed results and prevent further plans`() {
        val owner = account(); val team = team(owner); val author = member(owner, team)
        val id = UUID.randomUUID(); val decision = UUID.randomUUID(); val trial = UUID.randomUUID(); val evaluation = UUID.randomUUID()
        suggestions.create(author, team, id, "Meetings", "Focus", null)
        suggestions.publishDecision(owner, team, id, decision, 0, SuggestionDecisionStatus.Planned, "Try", owner, "Ada", "2099-01-01")
        suggestions.publishTrial(owner, team, id, trial, 0, decision, "Mornings", "Focus", owner, "Ada", "2099-01-01", "2099-02-01", "2099-02-02")
        val outcome = UUID.randomUUID()
        assertThrows(TeamConflictException::class.java) {
            suggestions.publishOutcome(owner, team, id, outcome, trial, TrialOutcome.Stop, "Not useful")
        }
        suggestions.openEvaluation(owner, team, id, evaluation, trial, System.currentTimeMillis() + 60000)
        assertThrows(TeamConflictException::class.java) {
            suggestions.publishOutcome(owner, team, id, outcome, trial, TrialOutcome.Stop, "Not useful")
        }
        suggestions.answerEvaluation(author, team, id, evaluation, EvaluationAnswer.CannotAssess)
        dataSource.connection.use { connection -> connection.prepareStatement("UPDATE suggestion_evaluation SET closes_at = 1 WHERE id = ?").use { it.setObject(1, evaluation); it.executeUpdate() } }
        val result = suggestions.publishOutcome(owner, team, id, outcome, trial, TrialOutcome.Stop, "Not useful").suggestions.single()
        assertEquals(EvaluationSummary.InsufficientResponses, result.evaluations.single().summary)
        assertEquals(TrialOutcome.Stop, result.outcomes.single().outcome)
        assertThrows(TeamConflictException::class.java) {
            suggestions.publishTrial(owner, team, id, UUID.randomUUID(), 1, decision, "Again", "Focus", owner, "Ada", "2099-01-01", "2099-02-01", "2099-02-02")
        }
    }
    @Test
    fun `retention purges closed content after twenty four months and reserves retry identifiers`() {
        val owner = account(); val team = team(owner); val author = member(owner, team)
        val id = UUID.randomUUID()
        suggestions.create(author, team, id, "Meetings", "Focus", null)
        suggestions.publishDecision(owner, team, id, UUID.randomUUID(), 0, SuggestionDecisionStatus.Declined, "No", owner, "Ada", null)
        val now = java.time.Instant.now()
        assertEquals(0, suggestions.purgeClosedSuggestions(now))
        // Reopening cancels retention, even when a previous deadline would have elapsed.
        suggestions.publishDecision(owner, team, id, UUID.randomUUID(), 1, SuggestionDecisionStatus.Reviewing, "Reconsider", owner, "Ada", "2099-01-01")
        suggestions.purgeClosedSuggestions(now.atZone(java.time.ZoneOffset.UTC).plusMonths(25).toInstant())
        assertEquals(id, suggestions.list(author, team).single().id)
        suggestions.withdraw(author, team, id)
        assertEquals(1, suggestions.purgeClosedSuggestions(now.atZone(java.time.ZoneOffset.UTC).plusMonths(25).toInstant()))
        assertThrows(TeamConflictException::class.java) { suggestions.create(author, team, id, "Meetings", "Focus", null) }
        assertTrue(suggestions.list(author, team).isEmpty())
        dataSource.connection.use { connection ->
            connection.prepareStatement("SELECT * FROM suggestion_receipt WHERE id = ?").use {
                it.setObject(1, id)
                it.executeQuery().use { result -> assertTrue(result.next()); assertEquals(1, result.metaData.columnCount) }
            }
        }
    }
    @Test
    fun `meaningful updates queue once and resolve current membership and opt in at delivery`() {
        val owner = account(); val team = team(owner); val author = member(owner, team); val departing = member(owner, team)
        val id = UUID.randomUUID(); val decision = UUID.randomUUID()
        suggestions.create(author, team, id, "Meetings", "Focus", null)
        dataSource.connection.use { connection ->
            connection.prepareStatement("INSERT INTO fcm_token (token, account_id) VALUES (?, ?)").use {
                it.setString(1, "token-$author"); it.setString(2, author); it.executeUpdate()
                it.setString(1, "token-$departing"); it.setString(2, departing); it.executeUpdate()
            }
        }
        repeat(2) { suggestions.publishDecision(owner, team, id, decision, 0, SuggestionDecisionStatus.Planned, "Try", owner, "Ada", "2099-01-01") }
        teams.remove(owner, team, departing)
        dataSource.connection.use { connection -> connection.prepareStatement("INSERT INTO fcm_token (token, account_id) VALUES (?, ?)").use {
            it.setString(1, "invalid-$author"); it.setString(2, author); it.executeUpdate()
        } }
        val deliveries = mutableListOf<String>()
        assertThrows(IllegalStateException::class.java) {
            notifications.dispatch { token, target, _ -> if (target == team && token == "token-$author") error("Transient failure"); true }
        }
        notifications.dispatch { token, target, _ -> if (target == team && !token.startsWith("invalid-")) deliveries.add(token); !token.startsWith("invalid-") }
        assertEquals(listOf("token-$author"), deliveries)
        dataSource.connection.use { connection -> connection.prepareStatement("SELECT COUNT(*) FROM fcm_token WHERE token = ?").use {
            it.setString(1, "invalid-$author")
            it.executeQuery().use { result -> assertTrue(result.next()); assertEquals(0, result.getInt(1)) }
        } }
        notifications.dispatch { _, target, _ -> assertNotEquals(team, target); true }
        suggestions.support(author, team, id, true)
        notifications.dispatch { _, target, _ -> assertNotEquals(team, target); true }
        val trial = UUID.randomUUID()
        suggestions.publishTrial(owner, team, id, trial, 0, decision, "Mornings", "Focus", owner, "Ada", "2099-01-01", "2099-02-01", "2099-02-02")
        notifications.dispatch { _, _, _ -> true }
        suggestions.publishTrial(owner, team, id, UUID.randomUUID(), 1, decision, "Mornings", "Focus", owner, "Ada", "2099-01-01", "2099-02-01", "2099-02-02")
        notifications.dispatch { _, target, _ -> assertNotEquals(team, target); true }
    }
    @Test
    fun `evaluation release suppresses small samples and never exposes category counts`() {
        val scenarios = listOf(
            List(4) { EvaluationAnswer.Better } to EvaluationSummary.InsufficientResponses,
            List(5) { EvaluationAnswer.Better } to EvaluationSummary.Improved,
            List(5) { EvaluationAnswer.CannotAssess } to EvaluationSummary.Mixed,
            List(5) { EvaluationAnswer.Worse } to EvaluationSummary.NotImproved,
            listOf(EvaluationAnswer.Better, EvaluationAnswer.Better, EvaluationAnswer.Worse, EvaluationAnswer.Unchanged, EvaluationAnswer.CannotAssess) to EvaluationSummary.Mixed,
        )
        scenarios.forEach { (answers, expected) ->
            val owner = account(); val team = team(owner); val voters = answers.map { member(owner, team) }
            val id = UUID.randomUUID(); val decision = UUID.randomUUID(); val trial = UUID.randomUUID(); val evaluation = UUID.randomUUID()
            suggestions.create(voters.first(), team, id, "Meetings", "Focus", null)
            suggestions.publishDecision(owner, team, id, decision, 0, SuggestionDecisionStatus.Planned, "Try", owner, "Ada", "2099-01-01")
            suggestions.publishTrial(owner, team, id, trial, 0, decision, "Mornings", "Focus", owner, "Ada", "2099-01-01", "2099-02-01", "2099-02-02")
            suggestions.openEvaluation(owner, team, id, evaluation, trial, System.currentTimeMillis() + 60000)
            voters.zip(answers).forEach { (actor, answer) -> suggestions.answerEvaluation(actor, team, id, evaluation, answer) }
            dataSource.connection.use { connection -> connection.prepareStatement("UPDATE suggestion_evaluation SET closes_at = 1 WHERE id = ?").use { it.setObject(1, evaluation); it.executeUpdate() } }
            suggestions.publishOutcome(owner, team, id, UUID.randomUUID(), trial, TrialOutcome.Continue, "Keep it")
            val body = mvc.perform(get("/teams/$team/suggestions/inbox").with(jwt().jwt { it.subject(owner) }))
                .andExpect(status().isOk).andReturn().response.contentAsString
            val result = mapper.readTree(body)["suggestions"][0]["evaluations"][0]
            assertEquals(expected.name, result["summary"].asText())
            assertEquals(setOf("id", "trialId", "closesAt", "closed", "eligible", "myAnswer", "summary"), result.fieldNames().asSequence().toSet())
            assertTrue(result["myAnswer"].isNull)
            voters.forEach { assertFalse(body.contains(it)) }
        }
    }
}
