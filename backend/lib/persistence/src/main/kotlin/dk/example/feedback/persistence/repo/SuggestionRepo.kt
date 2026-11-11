package dk.example.feedback.persistence.repo

import dk.example.feedback.model.exceptions.ForbiddenResourceAccessException
import dk.example.feedback.model.exceptions.TeamConflictException
import dk.example.feedback.model.exceptions.TeamNotFoundException
import dk.example.feedback.model.team.*
import dk.example.feedback.persistence.table.*
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.util.UUID
import java.util.HexFormat
import java.security.MessageDigest

@Component
@Transactional
class SuggestionRepo(private val teams: TeamRepo) {
    // Same lock as membership removal: authorization and mutations have one ordering.
    private fun member(accountId: String, teamId: UUID) {
        AccountTable.selectAll().where { AccountTable.id eq accountId }.forUpdate().singleOrNull()
            ?: throw ForbiddenResourceAccessException("Current team membership or authorship required")
        teams.requireMember(accountId, teamId)
    }

    fun list(accountId: String, teamId: UUID): List<Suggestion> {
        member(accountId, teamId)
        return feed(accountId, teamId)
    }

    private fun feed(accountId: String, teamId: UUID): List<Suggestion> {
        val rows = SuggestionTable.selectAll().where { (SuggestionTable.team eq teamId) and (SuggestionTable.withdrawn eq false) }
            .orderBy(SuggestionTable.id).toList()
        if (rows.isEmpty()) return emptyList()
        val support = SuggestionSupportTable.selectAll().where { SuggestionSupportTable.suggestion inList rows.map { it[SuggestionTable.id] } }
            .groupBy { it[SuggestionSupportTable.suggestion] }
        val decisions = SuggestionDecisionTable.selectAll().where {
            SuggestionDecisionTable.suggestion inList rows.map { it[SuggestionTable.id] }
        }.orderBy(SuggestionDecisionTable.revision, SortOrder.DESC).groupBy { it[SuggestionDecisionTable.suggestion] }
        val trials = SuggestionTrialTable.selectAll().where {
            SuggestionTrialTable.suggestion inList rows.map { it[SuggestionTable.id] }
        }.orderBy(SuggestionTrialTable.revision, SortOrder.DESC).groupBy { it[SuggestionTrialTable.suggestion] }
        val team = TeamTable.selectAll().where { TeamTable.id eq teamId }.single()
        val owner = OrganizationTable.selectAll().where { OrganizationTable.id eq team[TeamTable.organization] }.single()[OrganizationTable.creator].value
        val eligible = TeamLeaderTable.selectAll().where { TeamLeaderTable.team eq teamId }
            .map { digest(it[TeamLeaderTable.account].value) }.toSet() + digest(owner)
        return rows.map { row ->
            val votes = support[row[SuggestionTable.id]].orEmpty()
            Suggestion(row[SuggestionTable.id], row[SuggestionTable.problem], row[SuggestionTable.impact], row[SuggestionTable.solution],
                votes.size >= 5, votes.any { it[SuggestionSupportTable.account].value == accountId }, row[SuggestionTable.author]?.value == accountId,
                decisions[row[SuggestionTable.id]].orEmpty().map(::decision),
                trials[row[SuggestionTable.id]].orEmpty().map { trial(it, eligible) },
                evaluations(accountId, row[SuggestionTable.id]), outcomes(row[SuggestionTable.id]))
        }
    }

    fun inbox(accountId: String, teamId: UUID): SuggestionInbox {
        val team = teams.requireLeader(accountId, teamId)
        val owner = OrganizationTable.selectAll().where { OrganizationTable.id eq team.organizationId }.single()[OrganizationTable.creator].value
        val leaders = TeamLeaderTable.selectAll().where { TeamLeaderTable.team eq teamId }
            .associate { it[TeamLeaderTable.account].value to it[TeamLeaderTable.email] }
        val ids = listOf(owner) + leaders.keys
        val people = AccountTable.selectAll().where { AccountTable.id inList ids }.map {
            SuggestionResponsiblePerson(it[AccountTable.id].value, it[AccountTable.name], leaders[it[AccountTable.id].value] ?: it[AccountTable.email])
        }
        return SuggestionInbox(feed(accountId, teamId), people)
    }

