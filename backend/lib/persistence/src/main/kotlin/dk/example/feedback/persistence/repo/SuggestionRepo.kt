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
        return rows.map { row ->
            val votes = support[row[SuggestionTable.id]].orEmpty()
            Suggestion(row[SuggestionTable.id], row[SuggestionTable.problem], row[SuggestionTable.impact], row[SuggestionTable.solution],
                votes.size >= 5, votes.any { it[SuggestionSupportTable.account].value == accountId }, row[SuggestionTable.author]?.value == accountId,
                decisions[row[SuggestionTable.id]].orEmpty().map(::decision))
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
        val fingerprint = HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(command.toByteArray(Charsets.UTF_8)))
        val existing = SuggestionDecisionTable.selectAll().where { SuggestionDecisionTable.id eq id }.singleOrNull()
        if (existing != null) {
            if (existing[SuggestionDecisionTable.suggestion] != suggestionId ||
                existing[SuggestionDecisionTable.requestFingerprint] != fingerprint) throw TeamConflictException()
            return inbox(accountId, teamId)
        }
        val revision = SuggestionDecisionTable.selectAll().where { SuggestionDecisionTable.suggestion eq suggestionId }.count().toInt()
        if (expectedRevision != revision) throw TeamConflictException()
        val owner = OrganizationTable.selectAll().where { OrganizationTable.id eq team.organizationId }.single()[OrganizationTable.creator].value
        // Lock the assignment row, not another account: removal cannot race publication,
        // and we preserve TeamRepo's account-before-assignment lock ordering.
        if (responsibleId != owner && TeamLeaderTable.selectAll().where {
                (TeamLeaderTable.team eq teamId) and (TeamLeaderTable.account eq responsibleId)
            }.forUpdate().singleOrNull() == null) throw ForbiddenResourceAccessException("Responsible person must currently lead this team")
        SuggestionDecisionTable.insert {
            it[this.id] = id; it[suggestion] = suggestionId; it[this.revision] = revision + 1
            it[this.status] = status.name; it[this.explanation] = explanation; it[requestFingerprint] = fingerprint
            it[this.responsibleName] = responsibleName; it[this.followUpDate] = followUpDate; it[publishedAt] = System.currentTimeMillis()
        }
        return inbox(accountId, teamId)
    }

    private fun decision(row: ResultRow) = SuggestionDecision(row[SuggestionDecisionTable.id], row[SuggestionDecisionTable.revision],
        SuggestionDecisionStatus.valueOf(row[SuggestionDecisionTable.status]), row[SuggestionDecisionTable.explanation],
        row[SuggestionDecisionTable.responsibleName], row[SuggestionDecisionTable.followUpDate], row[SuggestionDecisionTable.publishedAt])

    fun create(accountId: String, teamId: UUID, id: UUID, problem: String, impact: String, solution: String?): List<Suggestion> {
        member(accountId, teamId)
        val existing = SuggestionTable.selectAll().where { SuggestionTable.id eq id }.singleOrNull()
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
        SuggestionTable.update({ SuggestionTable.id eq id }) {
            it[withdrawn] = true; it[reported] = false; it[problem] = "withdrawn"; it[impact] = "withdrawn"; it[solution] = null
        }
        SuggestionSupportTable.deleteWhere { suggestion eq id }
        SuggestionDecisionTable.deleteWhere { suggestion eq id }
    }

    private fun active(teamId: UUID, id: UUID) {
        SuggestionTable.selectAll().where { (SuggestionTable.id eq id) and (SuggestionTable.team eq teamId) and (SuggestionTable.withdrawn eq false) }
            .forUpdate().singleOrNull() ?: throw TeamNotFoundException()
    }
}
