package dk.example.feedback.persistence.repo

import dk.example.feedback.model.exceptions.ForbiddenResourceAccessException
import dk.example.feedback.model.exceptions.TeamConflictException
import dk.example.feedback.model.exceptions.TeamNotFoundException
import dk.example.feedback.model.exceptions.InvalidTeamInviteException
import dk.example.feedback.model.team.*
import dk.example.feedback.persistence.table.*
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.security.SecureRandom
import java.util.Base64
import java.util.UUID

@Component
@Transactional
class TeamRepo {
    // Every employee transition locks the same account row, including approval by a leader.
    // This serializes the active/pending invariant across the two tables and all teams.
    private fun lockAccount(accountId: String) {
        AccountTable.selectAll().where { AccountTable.id eq accountId }.forUpdate().singleOrNull()
            ?: throw TeamNotFoundException()
    }

    fun context(accountId: String): TeamContext {
        val owned = organizationFor(accountId)
        val assigned = leadershipFor(accountId)
        val organization = owned ?: assigned?.let { leader ->
            val team = teamInfo(leader[TeamLeaderTable.team])
            OrganizationTable.selectAll().where { OrganizationTable.id eq team.organizationId }.single()
        }
        val membership = TeamMembershipTable.selectAll().where { TeamMembershipTable.account eq accountId }.singleOrNull()
        val request = requestFor(accountId)?.takeIf { it[TeamRequestTable.status] in listOf("Pending", "Rejected") }
        return TeamContext(
            organization = organization?.let { OrganizationInfo(it[OrganizationTable.id], it[OrganizationTable.name]) },
            isOwner = owned != null,
            managedTeams = owned?.let { org ->
                TeamTable.selectAll().where { TeamTable.organization eq org[OrganizationTable.id] }.map { teamInfo(it[TeamTable.id]) }
            } ?: assigned?.let { listOf(teamInfo(it[TeamLeaderTable.team])) } ?: emptyList(),
            membership = membership?.let { teamInfo(it[TeamMembershipTable.team]) },
            request = request?.let(::requestInfo),
        )
    }

    fun createOrganization(accountId: String, id: UUID, name: String, teamId: UUID, teamName: String): TeamContext {
        lockAccount(accountId)
        val existing = organizationFor(accountId)
        if (existing != null) {
            if (existing[OrganizationTable.id] != id) conflict()
            return context(accountId)
        }
        if (OrganizationTable.selectAll().where { OrganizationTable.id eq id }.any()) forbidden()
        if (leadershipFor(accountId) != null || hasMembership(accountId) || requestFor(accountId)?.get(TeamRequestTable.status) == "Pending") conflict()
        OrganizationTable.insert { it[this.id] = id; it[creator] = accountId; it[this.name] = name }
        addTeam(accountId, id, teamId, teamName)
        return context(accountId)
    }

    fun addTeam(accountId: String, organizationId: UUID, id: UUID, name: String): TeamInfo {
        lockAccount(accountId)
        val org = organizationFor(accountId) ?: forbidden()
        if (org[OrganizationTable.id] != organizationId) forbidden()
        val existing = TeamTable.selectAll().where { TeamTable.id eq id }.singleOrNull()
        if (existing != null) {
            if (existing[TeamTable.organization] != organizationId) forbidden()
            return teamInfo(id)
        }
        TeamTable.insert {
            it[this.id] = id; it[organization] = organizationId; it[this.name] = name; it[inviteCode] = newCode()
        }
        return teamInfo(id)
    }

    fun requireLeader(accountId: String, teamId: UUID): TeamInfo {
        lockAccount(accountId)
        val team = teamInfo(teamId)
        if (organizationFor(accountId)?.get(OrganizationTable.id) != team.organizationId &&
            leadershipFor(accountId)?.get(TeamLeaderTable.team) != teamId) forbidden()
        return team
    }

    fun requireMember(accountId: String, teamId: UUID): TeamInfo {
        val membership = TeamMembershipTable.selectAll().where { TeamMembershipTable.account eq accountId }.singleOrNull()
        if (membership?.get(TeamMembershipTable.team) != teamId) forbidden()
        return teamInfo(teamId)
    }