    fun publishDecision(accountId: String, teamId: UUID, suggestionId: UUID, id: UUID, expectedRevision: Int,
        status: SuggestionDecisionStatus, explanation: String, responsibleId: String, responsibleName: String,
        followUpDate: String?): SuggestionInbox {
        val team = teams.requireLeader(accountId, teamId)
        active(teamId, suggestionId)
        val command = listOf(expectedRevision.toString(), status.name, explanation, responsibleId, responsibleName, followUpDate)
            .joinToString("") { value -> value?.let { "${it.length}:$it" } ?: "-1:" }
        val fingerprint = digest(command)
        val existing = SuggestionDecisionTable.selectAll().where { SuggestionDecisionTable.id eq id }.singleOrNull()
        if (existing != null) {
            if (existing[SuggestionDecisionTable.suggestion] != suggestionId ||
                existing[SuggestionDecisionTable.requestFingerprint] != fingerprint) throw TeamConflictException()
            return inbox(accountId, teamId)
        }
        if (SuggestionTrialTable.selectAll().where { SuggestionTrialTable.suggestion eq suggestionId }.any()) throw TeamConflictException()
        val revision = SuggestionDecisionTable.selectAll().where { SuggestionDecisionTable.suggestion eq suggestionId }.count().toInt()
        if (expectedRevision != revision) throw TeamConflictException()
        val owner = OrganizationTable.selectAll().where { OrganizationTable.id eq team.organizationId }.single()[OrganizationTable.creator].value
        // Lock the assignment row, not another account: removal cannot race publication,
        // and we preserve TeamRepo's account-before-assignment lock ordering.
        if (responsibleId != owner && TeamLeaderTable.selectAll().where {
                (TeamLeaderTable.team eq teamId) and (TeamLeaderTable.account eq responsibleId)
            }.forUpdate().singleOrNull() == null) throw ForbiddenResourceAccessException("Responsible person must currently lead this team")
        SuggestionTable.update({ SuggestionTable.id eq suggestionId }) {
            it[closedAt] = if (status == SuggestionDecisionStatus.Declined && followUpDate == null) System.currentTimeMillis() else null
        }
        SuggestionDecisionTable.insert {
            it[this.id] = id; it[suggestion] = suggestionId; it[this.revision] = revision + 1
            it[this.status] = status.name; it[this.explanation] = explanation; it[requestFingerprint] = fingerprint
            it[this.responsibleName] = responsibleName; it[this.followUpDate] = followUpDate; it[publishedAt] = System.currentTimeMillis()
        }
        ImprovementNotificationTable.insert { it[this.id] = UUID.randomUUID(); it[suggestion] = suggestionId }
        return inbox(accountId, teamId)
    }

