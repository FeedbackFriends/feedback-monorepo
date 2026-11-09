package dk.example.feedback.persistence.repo

import dk.example.feedback.model.exceptions.ForbiddenResourceAccessException
import dk.example.feedback.model.exceptions.TeamConflictException
import dk.example.feedback.model.exceptions.TeamNotFoundException
import dk.example.feedback.model.team.Suggestion
import dk.example.feedback.model.team.ReportedSuggestion
import dk.example.feedback.persistence.table.*
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

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
        val rows = SuggestionTable.selectAll().where { (SuggestionTable.team eq teamId) and (SuggestionTable.withdrawn eq false) }
            .orderBy(SuggestionTable.id).toList()
        if (rows.isEmpty()) return emptyList()
        val support = SuggestionSupportTable.selectAll().where { SuggestionSupportTable.suggestion inList rows.map { it[SuggestionTable.id] } }
            .groupBy { it[SuggestionSupportTable.suggestion] }
        return rows.map { row ->
            val votes = support[row[SuggestionTable.id]].orEmpty()
            Suggestion(row[SuggestionTable.id], row[SuggestionTable.problem], row[SuggestionTable.impact], row[SuggestionTable.solution],
                votes.size.toLong(), votes.any { it[SuggestionSupportTable.account].value == accountId }, row[SuggestionTable.author]?.value == accountId)
        }
    }

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
    }

    private fun active(teamId: UUID, id: UUID) {
        SuggestionTable.selectAll().where { (SuggestionTable.id eq id) and (SuggestionTable.team eq teamId) and (SuggestionTable.withdrawn eq false) }
            .forUpdate().singleOrNull() ?: throw TeamNotFoundException()
    }
}