    fun management(accountId: String, teamId: UUID): TeamManagement {
        val team = requireLeader(accountId, teamId)
        val members = TeamMembershipTable.selectAll().where { TeamMembershipTable.team eq teamId }
            .map { TeamMember(it[TeamMembershipTable.account].value, it[TeamMembershipTable.name]) }
        return TeamManagement(team, teamRow(teamId)[TeamTable.inviteCode], members,
            TeamRequestTable.selectAll().where { (TeamRequestTable.team eq teamId) and (TeamRequestTable.status eq "Pending") and TeamRequestTable.current }
                .map(::requestInfo), members.size)
    }

    fun rotateInvite(accountId: String, teamId: UUID): TeamManagement {
        requireLeader(accountId, teamId)
        TeamTable.update({ TeamTable.id eq teamId }) { it[inviteCode] = newCode() }
        return management(accountId, teamId)
    }

    fun resolveInvite(code: String): TeamInfo {
        val team = TeamTable.selectAll().where { TeamTable.inviteCode eq code }.singleOrNull()
            ?: throw InvalidTeamInviteException()
        return teamInfo(team[TeamTable.id])
    }

    fun join(accountId: String, id: UUID, code: String, name: String): TeamContext {
        lockAccount(accountId)
        if (organizationFor(accountId) != null || leadershipFor(accountId) != null) conflict()
        val receipt = TeamRequestTable.selectAll().where { TeamRequestTable.id eq id }.singleOrNull()
        if (receipt != null) {
            if (receipt[TeamRequestTable.account].value != accountId) forbidden()
            return context(accountId)
        }
        val previous = requestFor(accountId)
        // A network retry remains valid after rotation, but never revives a terminal request.
        if (previous?.get(TeamRequestTable.id) == id) return context(accountId)
        val team = resolveInvite(code)
        val membership = TeamMembershipTable.selectAll().where { TeamMembershipTable.account eq accountId }.singleOrNull()
        if (membership != null) {
            if (membership[TeamMembershipTable.team] != team.id) conflict()
            return context(accountId)
        }
        if (previous?.get(TeamRequestTable.status) == "Pending") {
            if (previous[TeamRequestTable.team] != team.id) conflict()
            return context(accountId)
        }
        if (TeamRequestTable.selectAll().where { TeamRequestTable.id eq id }.any()) forbidden()
        TeamRequestTable.update({ TeamRequestTable.account eq accountId }) { it[current] = false }
        TeamRequestTable.insert {
            it[this.id] = id; it[account] = accountId; it[this.team] = team.id
            it[this.name] = name; it[status] = "Pending"
        }
        return context(accountId)
    }

    fun decide(accountId: String, teamId: UUID, requestId: UUID, approve: Boolean): TeamManagement {
        requireLeader(accountId, teamId)
        val initial = TeamRequestTable.selectAll().where { TeamRequestTable.id eq requestId }.singleOrNull() ?: conflict()
        if (initial[TeamRequestTable.team] != teamId) forbidden()
        val applicant = initial[TeamRequestTable.account].value
        lockAccount(applicant)
        val request = requestFor(applicant) ?: conflict()
        if (request[TeamRequestTable.id] != requestId) conflict()
        val target = if (approve) "Approved" else "Rejected"
        if (request[TeamRequestTable.status] == target) return management(accountId, teamId)
        if (request[TeamRequestTable.status] != "Pending") conflict()
        if (approve) {
            if (hasMembership(applicant) || organizationFor(applicant) != null || leadershipFor(applicant) != null) conflict()
            TeamMembershipTable.insert {
                it[account] = applicant; it[team] = teamId; it[name] = request[TeamRequestTable.name]
            }
        }
        TeamRequestTable.update({ TeamRequestTable.id eq requestId }) { it[status] = target }
        return management(accountId, teamId)
    }