    fun publishTrial(accountId: String, teamId: UUID, suggestionId: UUID, id: UUID, expectedRevision: Int,
        expectedDecisionId: UUID, change: String, intendedBenefit: String, responsibleId: String, responsibleName: String,
        startDate: String, endDate: String, followUpDate: String): SuggestionInbox {
        val team = teams.requireLeader(accountId, teamId)
        active(teamId, suggestionId)
        val command = listOf(expectedRevision.toString(), expectedDecisionId.toString(), change, intendedBenefit,
            responsibleId, responsibleName, startDate, endDate, followUpDate).joinToString("") { "${it.length}:$it" }
        val fingerprint = digest(command)
        val existing = SuggestionTrialTable.selectAll().where { SuggestionTrialTable.id eq id }.singleOrNull()
        if (existing != null) {
            if (existing[SuggestionTrialTable.suggestion] != suggestionId || existing[SuggestionTrialTable.requestFingerprint] != fingerprint)
                throw TeamConflictException()
            return inbox(accountId, teamId)
        }
        val revision = SuggestionTrialTable.selectAll().where { SuggestionTrialTable.suggestion eq suggestionId }.count().toInt()
        val decision = SuggestionDecisionTable.selectAll().where { SuggestionDecisionTable.suggestion eq suggestionId }
            .orderBy(SuggestionDecisionTable.revision, SortOrder.DESC).firstOrNull() ?: throw TeamConflictException()
        if (revision != expectedRevision || decision[SuggestionDecisionTable.id] != expectedDecisionId ||
            decision[SuggestionDecisionTable.status] != SuggestionDecisionStatus.Planned.name) throw TeamConflictException()
        val previousPlan = if (revision > 0) latestTrial(suggestionId) else null
        var startsSubsequentTrial = false
        if (previousPlan != null) {
            val previous = previousPlan[SuggestionTrialTable.id]
            val outcome = SuggestionOutcomeTable.selectAll().where { SuggestionOutcomeTable.trial eq previous }.singleOrNull()
            if (outcome != null && outcome[SuggestionOutcomeTable.outcome] != TrialOutcome.Adjust.name) throw TeamConflictException()
            startsSubsequentTrial = outcome != null
            if (outcome == null && SuggestionEvaluationTable.selectAll().where { SuggestionEvaluationTable.trial eq previous }.any())
                throw TeamConflictException()
        }
        val owner = OrganizationTable.selectAll().where { OrganizationTable.id eq team.organizationId }.single()[OrganizationTable.creator].value
        if (responsibleId != owner && TeamLeaderTable.selectAll().where {
                (TeamLeaderTable.team eq teamId) and (TeamLeaderTable.account eq responsibleId)
            }.forUpdate().singleOrNull() == null) throw ForbiddenResourceAccessException("Responsible person must currently lead this team")
        SuggestionTrialTable.insert {
            it[this.id] = id; it[suggestion] = suggestionId; it[this.revision] = revision + 1; it[this.decision] = expectedDecisionId
            it[this.change] = change; it[this.intendedBenefit] = intendedBenefit; it[responsibleFingerprint] = digest(responsibleId)
            it[this.responsibleName] = responsibleName; it[requestFingerprint] = fingerprint
            it[this.startDate] = startDate; it[this.endDate] = endDate; it[this.followUpDate] = followUpDate
            it[publishedAt] = System.currentTimeMillis()
        }
        val materialChange = previousPlan == null || startsSubsequentTrial || listOf(change, intendedBenefit, digest(responsibleId), responsibleName,
            startDate, endDate, followUpDate) != listOf(previousPlan[SuggestionTrialTable.change], previousPlan[SuggestionTrialTable.intendedBenefit],
            previousPlan[SuggestionTrialTable.responsibleFingerprint], previousPlan[SuggestionTrialTable.responsibleName],
            previousPlan[SuggestionTrialTable.startDate], previousPlan[SuggestionTrialTable.endDate], previousPlan[SuggestionTrialTable.followUpDate])
        if (materialChange) ImprovementNotificationTable.insert { it[this.id] = UUID.randomUUID(); it[suggestion] = suggestionId }
        return inbox(accountId, teamId)
    }

    fun openEvaluation(accountId: String, teamId: UUID, suggestionId: UUID, id: UUID,
        trialId: UUID, closesAt: Long): SuggestionInbox {
        teams.requireLeader(accountId, teamId)
        active(teamId, suggestionId)
        val existing = SuggestionEvaluationTable.selectAll().where { SuggestionEvaluationTable.id eq id }.singleOrNull()
        if (existing != null) {
            if (existing[SuggestionEvaluationTable.suggestion] != suggestionId || existing[SuggestionEvaluationTable.trial] != trialId ||
                existing[SuggestionEvaluationTable.closesAt] != closesAt) throw TeamConflictException()
            return inbox(accountId, teamId)
        }
        val latest = latestTrial(suggestionId)
        if (latest[SuggestionTrialTable.id] != trialId ||
            SuggestionOutcomeTable.selectAll().where { SuggestionOutcomeTable.trial eq trialId }.any() ||
            SuggestionEvaluationTable.selectAll().where { SuggestionEvaluationTable.trial eq trialId }.any()) throw TeamConflictException()
        if (closesAt <= System.currentTimeMillis() || closesAt > 253402300799999L) throw TeamConflictException()
        SuggestionEvaluationTable.insert {
            it[this.id] = id; it[suggestion] = suggestionId; it[trial] = trialId; it[this.closesAt] = closesAt
        }
        // A statement-level snapshot: later joiners are excluded, current membership is checked again on answering.
        TeamMembershipTable.selectAll().where { TeamMembershipTable.team eq teamId }.forEach { row ->
            SuggestionEvaluationResponseTable.insert {
                it[evaluation] = id; it[accountFingerprint] = digest(row[TeamMembershipTable.account].value)
            }
        }
        ImprovementNotificationTable.insert { it[this.id] = UUID.randomUUID(); it[suggestion] = suggestionId }
        return inbox(accountId, teamId)
    }

    fun answerEvaluation(accountId: String, teamId: UUID, suggestionId: UUID, evaluationId: UUID,
        answer: EvaluationAnswer): List<Suggestion> {
        member(accountId, teamId)
        active(teamId, suggestionId)
        val evaluation = SuggestionEvaluationTable.selectAll().where {
            (SuggestionEvaluationTable.id eq evaluationId) and (SuggestionEvaluationTable.suggestion eq suggestionId)
        }.forUpdate().singleOrNull() ?: throw TeamNotFoundException()
        if (evaluation[SuggestionEvaluationTable.closesAt] <= System.currentTimeMillis() ||
            evaluation[SuggestionEvaluationTable.summary] != null) throw TeamConflictException()
        val updated = SuggestionEvaluationResponseTable.update({
            (SuggestionEvaluationResponseTable.evaluation eq evaluationId) and
                (SuggestionEvaluationResponseTable.accountFingerprint eq digest(accountId))
        }) { it[this.answer] = answer.name }
        if (updated != 1) throw ForbiddenResourceAccessException("Not eligible for this evaluation")
        return feed(accountId, teamId)
    }

    fun publishOutcome(accountId: String, teamId: UUID, suggestionId: UUID, id: UUID, trialId: UUID,
        outcome: TrialOutcome, explanation: String): SuggestionInbox {
        teams.requireLeader(accountId, teamId)
        active(teamId, suggestionId)
        val existing = SuggestionOutcomeTable.selectAll().where { SuggestionOutcomeTable.id eq id }.singleOrNull()
        if (existing != null) {
            if (existing[SuggestionOutcomeTable.suggestion] != suggestionId || existing[SuggestionOutcomeTable.trial] != trialId ||
                existing[SuggestionOutcomeTable.outcome] != outcome.name || existing[SuggestionOutcomeTable.explanation] != explanation)
                throw TeamConflictException()
            return inbox(accountId, teamId)
        }
        if (latestTrial(suggestionId)[SuggestionTrialTable.id] != trialId ||
            SuggestionOutcomeTable.selectAll().where { SuggestionOutcomeTable.trial eq trialId }.any()) throw TeamConflictException()
        val evaluation = SuggestionEvaluationTable.selectAll().where { SuggestionEvaluationTable.trial eq trialId }.singleOrNull()
            ?: throw TeamConflictException()
        if (evaluation[SuggestionEvaluationTable.closesAt] > System.currentTimeMillis()) throw TeamConflictException()
        freezeEvaluation(evaluation[SuggestionEvaluationTable.id])
        SuggestionTable.update({ SuggestionTable.id eq suggestionId }) {
            it[closedAt] = if (outcome == TrialOutcome.Adjust) null else System.currentTimeMillis()
        }
        SuggestionOutcomeTable.insert {
            it[this.id] = id; it[suggestion] = suggestionId; it[trial] = trialId; it[this.outcome] = outcome.name
            it[this.explanation] = explanation; it[publishedAt] = System.currentTimeMillis()
        }
        ImprovementNotificationTable.insert { it[this.id] = UUID.randomUUID(); it[suggestion] = suggestionId }
        return inbox(accountId, teamId)
    }

    private fun latestTrial(suggestionId: UUID) = SuggestionTrialTable.selectAll().where {
        SuggestionTrialTable.suggestion eq suggestionId
    }.orderBy(SuggestionTrialTable.revision, SortOrder.DESC).firstOrNull() ?: throw TeamConflictException()

    private fun outcomes(suggestionId: UUID) = SuggestionOutcomeTable.selectAll().where {
        SuggestionOutcomeTable.suggestion eq suggestionId
    }.orderBy(SuggestionOutcomeTable.publishedAt, SortOrder.DESC).map {
        SuggestionOutcome(it[SuggestionOutcomeTable.id], it[SuggestionOutcomeTable.trial],
            TrialOutcome.valueOf(it[SuggestionOutcomeTable.outcome]), it[SuggestionOutcomeTable.explanation], it[SuggestionOutcomeTable.publishedAt])
    }