    fun cancel(accountId: String, requestId: UUID): TeamContext {
        lockAccount(accountId)
        val request = requestFor(accountId)
        if (request != null && request[TeamRequestTable.id] == requestId && request[TeamRequestTable.status] == "Pending") {
            // Retain a terminal outcome so delayed retries cannot recreate the canceled request.
            TeamRequestTable.update({ TeamRequestTable.id eq requestId }) { it[status] = "Canceled" }
        }
        return context(accountId)
    }

    fun leave(accountId: String, teamId: UUID): TeamContext {
        lockAccount(accountId)
        TeamMembershipTable.deleteWhere { (account eq accountId) and (team eq teamId) }
        return context(accountId)
    }

    fun remove(accountId: String, teamId: UUID, memberId: String): TeamManagement {
        requireLeader(accountId, teamId)
        leave(memberId, teamId)
        return management(accountId, teamId)
    }

    private fun requireOwner(accountId: String, teamId: UUID) {
        lockAccount(accountId)
        if (organizationFor(accountId)?.get(OrganizationTable.id) != teamInfo(teamId).organizationId) forbidden()
    }

    fun leadership(accountId: String, teamId: UUID): TeamLeadership {
        requireOwner(accountId, teamId)
        return TeamLeadership(
            TeamLeaderTable.selectAll().where { TeamLeaderTable.team eq teamId }
                .map { TeamLeader(it[TeamLeaderTable.account].value, it[TeamLeaderTable.email]) },
            LeaderInvitationTable.selectAll().where {
                (LeaderInvitationTable.team eq teamId) and (LeaderInvitationTable.revoked eq false) and
                    LeaderInvitationTable.acceptedBy.isNull() and (LeaderInvitationTable.expiresAt greater System.currentTimeMillis())
            }.map { LeaderInvitation(it[LeaderInvitationTable.id], it[LeaderInvitationTable.email],
                it[LeaderInvitationTable.code], it[LeaderInvitationTable.expiresAt]) },
        )
    }

    fun inviteLeader(accountId: String, teamId: UUID, id: UUID, email: String): TeamLeadership {
        requireOwner(accountId, teamId)
        val existing = LeaderInvitationTable.selectAll().where { LeaderInvitationTable.id eq id }.singleOrNull()
        if (existing != null) {
            if (existing[LeaderInvitationTable.team] != teamId || existing[LeaderInvitationTable.email] != email) conflict()
            return leadership(accountId, teamId)
        }
        LeaderInvitationTable.insert {
            it[this.id] = id; it[team] = teamId; it[this.email] = email; it[code] = newCode()
            it[expiresAt] = System.currentTimeMillis() + 7 * 24 * 60 * 60 * 1000L
        }
        return leadership(accountId, teamId)
    }

    fun revokeLeaderInvite(accountId: String, teamId: UUID, id: UUID): TeamLeadership {
        requireOwner(accountId, teamId)
        val invite = LeaderInvitationTable.selectAll().where { LeaderInvitationTable.id eq id }.forUpdate().singleOrNull()
            ?: throw TeamNotFoundException()
        if (invite[LeaderInvitationTable.team] != teamId) forbidden()
        LeaderInvitationTable.update({ LeaderInvitationTable.id eq id }) { it[revoked] = true }
        return leadership(accountId, teamId)
    }

    fun removeLeader(accountId: String, teamId: UUID, leaderId: String): TeamLeadership {
        requireOwner(accountId, teamId)
        lockAccount(leaderId)
        val leader = leadershipFor(leaderId)
        if (leader?.get(TeamLeaderTable.team) == teamId) {
            LeaderInvitationTable.update({
                (LeaderInvitationTable.team eq teamId) and
                    (LeaderInvitationTable.email eq leader[TeamLeaderTable.email]) and LeaderInvitationTable.acceptedBy.isNull()
            }) { it[revoked] = true }
        }
        TeamLeaderTable.deleteWhere { (account eq leaderId) and (team eq teamId) }
        return leadership(accountId, teamId)
    }