    private fun freezeEvaluation(id: UUID) {
        val row = SuggestionEvaluationTable.selectAll().where { SuggestionEvaluationTable.id eq id }.forUpdate().single()
        if (row[SuggestionEvaluationTable.summary] != null) return
        val answers = SuggestionEvaluationResponseTable.selectAll().where {
            SuggestionEvaluationResponseTable.evaluation eq id
        }.mapNotNull { it[SuggestionEvaluationResponseTable.answer] }
        val summary = when {
            answers.size < 5 -> EvaluationSummary.InsufficientResponses
            answers.count { it == EvaluationAnswer.Better.name } > answers.size / 2 -> EvaluationSummary.Improved
            answers.count { it == EvaluationAnswer.Worse.name } > answers.size / 2 -> EvaluationSummary.NotImproved
            else -> EvaluationSummary.Mixed
        }
        SuggestionEvaluationTable.update({ SuggestionEvaluationTable.id eq id }) { it[this.summary] = summary.name }
    }

    private fun evaluations(accountId: String, suggestionId: UUID): List<SuggestionEvaluation> =
        SuggestionEvaluationTable.selectAll().where { SuggestionEvaluationTable.suggestion eq suggestionId }
            .orderBy(SuggestionEvaluationTable.closesAt, SortOrder.DESC).map { row ->
                val id = row[SuggestionEvaluationTable.id]
                val own = SuggestionEvaluationResponseTable.selectAll().where {
                    (SuggestionEvaluationResponseTable.evaluation eq id) and
                        (SuggestionEvaluationResponseTable.accountFingerprint eq digest(accountId))
                }.singleOrNull()
                SuggestionEvaluation(id, row[SuggestionEvaluationTable.trial], row[SuggestionEvaluationTable.closesAt],
                    row[SuggestionEvaluationTable.closesAt] <= System.currentTimeMillis(), own != null,
                    own?.get(SuggestionEvaluationResponseTable.answer)?.let(EvaluationAnswer::valueOf),
                    row[SuggestionEvaluationTable.summary]?.let(EvaluationSummary::valueOf))
            }