    private fun validLeaderInvite(code: String): ResultRow {
        val invite = LeaderInvitationTable.selectAll().where { LeaderInvitationTable.code eq code }.forUpdate().singleOrNull()
            ?: throw TeamNotFoundException()
        if (invite[LeaderInvitationTable.revoked] || invite[LeaderInvitationTable.expiresAt] <= System.currentTimeMillis()) {
            throw TeamNotFoundException()
        }
        return invite
    }

    fun pendingLeaderInvitations(email: String): List<PendingLeaderInvitation> =
        LeaderInvitationTable.selectAll().where {
            (LeaderInvitationTable.email eq email) and (LeaderInvitationTable.revoked eq false) and
                LeaderInvitationTable.acceptedBy.isNull() and (LeaderInvitationTable.expiresAt greater System.currentTimeMillis())
        }.map { PendingLeaderInvitation(it[LeaderInvitationTable.code], teamInfo(it[LeaderInvitationTable.team])) }

    fun leaderInvitation(code: String): LeaderInvitationInfo {
        val invite = validLeaderInvite(code)
        if (invite[LeaderInvitationTable.acceptedBy] != null) conflict()
        return LeaderInvitationInfo(teamInfo(invite[LeaderInvitationTable.team]), invite[LeaderInvitationTable.email])
    }

    fun acceptLeadership(accountId: String, code: String, email: String): TeamContext {
        lockAccount(accountId)
        val invite = validLeaderInvite(code)
        if (invite[LeaderInvitationTable.email] != email) forbidden()
        val teamId = invite[LeaderInvitationTable.team]
        val accepted = invite[LeaderInvitationTable.acceptedBy]?.value
        if (accepted != null) {
            if (accepted != accountId || leadershipFor(accountId)?.get(TeamLeaderTable.team) != teamId) conflict()
            return context(accountId)
        }
        if (organizationFor(accountId) != null || hasMembership(accountId) ||
            requestFor(accountId)?.get(TeamRequestTable.status) == "Pending") conflict()
        val assigned = leadershipFor(accountId)
        if (assigned != null && assigned[TeamLeaderTable.team] != teamId) conflict()
        if (assigned == null) TeamLeaderTable.insert {
            it[account] = accountId; it[team] = teamId; it[this.email] = email
        }
        LeaderInvitationTable.update({ LeaderInvitationTable.id eq invite[LeaderInvitationTable.id] }) {
            it[acceptedBy] = accountId
        }
        return context(accountId)
    }

    private fun leadershipFor(accountId: String) = TeamLeaderTable.selectAll().where { TeamLeaderTable.account eq accountId }.singleOrNull()

    private fun hasMembership(accountId: String) = TeamMembershipTable.selectAll().where { TeamMembershipTable.account eq accountId }.any()
    private fun organizationFor(accountId: String) = OrganizationTable.selectAll().where { OrganizationTable.creator eq accountId }.singleOrNull()
    private fun requestFor(accountId: String) = TeamRequestTable.selectAll().where { (TeamRequestTable.account eq accountId) and TeamRequestTable.current }.singleOrNull()
    private fun teamRow(id: UUID) = TeamTable.selectAll().where { TeamTable.id eq id }.singleOrNull()
        ?: throw TeamNotFoundException()
    private fun teamInfo(id: UUID): TeamInfo {
        val row = teamRow(id)
        val org = OrganizationTable.selectAll().where { OrganizationTable.id eq row[TeamTable.organization] }.single()
        return TeamInfo(id, org[OrganizationTable.id], org[OrganizationTable.name], row[TeamTable.name])
    }
    private fun requestInfo(row: ResultRow) = TeamJoinRequest(row[TeamRequestTable.id], teamInfo(row[TeamRequestTable.team]),
        row[TeamRequestTable.name], TeamRequestStatus.valueOf(row[TeamRequestTable.status]))
    private fun newCode(): String = Base64.getUrlEncoder().withoutPadding().encodeToString(ByteArray(24).also { SecureRandom().nextBytes(it) })
    private fun forbidden(): Nothing = throw ForbiddenResourceAccessException("No access to this team")
    private fun conflict(): Nothing = throw TeamConflictException()
}