    private fun digest(value: String): String =
        HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(value.toByteArray(Charsets.UTF_8)))

    private fun trial(row: ResultRow, eligible: Set<String>) = SuggestionTrial(row[SuggestionTrialTable.id], row[SuggestionTrialTable.revision],
        row[SuggestionTrialTable.decision], row[SuggestionTrialTable.change], row[SuggestionTrialTable.intendedBenefit],
        row[SuggestionTrialTable.responsibleName], row[SuggestionTrialTable.responsibleFingerprint] !in eligible,
        row[SuggestionTrialTable.startDate], row[SuggestionTrialTable.endDate], row[SuggestionTrialTable.followUpDate], row[SuggestionTrialTable.publishedAt])

    private fun decision(row: ResultRow) = SuggestionDecision(row[SuggestionDecisionTable.id], row[SuggestionDecisionTable.revision],
        SuggestionDecisionStatus.valueOf(row[SuggestionDecisionTable.status]), row[SuggestionDecisionTable.explanation],
        row[SuggestionDecisionTable.responsibleName], row[SuggestionDecisionTable.followUpDate], row[SuggestionDecisionTable.publishedAt])

    fun create(accountId: String, teamId: UUID, id: UUID, problem: String, impact: String, solution: String?): List<Suggestion> {
        member(accountId, teamId)
        val reserved = SuggestionReceiptTable.insertIgnore { it[this.id] = id }.insertedCount == 1
        SuggestionReceiptTable.selectAll().where { SuggestionReceiptTable.id eq id }.forUpdate().single()
        val existing = SuggestionTable.selectAll().where { SuggestionTable.id eq id }.singleOrNull()
        if (!reserved && existing == null) throw TeamConflictException()
        if (existing != null) {
            if (existing[SuggestionTable.team] != teamId || existing[SuggestionTable.author]?.value != accountId) throw ForbiddenResourceAccessException("Current team membership or authorship required")
            if (existing[SuggestionTable.withdrawn] || existing[SuggestionTable.problem] != problem ||
                existing[SuggestionTable.impact] != impact || existing[SuggestionTable.solution] != solution) throw TeamConflictException()
        } else {
            SuggestionTable.insert {
                it[this.id] = id; it[team] = teamId; it[author] = accountId
                it[this.problem] = problem; it[this.impact] = impact; it[this.solution] = solution
            }
        }
        return list(accountId, teamId)
    }

    fun support(accountId: String, teamId: UUID, id: UUID, supported: Boolean): List<Suggestion> {
        member(accountId, teamId)
        active(teamId, id)
        if (supported) {
            SuggestionSupportTable.insertIgnore { it[suggestion] = id; it[account] = accountId }
        } else {
            SuggestionSupportTable.deleteWhere { (suggestion eq id) and (account eq accountId) }
        }
        return list(accountId, teamId)
    }

    fun withdraw(accountId: String, teamId: UUID, id: UUID): List<Suggestion> {
        member(accountId, teamId)
        val row = SuggestionTable.selectAll().where { (SuggestionTable.id eq id) and (SuggestionTable.team eq teamId) }
            .forUpdate().singleOrNull() ?: throw TeamNotFoundException()
        if (row[SuggestionTable.author]?.value != accountId) throw ForbiddenResourceAccessException("Current team membership or authorship required")
        // Keep a content-free receipt so a delayed create retry cannot republish withdrawn text.
        removeContent(id)
        return list(accountId, teamId)
    }

    fun report(accountId: String, teamId: UUID, id: UUID): List<Suggestion> {
        member(accountId, teamId)
        active(teamId, id)
        // One content flag is sufficient: no reporter identities, reasons or timestamps are retained.
        SuggestionTable.update({ SuggestionTable.id eq id }) { it[reported] = true }
        return list(accountId, teamId)
    }

    fun reports(accountId: String, teamId: UUID): List<ReportedSuggestion> {
        teams.requireLeader(accountId, teamId)
        return SuggestionTable.selectAll().where {
            (SuggestionTable.team eq teamId) and (SuggestionTable.reported eq true) and (SuggestionTable.withdrawn eq false)
        }.orderBy(SuggestionTable.id).map {
            ReportedSuggestion(it[SuggestionTable.id], it[SuggestionTable.problem], it[SuggestionTable.impact], it[SuggestionTable.solution])
        }
    }

    fun moderate(accountId: String, teamId: UUID, id: UUID, remove: Boolean): List<ReportedSuggestion> {
        teams.requireLeader(accountId, teamId)
        SuggestionTable.selectAll().where { (SuggestionTable.id eq id) and (SuggestionTable.team eq teamId) }
            .forUpdate().singleOrNull() ?: throw TeamNotFoundException()
        if (remove) removeContent(id)
        else SuggestionTable.update({ SuggestionTable.id eq id }) { it[reported] = false }
        return reports(accountId, teamId)
    }

    private fun removeContent(id: UUID) {
        SuggestionTable.update({ (SuggestionTable.id eq id) and (SuggestionTable.withdrawn eq false) }) {
            it[closedAt] = System.currentTimeMillis()
            it[withdrawn] = true; it[reported] = false; it[problem] = "withdrawn"; it[impact] = "withdrawn"; it[solution] = null
        }
        SuggestionSupportTable.deleteWhere { suggestion eq id }
        ImprovementNotificationTable.deleteWhere { suggestion eq id }
        SuggestionOutcomeTable.deleteWhere { suggestion eq id }
        SuggestionEvaluationTable.deleteWhere { suggestion eq id }
        SuggestionTrialTable.deleteWhere { suggestion eq id }
        SuggestionDecisionTable.deleteWhere { suggestion eq id }
    }

    // Called only by the explicitly enabled retention job, after operational backup/restore verification.
    fun purgeClosedSuggestions(now: java.time.Instant = java.time.Instant.now()): Int {
        val cutoff = now.atZone(java.time.ZoneOffset.UTC).minusMonths(24).toInstant().toEpochMilli()
        val ids = SuggestionTable.selectAll().where { SuggestionTable.closedAt lessEq cutoff }
            .orderBy(SuggestionTable.id).map { it[SuggestionTable.id] }
        var removed = 0
        ids.forEach { id ->
            // Creation retries take the same receipt-before-suggestion lock order.
            SuggestionReceiptTable.selectAll().where { SuggestionReceiptTable.id eq id }.forUpdate().single()
            val row = SuggestionTable.selectAll().where { SuggestionTable.id eq id }.forUpdate().singleOrNull()
            if (row?.get(SuggestionTable.closedAt)?.let { it <= cutoff } == true) {
                removeContent(id)
                removed += SuggestionTable.deleteWhere { SuggestionTable.id eq id }
            }
        }
        return removed
    }

    private fun active(teamId: UUID, id: UUID) {
        SuggestionTable.selectAll().where { (SuggestionTable.id eq id) and (SuggestionTable.team eq teamId) and (SuggestionTable.withdrawn eq false) }
            .forUpdate().singleOrNull() ?: throw TeamNotFoundException()
    }
}
